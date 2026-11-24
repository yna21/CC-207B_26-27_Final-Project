import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/screens/guard/data/guard_log.dart';
import 'package:websupark/screens/guard/data/sample_guard_data.dart';
import 'package:websupark/screens/guard/services/pass_recognition_service.dart';
import 'package:websupark/screens/guard/utils/pass_number_validator.dart';
import 'package:websupark/screens/guard/widgets/dashed_rrect_painter.dart';
import 'package:websupark/theme/app_colors.dart';

/// How many scans in a row must read the SAME registered pass number before
/// the vehicle record opens. Only numbers that belong to a registered pass
/// count, so 1 is safe and works best when the OCR result flickers between
/// scans. Set it to 2 for extra caution.
const int _requiredAgreeingReads = 1;

/// Time between two automatic scans.
const Duration _scanInterval = Duration(milliseconds: 1500);

/// What the camera is doing.
enum _CameraMode { starting, on, error, off }

class ScanVehiclePassScreen extends StatefulWidget {
  const ScanVehiclePassScreen({super.key});

  @override
  State<ScanVehiclePassScreen> createState() => _ScanVehiclePassScreenState();
}

class _ScanVehiclePassScreenState extends State<ScanVehiclePassScreen> {
  Timer? _elapsedTimer;
  Timer? _scanTimer;

  int _seconds = 0;

  CameraController? _cameraController;
  _CameraMode _mode = _CameraMode.starting;

  /// Bumped every time the camera is started or stopped. Any start-up or scan
  /// that began under an older number is stale and must do nothing more.
  int _session = 0;

  /// The photo currently being taken. The camera must not be released until
  /// this finishes, or the browser keeps the camera light on.
  Future<void>? _pendingShot;

  /// After a pass found by the camera, the camera comes back when the guard
  /// returns to this screen. After manual entry it stays OFF.
  bool _resumeCameraOnReturn = true;

  bool _torchOn = false;
  bool _isCapturing = false;
  bool _hasNavigated = false;

  // Agreement between consecutive scans (see _requiredAgreeingReads).
  String? _lastCandidate;
  int _agreeingReads = 0;

  // A number the guard said was NOT correct is ignored for a short time, so
  // the same wrong read does not open the question again straight away.
  String? _rejectedNumber;
  DateTime? _rejectedUntil;

  bool _isRejected(String number) =>
      number == _rejectedNumber &&
      _rejectedUntil != null &&
      DateTime.now().isBefore(_rejectedUntil!);

  String? _cameraError;
  String _scanStatus = 'Starting the camera...';

