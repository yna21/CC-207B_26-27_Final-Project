import 'package:flutter/material.dart';
import 'package:websupark/data/sample_parking_areas.dart';
import 'package:websupark/models/parking_area.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/screens/guard/data/guard_log.dart';
import 'package:websupark/screens/guard/data/sample_guard_data.dart';
import 'package:websupark/screens/guard/guard_vehicle.dart';
import 'package:websupark/screens/guard/models/guard_case.dart';
import 'package:websupark/screens/guard/models/parking_check.dart';
import 'package:websupark/screens/guard/models/vehicle_check.dart';
import 'package:websupark/screens/guard/models/verify_result.dart';
import 'package:websupark/screens/guard/utils/time_format.dart';
import 'package:websupark/screens/guard/widgets/guard_colors.dart';
import 'package:websupark/screens/guard/widgets/guard_widgets.dart';
import 'package:websupark/theme/app_colors.dart';
import 'package:websupark/widgets/status_chip.dart';

class VerifyParkingScreen extends StatefulWidget {
  final GuardCase guardCase;

  const VerifyParkingScreen({super.key, required this.guardCase});

  @override
  State<VerifyParkingScreen> createState() => _VerifyParkingScreenState();
}

class _VerifyParkingScreenState extends State<VerifyParkingScreen> {
  /// The area chosen in the dropdown (not confirmed yet).
  String? _selectedId;

  /// The confirmed check. null = the guard has not verified a location yet.
  ParkingCheck? _check;

  /// The entry in "Recent checks" created when the location was verified.
  String? _checkId;

  GuardVehicle get record => widget.guardCase.record;

  @override
  void initState() {
    super.initState();

    // Opened from "Recent checks": the location was already verified, so
    // show the saved result instead of asking again.
    final saved = widget.guardCase;
    if (saved.checkId != null) {
      _check = saved.check;
      _checkId = saved.checkId;
      _selectedId = saved.check.detectedArea.id;
      GuardLog.instance.saveCase(saved);
    }
  }

  /// The case carried to the next screens, using the area the guard selected.
  GuardCase _caseFor(ParkingCheck check) {
    final g = widget.guardCase;
    return GuardCase(
      record: record,
      check: check,
      checkId: _checkId,
      incidentRef: g.incidentRef,
      syncedAt: g.syncedAt,
      violationType: g.violationType,
      offenseNumber: g.offenseNumber,
      notes: g.notes,
      photos: g.photos,
    );
  }

  /// The guard confirms the area where the vehicle was found.
  /// There is no GPS: the location is chosen by the guard.
  void _verifyLocation() {
    final id = _selectedId;
    if (id == null) return;

    final area = sampleParkingAreas.firstWhere((a) => a.id == id);
    final now = DateTime.now();

    final check = ParkingCheck(
      detectedArea: area,
      beacon: 'Selected by guard',
      accuracyMeters: 0,
      checkedAt: formatHms(now),
      observedAt: '${formatMonthDay(now)} · ${formatHm(now)}',
      hasOpenEntry: hasOpenEntry(record),
    );

    // Every vehicle that is verified is added to "Recent checks".
    final checkId = GuardLog.instance.recordCheck(
      plate: record.plate,
      location: '${area.id} · ${area.name}',
      status: switch (verifyParking(record, check)) {
        VerifyResult.cleared => CheckStatus.cleared,
        VerifyResult.mismatch => CheckStatus.mismatch,
        VerifyResult.noOpenEntry => CheckStatus.noEntry,
      },
      driverName: record.driverName,
      passTypeLabel: record.passType.label,
    );

    setState(() {
      _check = check;
      _checkId = checkId;
    });

    // Keep the full case so the card in "Recent checks" can open its details.
    GuardLog.instance.saveCase(_caseFor(check));
  }

  void _backToPatrol() => Navigator.of(context).popUntil((route) =>
      route.settings.name == AppRoutes.guardConsole || route.isFirst);

