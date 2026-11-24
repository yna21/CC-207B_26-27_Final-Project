import 'package:flutter/material.dart';
import 'package:websupark/screens/guard/data/guard_log.dart';
import 'package:websupark/screens/guard/incident_details_screen.dart';
import 'package:websupark/screens/guard/models/guard_case.dart';
import 'package:websupark/screens/guard/models/vehicle_check.dart';
import 'package:websupark/screens/guard/widgets/guard_colors.dart';
import 'package:websupark/screens/guard/widgets/guard_page.dart';
import 'package:websupark/screens/guard/widgets/guard_widgets.dart';
import 'package:websupark/theme/app_colors.dart';
import 'package:websupark/widgets/status_chip.dart';

/// Opens the details of a card in "Recent checks":
///  - a reported check with its saved report -> the full Incident Details
///  - any other check                        -> Check Details
void openCheckDetails(BuildContext context, VehicleCheck check) {
  final guardCase = GuardLog.instance.caseFor(check.id);

  final Widget page = (check.status == CheckStatus.reported &&
          guardCase != null &&
          guardCase.incidentRef != null)
      ? IncidentDetailsScreen(guardCase: guardCase)
      : CheckDetailsScreen(check: check, guardCase: guardCase);

  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => GuardPage(child: page),
    ),
  );
}

/// Everything known about one check. Starting sample checks have no vehicle
/// record behind them, so they only show what the list itself holds.
class CheckDetailsScreen extends StatelessWidget {
  final VehicleCheck check;
  final GuardCase? guardCase;

  const CheckDetailsScreen({super.key, required this.check, this.guardCase});

  (String, StatusKind) get _status => switch (check.status) {
        CheckStatus.cleared => ('CLEARED', StatusKind.success),
        CheckStatus.mismatch => ('MISMATCH', StatusKind.warning),
        CheckStatus.reported => ('REPORTED', StatusKind.danger),
        CheckStatus.noEntry => ('NO ENTRY', StatusKind.neutral),
      };

  String get _result => switch (check.status) {
        CheckStatus.cleared => 'Cleared · parked in an allowed area',
        CheckStatus.mismatch => 'Mismatch · not reported',
        CheckStatus.reported => 'Violation reported',
        CheckStatus.noEntry => 'No open entry record',
      };

  @override
  Widget build(BuildContext context) {
    final record = guardCase?.record;
    final reading = guardCase?.check;
    final (chipLabel, chipKind) = _status;

    return Scaffold(
      appBar: GuardAppBar(title: 'Check Details', subtitle: check.plate),
      body: SafeArea(
        child: ScreenBody(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(check.plate,
                      style: monoStyle.copyWith(fontSize: 24)),
                ),
                StatusChip(label: chipLabel, kind: chipKind),
              ],
            ),
            const SizedBox(height: 14),
            SectionCard(
              title: 'CHECK',
              child: Column(
                children: [
                  DetailRow('Result', _result),
                  DetailRow('Time', check.time),
                  DetailRow('Location', check.location),
                  DetailRow('Incident reference', check.incidentRef ?? 'None',
                      valueStyle: monoStyle.copyWith(
                          fontSize: 13,
                          color: check.incidentRef != null
                              ? AppColors.danger
                              : AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              title: 'VEHICLE',
              child: Column(
                children: [
                  DetailRow('Driver',
                      record?.driverName ?? check.driverName ?? '-'),
                  if (record != null) DetailRow('Vehicle', record.vehicleSummary),
                  if (record != null)
                    DetailRow('Pass number', record.passNumber,
                        valueStyle: monoStyle.copyWith(fontSize: 14)),
                  DetailRow('Pass type',
                      record?.passType.label ?? check.passTypeLabel ?? '-'),
                ],
              ),
            ),
            if (record != null && reading != null) ...[
              const SizedBox(height: 14),
              SectionCard(
                title: 'LOCATION',
                child: Column(
                  children: [
                    DetailRow('Assigned area', record.assignedAreaLabel,
                        valueStyle: monoStyle.copyWith(fontSize: 13)),
                    DetailRow('Found in',
                        '${reading.detectedArea.id} · ${reading.detectedArea.name}',
                        valueStyle: monoStyle.copyWith(
                            fontSize: 13,
                            color: check.status == CheckStatus.cleared
                                ? AppColors.success
                                : GuardColors.warningText)),
                    DetailRow('Reading',
                        '${reading.beacon} · ${reading.accuracyMeters} m · ${reading.checkedAt}'),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 14),
              const Text(
                'Only the summary of this check is available.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}