  @override
  void initState() {
    super.initState();

    // Started after the first frame, so setState inside it is safe.
    Future.microtask(_startCamera);

    _elapsedTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() => _seconds++);
        }
      },
    );
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _session++;
    _scanTimer?.cancel();
    _cameraController?.dispose();
    _cameraController = null;
    super.dispose();
  }

  String get _elapsed {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  // ------------------------------------------------------------
  // CAMERA ON / OFF
  // ------------------------------------------------------------

  Future<void> _startCamera() async {
    if (!mounted || _cameraController != null) return;

    // Any older start-up or scan becomes stale from here on.
    final session = ++_session;
    CameraController? controller;

    setState(() {
      _mode = _CameraMode.starting;
      _cameraError = null;
      _scanStatus = 'Starting the camera...';
    });

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('No camera was found on this device.');
      }

      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // A high resolution matters: the printed digits are small.
      controller = CameraController(
        selectedCamera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );

      await controller.initialize();

      // The guard chose manual entry (or left) while the camera was starting.
      if (!mounted || session != _session) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _mode = _CameraMode.on;
        _cameraError = null;
        _scanStatus = 'Camera ready. Looking for vehicle pass...';
      });

      _startAutomaticScanning();
    } catch (error) {
      if (controller != null && !identical(controller, _cameraController)) {
        try {
          await controller.dispose();
        } catch (_) {}
      }

      if (!mounted || session != _session) return;

      setState(() {
        _mode = _CameraMode.error;
        _cameraError = error.toString();
        _scanStatus = 'Camera unavailable';
      });
    }
  }

  /// Stops scanning and RELEASES the camera (the browser's camera light goes
  /// off). Used for manual entry and while the vehicle record is open.
  Future<void> _stopCamera() async {
    // Invalidate any start-up or scan that is still running.
    _session++;

    _scanTimer?.cancel();
    _scanTimer = null;
    _lastCandidate = null;
    _agreeingReads = 0;
    _isCapturing = false;

    final controller = _cameraController;
    _cameraController = null;

    if (mounted) {
      setState(() {
        _mode = _CameraMode.off;
        _torchOn = false;
        _scanStatus = 'Camera off';
      });
    }

    if (controller == null) return;

    // Let the screen stop showing the preview before the camera is released.
    await WidgetsBinding.instance.endOfFrame;

    // Never release the camera in the middle of taking a photo.
    try {
      await _pendingShot?.timeout(const Duration(seconds: 2));
    } catch (_) {}

    try {
      await controller.dispose();
    } catch (_) {
      // Already released.
    }
  }

  // ------------------------------------------------------------
  // AUTOMATIC SCANNING
  // ------------------------------------------------------------

  void _startAutomaticScanning() {
    final controller = _cameraController;

    if (controller == null ||
        !controller.value.isInitialized ||
        _hasNavigated) {
      return;
    }

    if (!PassRecognitionService.isAvailable) {
      setState(() {
        _scanStatus =
            'Pass recognition is not set up (web/ocr_helper.js). Use manual entry.';
      });
      return;
    }

    _scanTimer?.cancel();

    // Perform an initial scan immediately.
    _captureAndRecognize();

    _scanTimer = Timer.periodic(_scanInterval, (_) {
      _captureAndRecognize();
    });
  }

  Future<void> _captureAndRecognize() async {
    final controller = _cameraController;

    if (controller == null ||
        !controller.value.isInitialized ||
        _isCapturing ||
        _hasNavigated) {
      return;
    }

    final session = _session;

    setState(() {
      _isCapturing = true;
      _scanStatus = 'Reading vehicle pass...';
    });

    try {
      // Take the photo. The camera is free again as soon as this finishes,
      // so manual entry never has to wait for the (slower) OCR below.
      final shot = controller.takePicture();
      _pendingShot = shot.then<void>((_) {}, onError: (_) {});
      final image = await shot;
      if (!mounted || session != _session) return;

      final imageBytes = await image.readAsBytes();
      final recognizedText =
          await PassRecognitionService.recognizeText(imageBytes);

      // The camera may have been switched off while the OCR was running.
      if (!mounted || _hasNavigated || session != _session) return;

      // Only numbers that belong to a registered vehicle pass count.
      final candidates =
          PassNumberValidator.extractCandidates(recognizedText);
      final registered = candidates
          .where((number) =>
              findVehicleByPassNumber(number) != null &&
              !_isRejected(number))
          .toList();

      if (registered.isEmpty) {
        _lastCandidate = null;
        _agreeingReads = 0;
        setState(() {
          _scanStatus = candidates.isEmpty
              ? 'Looking for vehicle pass...'
              : 'Read ${PassNumberValidator.display(candidates.first)}: no vehicle pass found. Keep scanning...';
        });
        return;
      }

      final number = registered.first;
      if (number == _lastCandidate) {
        _agreeingReads++;
      } else {
        _lastCandidate = number;
        _agreeingReads = 1;
      }

      if (_agreeingReads < _requiredAgreeingReads) {
        setState(() => _scanStatus =
            'Read ${PassNumberValidator.display(number)}. Checking...');
        return;
      }

      // Same number on consecutive scans: open the vehicle record.
      await _openRecord(number, fromCamera: true);
    } catch (error) {
      if (!mounted || session != _session) return;

      setState(() {
        _scanStatus = 'Scan failed. Trying again...';
      });
    } finally {
      // A stale scan must not unlock a newer session.
      if (mounted && session == _session) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // FLASHLIGHT
  // ------------------------------------------------------------

  Future<void> _toggleTorch() async {
    final controller = _cameraController;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      final newMode = _torchOn ? FlashMode.off : FlashMode.torch;

      await controller.setFlashMode(newMode);

      if (!mounted) return;

      setState(() {
        _torchOn = !_torchOn;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Flashlight is not supported by this camera.'),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // CAMERA PREVIEW
  // ------------------------------------------------------------

  Widget _buildCameraPreview() {
    switch (_mode) {
      case _CameraMode.error:
        return _CameraErrorView(
          message: _cameraError ?? 'Unable to access camera.',
          onRetry: _startCamera,
        );
      case _CameraMode.off:
        return _CameraOffView(onTurnOn: _startCamera);
      case _CameraMode.starting:
        return const _CameraPlaceholder();
      case _CameraMode.on:
        final controller = _cameraController;
        if (controller == null || !controller.value.isInitialized) {
          return const _CameraPlaceholder();
        }
        return SizedBox.expand(
          child: CameraPreview(controller),
        );
    }
  }

  // ------------------------------------------------------------
  // MANUAL PASS NUMBER ENTRY
  // ------------------------------------------------------------

  Future<void> _enterManually() async {
    // Typing the number replaces the camera: turn the camera off completely.
    await _stopCamera();

    if (!mounted) return;

    setState(() => _scanStatus = 'Camera off · manual entry');

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) => const _PassNumberSheet(),
    );

    if (!mounted) return;

    if (result != null) {
      // The camera stays off.
      await _openRecord(result, fromCamera: false);
      return;
    }

    // The box was closed without a number: bring the camera back.
    _startCamera();
  }

  // ------------------------------------------------------------
  // CONFIRM THE DETECTED PASS NUMBER
  // ------------------------------------------------------------

  /// Asks whether the number read by the camera matches the pass.
  /// Returns true only when the guard taps "Yes".
  Future<bool> _confirmPassNumber(String passNumber) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Is this pass number correct?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'The scanner read this number from the vehicle pass.',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                PassNumberValidator.display(passNumber),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Compare it with the number printed on the pass.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No, scan again'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Yes, open record'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // ------------------------------------------------------------
  // VEHICLE RECORD
  // ------------------------------------------------------------

  Future<void> _openRecord(
    String passNumber, {
    required bool fromCamera,
  }) async {
    if (!mounted || _hasNavigated) return;

    // A scan result must not open anything once the camera has been turned off.
    if (fromCamera && _mode != _CameraMode.on) return;

    final found = findVehicleByPassNumber(passNumber);

    if (found == null) {
      setState(() {
        _scanStatus = fromCamera
            ? 'Pass ${PassNumberValidator.display(passNumber)} not found. Keep scanning...'
            : 'Camera off · pass ${PassNumberValidator.display(passNumber)} not found';
      });

      if (!fromCamera) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No vehicle pass found for ${PassNumberValidator.display(passNumber)}.'),
          ),
        );
      }

      return;
    }

    // The pass number was read by the camera, not typed: ask the guard to
    // confirm it before any owner details are shown.
    if (fromCamera) {
      _scanTimer?.cancel(); // no new scans while the question is open
      final correct = await _confirmPassNumber(passNumber);

      if (!mounted) return;

      if (!correct) {
        // Wrong read: forget it, ignore it for a while and keep scanning.
        _rejectedNumber = passNumber;
        _rejectedUntil = DateTime.now().add(const Duration(seconds: 10));
        _lastCandidate = null;
        _agreeingReads = 0;
        setState(() => _scanStatus = 'Looking for vehicle pass...');
        _startAutomaticScanning();
        return;
      }

      // The camera may have been turned off while the question was open.
      if (_mode != _CameraMode.on) return;
    }

    final record = found.copyWith(
      pastViolations: [
        ...found.pastViolations,
        ...GuardLog.instance.violationsFor(found.plate),
      ],
    );

    _hasNavigated = true;
    _resumeCameraOnReturn = fromCamera;

    // The vehicle is identified: stop scanning and release the camera.
    await _stopCamera();

    if (!mounted) return;

    setState(() {
      _scanStatus =
          fromCamera ? 'Vehicle pass recognized!' : 'Camera off · manual entry';
    });

    Navigator.pushNamed(
      context,
      AppRoutes.guardVehicleRecord,
      arguments: record,
    ).then((_) {
      if (!mounted) return;

      _hasNavigated = false;

      if (_resumeCameraOnReturn) {
        // Found by the camera: scan again when the guard comes back.
        _startCamera();
      } else {
        // Entered manually: the camera stays off until the guard turns it on.
        setState(() => _scanStatus = 'Camera off · manual entry');
      }
    });
  }

  // ------------------------------------------------------------
  // MAIN SCREEN
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, box) {
          // Phone: the camera fills the screen. Wider: a compact camera card.
          final card = box.maxWidth > 460;

          final camera = ColoredBox(
            color: AppColors.sidebar,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildCameraPreview(),
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                        stops: const [0, 0.25, 0.7, 1],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, inner) => SingleChildScrollView(
                      child: ConstrainedBox(
                        // Fills the box when there is room, scrolls when not.
                        constraints:
                            BoxConstraints(minHeight: inner.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              _buildTopBar(),
                              const SizedBox(height: 8),
                              _buildHintBanner(),
                              const Spacer(),
                              _buildScanFrame(),
                              const Spacer(flex: 2),
                              _buildBottomPanel(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

          // Same width as the other guard screens (the shell limits it).
          return Padding(
            padding: card ? const EdgeInsets.all(16) : EdgeInsets.zero,
            child: card
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: camera,
                  )
                : camera,
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // TOP BAR
  // ------------------------------------------------------------

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _GlassIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIVE CAMERA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'Scan Vehicle Pass',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          _GlassIconButton(
            icon: _torchOn ? Icons.flash_on : Icons.flash_off,
            onTap: _toggleTorch,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HINT BANNER
  // ------------------------------------------------------------

  Widget _buildHintBanner() {
    final String label;
    final Color color;

    switch (_mode) {
      case _CameraMode.on:
        label = 'READY';
        color = AppColors.success;
      case _CameraMode.starting:
        label = 'STARTING';
        color = AppColors.warning;
      case _CameraMode.off:
        label = 'CAMERA OFF';
        color = AppColors.textMuted;
      case _CameraMode.error:
        label = 'NO CAMERA';
        color = AppColors.danger;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.sidebar.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.center_focus_strong_outlined,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Align the complete pass inside the frame',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SCAN FRAME
  // ------------------------------------------------------------

  Widget _buildScanFrame() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: AspectRatio(
            aspectRatio: 300 / 220,
            child: CustomPaint(
              painter: const DashedRRectPainter(
                color: AppColors.warning,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: -14,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'VEHICLE PASS AREA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: AppColors.sidebar,
                        ),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.crop_free,
                    color: Colors.white,
                    size: 38,
                  ),
                  const Positioned(
                    bottom: 16,
                    child: Text(
                      'Hold steady · 15–25 cm away',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM PANEL
  // ------------------------------------------------------------

  Widget _buildBottomPanel() {
    final cameraOn = _mode == _CameraMode.on;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sidebar.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                _isCapturing
                    ? Icons.document_scanner
                    : Icons.document_scanner_outlined,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _scanStatus,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
              if (_isCapturing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Text(
                  _elapsed,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Manual entry turns the camera off.
          ElevatedButton.icon(
            onPressed: _enterManually,
            icon: const Icon(
              Icons.keyboard_outlined,
              size: 20,
            ),
            label: const Text(
              'Enter Pass Number Manually',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cameraOn
                ? 'Automatic scanning is active'
                : 'The camera is off',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// CAMERA PLACEHOLDERS
// ------------------------------------------------------------

const BoxDecoration _cameraBackdrop = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF3A3F47),
      AppColors.sidebar,
    ],
  ),
);

class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: _cameraBackdrop,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white70,
            ),
            SizedBox(height: 12),
            Text(
              'Starting the camera...',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the camera was turned off (manual entry).
class _CameraOffView extends StatelessWidget {
  final VoidCallback onTurnOn;

  const _CameraOffView({required this.onTurnOn});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _cameraBackdrop,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam_off_outlined,
                color: Colors.white70,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Camera is off',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Entering the pass number manually turns the camera off.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onTurnOn,
                icon: const Icon(Icons.videocam_outlined),
                label: const Text('Turn camera on'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CameraErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sidebar,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.videocam_off_outlined,
            color: Colors.white70,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to access camera',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry Camera'),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// GLASS ICON BUTTON
// ------------------------------------------------------------

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sidebar.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// MANUAL PASS NUMBER ENTRY
// ------------------------------------------------------------

class _PassNumberSheet extends StatefulWidget {
  const _PassNumberSheet();

  @override
  State<_PassNumberSheet> createState() => _PassNumberSheetState();
}

class _PassNumberSheetState extends State<_PassNumberSheet> {
  final TextEditingController _controller = TextEditingController();

  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = PassNumberValidator.normalize(_controller.text);

    if (value == null) {
      setState(() {
        _error = 'Please follow your vehicle pass number format.';
      });

      return;
    }

    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter pass number',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[SsEe0-9 ]')),
              LengthLimitingTextInputFormatter(5),
              TextInputFormatter.withFunction(
                (oldValue, newValue) =>
                    newValue.copyWith(text: newValue.text.toUpperCase()),
              ),
            ],
            decoration: InputDecoration(
              hintText: 'Vehicle pass number',
              helperText: 'Type your vehicle pass number',
              errorText: _error,
            ),
            onChanged: (_) {
              if (_error != null) {
                setState(() => _error = null);
              }
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}