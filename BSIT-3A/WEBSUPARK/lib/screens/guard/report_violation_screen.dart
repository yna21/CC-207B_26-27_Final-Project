import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:websupark/screens/guard/data/guard_log.dart';
import 'package:websupark/screens/guard/models/guard_case.dart';
import 'package:websupark/screens/guard/models/parking_check.dart';
import 'package:websupark/models/pass_type.dart';
import 'package:websupark/screens/guard/models/past_violation.dart';
import 'package:websupark/screens/guard/guard_vehicle.dart';
import 'package:websupark/screens/guard/models/violation_type.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/theme/app_colors.dart';
import 'package:websupark/screens/guard/widgets/guard_colors.dart';
import 'package:websupark/screens/guard/utils/time_format.dart';
import 'package:websupark/screens/guard/widgets/dashed_rrect_painter.dart';
import 'package:websupark/screens/guard/widgets/guard_widgets.dart';

class ReportViolationScreen extends StatefulWidget {
  final GuardCase guardCase;

  const ReportViolationScreen({super.key, required this.guardCase});

  GuardVehicle get record => guardCase.record;
  ParkingCheck get check => guardCase.check;

  @override
  State<ReportViolationScreen> createState() => _ReportViolationScreenState();
}

class _ReportViolationScreenState extends State<ReportViolationScreen> {
  static const int _maxPhotos = 4;

  final ImagePicker _picker = ImagePicker();
  final List<Uint8List> _photos = [];
  final TextEditingController _notes = TextEditingController(); // starts empty
  // A vehicle parked outside its assigned area: "Unauthorized Parking"
  // (no. 8 on the Traffic Violation Ticket). The guard can change it.
  ViolationType _type = ViolationType.unauthorizedParking;
  bool _verified = false;

  bool get _canSubmit => _verified && _photos.isNotEmpty;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  /// Sanctions and Penalties, nos. 1 and 3 of the guidelines.
  String? get _sanctionNote {
    switch (widget.record.passType) {
      case PassType.studentWithParking:
        return 'An incident report will be submitted to the Office of Student Affairs.';
      case PassType.facultyStaffWithParking:
        return 'A Traffic Violation Ticket (TVT) will be issued. An explanation is required within 72 hours.';
      case PassType.parentGuardianWithParking:
      case PassType.withoutParking:
        return null;
    }
  }