  String _mismatchText(ParkingArea area) {
    final assigned = record.assignedArea;
    if (assigned == null) {
      return 'This ${record.passType.label} pass has no assigned area, but the '
          'vehicle is parked in ${area.id} (${area.name}). '
          'Confirm and report if accurate.';
    }
    return 'Assigned area is ${assigned.id} (${assigned.name}), but the vehicle '
        'was found in ${area.id} (${area.name}). Confirm the area and report '
        'if the mismatch is accurate.';
  }

  // ---- bottom buttons ----

  Widget _backToPatrolButton() => OutlinedButton.icon(
        onPressed: _backToPatrol,
        icon: const Icon(Icons.shield_outlined, size: 20),
        label: const Text('Back to Patrol',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  /// Before the location is verified.
  Widget _pickerActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: _selectedId == null ? null : _verifyLocation,
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Verify Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        ),
        const SizedBox(height: 10),
        _backToPatrolButton(),
      ],
    );
  }

  /// After the location is verified.
  Widget _resultActions(VerifyResult result, ParkingCheck check) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        switch (result) {
          VerifyResult.cleared => ElevatedButton.icon(
              onPressed: _backToPatrol,
              icon: const Icon(Icons.shield_outlined),
              label: const Text('Back to Patrol',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56)),
            ),
          VerifyResult.mismatch => ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.guardReportViolation,
                arguments: _caseFor(check),
              ),
              icon: const Icon(Icons.report_gmailerrorred_outlined),
              label: const Text('Report Violation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                minimumSize: const Size.fromHeight(56),
              ),
            ),
          VerifyResult.noOpenEntry => ElevatedButton.icon(
              onPressed: () {
                // TODO: repository.recordEntry(vehicleId)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Entry recorded for ${record.plate}')),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Record Entry',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56)),
            ),
        },
        if (result != VerifyResult.cleared) ...[
          const SizedBox(height: 10),
          _backToPatrolButton(),
        ],
      ],
    );
  }

  // ---- result banner ----

  Widget _banner(VerifyResult result, ParkingArea area) {
    return switch (result) {
      VerifyResult.cleared => _ResultBanner(
          icon: Icons.check_circle_outline,
          title: 'PARKED IN ASSIGNED AREA',
          text:
              'Vehicle is in its assigned area (${area.id} · ${area.name}). No violation to report. This check was added to Recent Checks.',
          background: AppColors.successSoft,
          border: AppColors.success,
          color: AppColors.success,
        ),
      VerifyResult.mismatch => _ResultBanner(
          icon: Icons.warning_amber_rounded,
          title: 'PARKING AREA MISMATCH',
          text: _mismatchText(area),
          background: AppColors.warning,
          border: GuardColors.warningText,
          color: AppColors.sidebar,
        ),
      VerifyResult.noOpenEntry => _ResultBanner(
          icon: Icons.info_outline,
          title: 'NO OPEN ENTRY',
          text:
              'This vehicle has no open entry record. Record its entry first, or check that it was scanned in at the gate.',
          background: AppColors.action.withValues(alpha: 0.08),
          border: AppColors.action,
          color: AppColors.primary,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final check = _check;
    final result = check == null ? null : verifyParking(record, check);

    return Scaffold(
      appBar: GuardAppBar(
        title: 'Verify Parking',
        subtitle: check == null ? 'SELECT AREA' : 'AREA ${check.detectedArea.id}',
      ),
      body: SafeArea(
        child: ScreenBody(
          bottom: (check == null || result == null)
              ? _pickerActions()
              : _resultActions(result, check),
          children: [
            _VehicleCard(
              plate: record.plate,
              valid: record.isPassValid,
              statusLabel: record.passStatusLabel,
            ),
            const SizedBox(height: 14),
            if (check == null || result == null)
              _AreaPickerCard(
                areas: sampleParkingAreas,
                selectedId: _selectedId,
                onChanged: (id) => setState(() => _selectedId = id),
              )
            else ...[
              _LocationCard(record: record, check: check, result: result),
              const SizedBox(height: 14),
              _AreaRulesCard(record: record, area: check.detectedArea),
              const SizedBox(height: 14),
              _banner(result, check.detectedArea),
            ],
          ],
        ),
      ),
    );
  }
}

/// Step 1: the guard selects the campus area where the vehicle was found.
class _AreaPickerCard extends StatelessWidget {
  final List<ParkingArea> areas;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _AreaPickerCard({
    required this.areas,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'WHERE IS THE VEHICLE PARKED?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select the campus area where you found this vehicle. ',
            style: TextStyle(
                fontSize: 12.5, height: 1.35, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Detected area',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedId,
                hint: const Text('Select parking area'),
                menuMaxHeight: 360,
                items: [
                  for (final a in areas)
                    DropdownMenuItem<String>(
                      value: a.id,
                      child: Text(
                        '${a.id} · ${a.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final String plate;
  final bool valid;
  final String statusLabel;
  const _VehicleCard(
      {required this.plate, required this.valid, required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.action.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.directions_car_outlined,
                  color: AppColors.action),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CaptionLabel('VEHICLE'),
                  Text(plate, style: monoStyle.copyWith(fontSize: 22)),
                ],
              ),
            ),
            valid
                ? const StatusChip(label: 'PASS VALID', kind: StatusKind.success)
                : StatusChip(
                    label: statusLabel.toUpperCase(), kind: StatusKind.danger),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final GuardVehicle record;
  final ParkingCheck check;
  final VerifyResult result;

  const _LocationCard(
      {required this.record, required this.check, required this.result});

  @override
  Widget build(BuildContext context) {
    final assigned = record.assignedArea;
    final Color detectedBg = switch (result) {
      VerifyResult.cleared => AppColors.successSoft,
      VerifyResult.mismatch => AppColors.warningSoft,
      VerifyResult.noOpenEntry => AppColors.background,
    };
    final Color detectedCaption = switch (result) {
      VerifyResult.cleared => AppColors.success,
      VerifyResult.mismatch => GuardColors.warningText,
      VerifyResult.noOpenEntry => AppColors.textMuted,
    };

    return SectionCard(
      title: 'LOCATION CHECK',
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _InfoBox(
                    caption: 'ASSIGNED AREA',
                    value: assigned?.id ?? '-',
                    sub: assigned == null
                        ? 'No assigned area'
                        : (record.assignedSlot == null
                            ? assigned.name
                            : '${assigned.name} · Slot ${record.assignedSlot}'),
                    background: AppColors.action.withValues(alpha: 0.1),
                    captionColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoBox(
                    caption: 'DETECTED AREA',
                    value: check.detectedArea.id,
                    sub: check.detectedArea.name,
                    background: detectedBg,
                    captionColor: detectedCaption,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.edit_location_alt_outlined,
                  size: 15, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Area selected by guard · ${check.checkedAt}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String caption;
  final String value;
  final String sub;
  final Color background;
  final Color captionColor;

  const _InfoBox({
    required this.caption,
    required this.value,
    required this.sub,
    required this.background,
    required this.captionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CaptionLabel(caption, color: captionColor),
          const SizedBox(height: 8),
          Text(value,
              style: monoStyle.copyWith(
                  fontSize: 28, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(sub,
              style: const TextStyle(
                  fontSize: 11.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _AreaRulesCard extends StatelessWidget {
  final GuardVehicle record;
  final ParkingArea area;

  const _AreaRulesCard({required this.record, required this.area});

  @override
  Widget build(BuildContext context) {
    final allowedPasses = area.allowedPassTypes.isEmpty
        ? 'Emergency use only'
        : area.allowedPassTypes.map((t) => t.label).join(', ');
    final allowedHere = area.allowedPassTypes.contains(record.passType);

    return SectionCard(
      title: 'DETECTED AREA · ${area.id}',
      child: Column(
        children: [
          DetailRow('Area', area.name),
          DetailRow('Capacity', '${area.capacity} spaces'),
          DetailRow('Allowed passes', allowedPasses),
          DetailRow('Pass type', record.passType.label),
          DetailRow(
            'Pass type allowed here',
            allowedHere ? 'Yes' : 'No',
            valueStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: allowedHere ? AppColors.success : GuardColors.warningText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color background;
  final Color border;
  final Color color;

  const _ResultBanner({
    required this.icon,
    required this.title,
    required this.text,
    required this.background,
    required this.border,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          Text(text,
              style: TextStyle(fontSize: 13, height: 1.35, color: color)),
        ],
      ),
    );
  }
}