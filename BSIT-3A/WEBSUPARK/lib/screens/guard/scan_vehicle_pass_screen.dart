import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:websupark/screens/guard/data/guard_log.dart';
import 'package:websupark/screens/guard/data/sample_guard_data.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/theme/app_colors.dart';
import 'package:websupark/screens/guard/widgets/dashed_rrect_painter.dart';

/// Shows tappable sample pass numbers in the entry box (for demos and tests).
/// Set to false when real passes are used.
const bool _showDemoPasses = true;

class ScanVehiclePassScreen extends StatefulWidget {
  const ScanVehiclePassScreen({super.key});

  @override
  State<ScanVehiclePassScreen> createState() => _ScanVehiclePassScreenState();
}

class _ScanVehiclePassScreenState extends State<ScanVehiclePassScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _elapsed {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _enterManually() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _PassNumberSheet(),
    );
    if (result != null) _openRecord(result);
  }

  /// Also call this from the OCR / camera result later.
  void _openRecord(String passNumber) {
    if (!mounted) return;
    // TODO: replace with repository.findVehicleBy...(passNumber).
    final found = findVehicleByPassNumber(passNumber);
    if (found == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No vehicle pass found for $passNumber.')),
      );
      return;
    }
    // Add the violations reported in this session to the vehicle's history.
    final record = found.copyWith(
      pastViolations: [
        ...found.pastViolations,
        ...GuardLog.instance.violationsFor(found.plate),
      ],
    );
    Navigator.pushNamed(
      context,
      AppRoutes.guardVehicleRecord,
      arguments: record,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sidebar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // TODO: replace with CameraPreview(controller) or MobileScanner(...)
          const _CameraPlaceholder(),
          DecoratedBox(
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
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                const SizedBox(height: 8),
                _buildHintBanner(),
                const Spacer(),
                _buildScanFrame(),
                const Spacer(flex: 2),
                _buildBottomPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
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
            // TODO: also call controller.setFlashMode(...)
            onTap: () => setState(() => _torchOn = !_torchOn),
          ),
        ],
      ),
    );
  }

  Widget _buildHintBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.sidebar.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.center_focus_strong_outlined,
              color: Colors.white, size: 18),
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
              color: AppColors.success,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'READY',
              style: TextStyle(
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

  Widget _buildScanFrame() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: AspectRatio(
        aspectRatio: 300 / 220,
        child: CustomPaint(
          painter: const DashedRRectPainter(color: AppColors.warning),
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
              const Icon(Icons.crop_free, color: Colors.white, size: 38),
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
    );
  }

  Widget _buildBottomPanel() {
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
              const Icon(Icons.document_scanner_outlined,
                  color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Waiting for pass...',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
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
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _enterManually,
            icon: const Icon(Icons.keyboard_outlined, size: 20),
            label: const Text(
              'Enter Pass Number Manually',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3A3F47), AppColors.sidebar],
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

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
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

/// Bottom sheet for typing a pass number. A pass number is exactly 5 digits
/// (e.g. 00921); anything else is rejected with a message.
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
    final value = _controller.text.trim();
    if (!RegExp(r'^\d{5}$').hasMatch(value)) {
      setState(() => _error = 'Pass number must be exactly 5 digits (e.g. 00921).');
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
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
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(5),
            ],
            decoration: InputDecoration(
              hintText: 'e.g. 00921',
              helperText: '5-digit pass number',
              errorText: _error,
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _submit(),
          ),
          if (_showDemoPasses) ...[
            const SizedBox(height: 12),
            const Text(
              'DEMO PASSES · tap to fill',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final v in sampleVehicles)
                  ActionChip(
                    label: Text('${v.passNumber} · ${v.plate}'),
                    onPressed: () => setState(() {
                      _controller.text = v.passNumber;
                      _controller.selection = TextSelection.collapsed(
                          offset: v.passNumber.length);
                      _error = null;
                    }),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _submit, child: const Text('Verify')),
        ],
      ),
    );
  }
}