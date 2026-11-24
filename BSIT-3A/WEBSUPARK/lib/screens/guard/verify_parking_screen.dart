import 'package:flutter/material.dart';
import 'package:websupark/screens/guard/data/guard_log.dart';
import 'package:websupark/screens/guard/models/guard_case.dart';
import 'package:websupark/models/parking_area.dart';
import 'package:websupark/screens/guard/models/parking_check.dart';
import 'package:websupark/screens/guard/models/vehicle_check.dart';
import 'package:websupark/screens/guard/guard_vehicle.dart';
import 'package:websupark/screens/guard/models/verify_result.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/theme/app_colors.dart';
import 'package:websupark/screens/guard/widgets/guard_colors.dart';
import 'package:websupark/screens/guard/widgets/guard_widgets.dart';
import 'package:websupark/widgets/status_chip.dart';

class VerifyParkingScreen extends StatefulWidget {
  final GuardCase guardCase;

  const VerifyParkingScreen({super.key, required this.guardCase});

  @override
  State<VerifyParkingScreen> createState() => _VerifyParkingScreenState();
}

class _VerifyParkingScreenState extends State<VerifyParkingScreen> {
  late final String _checkId;

  GuardCase get guardCase => widget.guardCase;
  GuardVehicle get record => guardCase.record;
  ParkingCheck get check => guardCase.check;
  ParkingArea get area => check.detectedArea;

  VerifyResult get _result => verifyParking(record, check);

  @override
  void initState() {
    super.initState();
    // Every vehicle that is verified is added to "Recent checks".
    _checkId = guardCase.checkId ??
        GuardLog.instance.recordCheck(
          plate: record.plate,
          location: '${area.id} · ${area.name}',
          status: switch (_result) {
            VerifyResult.cleared => CheckStatus.cleared,
            VerifyResult.mismatch => CheckStatus.mismatch,
            VerifyResult.noOpenEntry => CheckStatus.noEntry,
          },
          driverName: record.driverName,
          passTypeLabel: record.passType.label,
        );

    // Keep the full case so the card in "Recent checks" can open its details.
    GuardLog.instance.saveCase(guardCase.copyWith(checkId: _checkId));
  }

  void _backToPatrol() => Navigator.of(context).popUntil((route) =>
      route.settings.name == AppRoutes.guardConsole || route.isFirst);

  String get _mismatchText {
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

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      appBar: GuardAppBar(
        title: 'Verify Parking',
        subtitle: 'AREA ${area.id}',
      ),
      body: SafeArea(
        child: ScreenBody(
          bottom: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: switch (result) {
                      VerifyResult.cleared => ElevatedButton.icon(
                          onPressed: _backToPatrol,
                          icon: const Icon(Icons.shield_outlined),
                          label: const Text('Back to Patrol',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56)),
                        ),
                      VerifyResult.mismatch => ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.guardReportViolation,
                            arguments: guardCase.copyWith(checkId: _checkId),
                          ),
                          icon: const Icon(Icons.report_gmailerrorred_outlined),
                          label: const Text('Report Violation',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            minimumSize: const Size.fromHeight(56),
                          ),
                        ),
                      VerifyResult.noOpenEntry => ElevatedButton.icon(
                          onPressed: () {
                            // TODO: repository.recordEntry(vehicleId)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Entry recorded for ${record.plate}')),
                            );
                          },
                          icon: const Icon(Icons.login),
                          label: const Text('Record Entry',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56)),
                        ),
                    },
                  ),
                ],
              ),
              if (result != VerifyResult.cleared) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _backToPatrol,
                  icon: const Icon(Icons.shield_outlined, size: 20),
                  label: const Text('Back to Patrol',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
          children: [
            _VehicleCard(
              plate: record.plate,
              valid: record.isPassValid,
              statusLabel: record.passStatusLabel,
            ),
            const SizedBox(height: 14),
            _LocationCard(record: record, check: check, result: result),
            const SizedBox(height: 14),
            _AreaRulesCard(record: record, area: area),
            const SizedBox(height: 14),
            switch (result) {
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
                  text: _mismatchText,
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
            },
          ],
        ),
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
              const Icon(Icons.navigation_outlined,
                  size: 15, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${check.beacon} · ${check.accuracyMeters} m accuracy · ${check.checkedAt}',
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