  /// Camera or gallery on phones; file chooser in the browser.
  Future<void> _addPhoto() async {
    if (_photos.length >= _maxPhotos) return;

    ImageSource? source = ImageSource.gallery;
    if (!kIsWeb) {
      source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
    }
    if (source == null) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() => _photos.add(bytes));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not add the photo. Please try again.')),
      );
    }
  }

  void _submit() {
    final record = widget.record;
    final area = widget.check.detectedArea;
    final now = DateTime.now();
    final log = GuardLog.instance;

    final incidentRef = log.nextIncidentRef();
    final offense = record.offenseNumberFor(_type);

    // TODO: upload type, notes and photos to your backend.
    log.addViolation(
      record.plate,
      PastViolation(type: _type, date: formatDate(now)),
    );
    log.markReported(
      widget.guardCase.checkId,
      plate: record.plate,
      location: '${area.id} · ${area.name}',
      incidentRef: incidentRef,
    );

    final submitted = widget.guardCase.copyWith(
      incidentRef: incidentRef,
      syncedAt: formatHm(now),
      violationType: _type,
      offenseNumber: offense,
      notes: _notes.text.trim(),
      photos: List.of(_photos),
    );

    // The card in "Recent checks" opens the full incident from this.
    log.saveCase(submitted);

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.guardReportSubmitted,
      arguments: submitted,
    );
  }

  Widget _offenseCard() {
    final record = widget.record;
    final offense = record.offenseNumberFor(_type);
    final parkingTotal =
        record.parkingViolationCount + (_type.isParking ? 1 : 0);
    final suspension = _type.isParking && parkingTotal > 3;
    final note = _sanctionNote;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: suspension
            ? AppColors.dangerSoft
            : AppColors.action.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: suspension ? Border.all(color: AppColors.danger) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${ordinal(offense)} offense · ${_type.label}',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
          if (suspension) ...[
            const SizedBox(height: 6),
            const Text(
              'More than three parking violations: parking privileges may be suspended for three (3) months.',
              style: TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger),
            ),
          ],
          if (note != null) ...[
            const SizedBox(height: 6),
            Text(note,
                style: const TextStyle(
                    fontSize: 12.5, height: 1.35, color: AppColors.textPrimary)),
          ],
          const SizedBox(height: 6),
          const Text(
            'The violator is subject to V-pass suspension or cancellation.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final check = widget.check;

    return Scaffold(
      appBar: const GuardAppBar(
          title: 'Report Violation', subtitle: 'DRAFT · AUTO-SAVED'),
      body: SafeArea(
        child: ScreenBody(
          bottom: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _verified = !_verified),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _verified,
                          activeColor: AppColors.action,
                          onChanged: (v) =>
                              setState(() => _verified = v ?? false),
                        ),
                        const Expanded(
                          child: Text(
                            'I verified the vehicle, location, and evidence above.',
                            style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _canSubmit ? _submit : null,
                icon: const Icon(Icons.send_outlined, size: 20),
                label: const Text('Submit Violation',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GuardColors.successDark,
                  disabledBackgroundColor:
                      GuardColors.successDark.withValues(alpha: 0.35),
                  disabledForegroundColor: Colors.white70,
                  minimumSize: const Size.fromHeight(56),
                ),
              ),
            ],
          ),
          children: [
            SectionCard(
              title: 'VERIFY DETAILS',
              trailing: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: const Text('Edit',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.action)),
              ),
              child: Column(
                children: [
                  DetailRow('Vehicle', record.plate,
                      valueStyle: monoStyle.copyWith(fontSize: 14)),
                  DetailRow('Driver', record.driverName),
                  DetailRow('Pass type', record.passType.label),
                  DetailRow(
                    'Assigned / found',
                    '${record.assignedArea?.id ?? '-'}  →  ${check.detectedArea.id}',
                    valueStyle: monoStyle.copyWith(
                        fontSize: 14, color: GuardColors.warningText),
                  ),
                  DetailRow('Observed', check.observedAt),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const CaptionLabel('VIOLATION TYPE', color: AppColors.textPrimary),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in ViolationType.values)
                  _TypeChip(
                    label: t.label,
                    selected: _type == t,
                    onTap: () => setState(() => _type = t),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _offenseCard(),
            const SizedBox(height: 18),
            const Text('Guard notes (optional)',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _notes,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(
                  fontSize: 15, height: 1.35, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Write what you observed...',
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CaptionLabel('EVIDENCE', color: AppColors.textPrimary),
                Text(
                  _photos.isEmpty
                      ? 'At least 1 photo required'
                      : '${_photos.length} photo${_photos.length == 1 ? '' : 's'} attached',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color:
                        _photos.isEmpty ? AppColors.danger : AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 96,
              child: _photos.isEmpty
                  ? _AddPhotoTile(onTap: _addPhoto)
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (var i = 0; i < _photos.length; i++) ...[
                          SizedBox(
                            width: 150,
                            child: _PhotoTile(
                              bytes: _photos[i],
                              label:
                                  '${check.detectedArea.id} PHOTO ${i + 1}',
                              onRemove: () =>
                                  setState(() => _photos.removeAt(i)),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (_photos.length < _maxPhotos)
                          SizedBox(
                              width: 150,
                              child: _AddPhotoTile(onTap: _addPhoto)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.warningSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? GuardColors.warningText : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: selected ? GuardColors.warningText : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final Uint8List bytes;
  final String label;
  final VoidCallback onRemove;

  const _PhotoTile(
      {required this.bytes, required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(bytes, fit: BoxFit.cover),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.sidebar.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.sidebar.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 15, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPhotoTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: CustomPaint(
        painter: const DashedRRectPainter(
          color: AppColors.action,
          radius: 12,
          strokeWidth: 1.5,
          dash: 6,
          gap: 4,
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_camera_outlined,
                  color: AppColors.action, size: 22),
              SizedBox(height: 6),
              Text('Add photo',
                  style: TextStyle(fontSize: 13, color: AppColors.action)),
            ],
          ),
        ),
      ),
    );
  }
}