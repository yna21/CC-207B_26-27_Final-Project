import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:websupark/screens/guard/models/guard_case.dart';
import 'package:websupark/screens/guard/models/violation_type.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/theme/app_colors.dart';
import 'package:websupark/screens/guard/widgets/guard_colors.dart';
import 'package:websupark/screens/guard/widgets/guard_widgets.dart';
import 'package:websupark/widgets/status_chip.dart';

/// Opened from "View Incident Details" on the Report Submitted screen.
class IncidentDetailsScreen extends StatelessWidget {
  final GuardCase guardCase;

  const IncidentDetailsScreen({super.key, required this.guardCase});

  void _openPhoto(BuildContext context, Uint8List bytes) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(child: Image.memory(bytes)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = guardCase.record;
    final check = guardCase.check;
    final area = check.detectedArea;
    final allowedPasses = area.allowedPassTypes.isEmpty
        ? 'Emergency use only'
        : area.allowedPassTypes.map((t) => t.label).join(', ');
    final type = guardCase.violationType?.label ?? 'Parking violation';
    final notes = guardCase.notes;

    return Scaffold(
      appBar: GuardAppBar(
          title: 'Incident Details',
          subtitle: guardCase.incidentRef ?? 'INCIDENT'),
      body: SafeArea(
        child: ScreenBody(
          bottom: ElevatedButton.icon(
          onPressed: () => Navigator.of(context).popUntil((route) =>
              route.settings.name == AppRoutes.guardConsole || route.isFirst),
          icon: const Icon(Icons.shield_outlined, size: 20),
          label: const Text('Return to Patrol',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          style:
              ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        ),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warningSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: GuardColors.warningText.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                        color: AppColors.warning, shape: BoxShape.circle),
                    child: const Icon(Icons.flag_outlined,
                        color: AppColors.sidebar, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.plate,
                            style: monoStyle.copyWith(fontSize: 22)),
                        const SizedBox(height: 2),
                        Text(
                          '$type · ${area.id}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: GuardColors.warningText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const StatusChip(label: 'OPEN', kind: StatusKind.warning),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              title: 'INCIDENT',
              child: Column(
                children: [
                  DetailRow('Reference', guardCase.incidentRef ?? '-',
                      valueStyle: monoStyle.copyWith(fontSize: 13)),
                  const DetailRow('Status', 'Open · Follow-up pending',
                      valueStyle: TextStyle(
                          fontSize: 14, color: GuardColors.warningText)),
                  DetailRow('Violation type', type),
                  DetailRow('Offense number',
                      ordinal(guardCase.offenseNumber ?? 1)),
                  DetailRow('Observed', check.observedAt),
                  DetailRow('Synced',
                      'Command Center · ${guardCase.syncedAt ?? '-'}'),
                  const DetailRow('Reported by', 'Officer M. Reyes · Unit 12'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              title: 'VEHICLE',
              child: Column(
                children: [
                  DetailRow('Driver', record.driverName),
                  DetailRow('Vehicle', record.vehicleSummary),
                  DetailRow('Pass number', record.passNumber,
                      valueStyle: monoStyle.copyWith(fontSize: 14)),
                  DetailRow('Pass type', record.passType.label),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              title: 'LOCATION',
              child: Column(
                children: [
                  DetailRow('Assigned area', record.assignedAreaLabel,
                      valueStyle: monoStyle.copyWith(fontSize: 13)),
                  DetailRow('Found in', '${area.id} · ${area.name}',
                      valueStyle: monoStyle.copyWith(
                          fontSize: 13, color: GuardColors.warningText)),
                  DetailRow('Allowed passes', allowedPasses),
                  DetailRow('Reading',
                      '${check.beacon} · ${check.accuracyMeters} m · ${check.checkedAt}'),
                ],
              ),
            ),
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 14),
              SectionCard(
                title: 'GUARD NOTES',
                child: Text(notes,
                    style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.textPrimary)),
              ),
            ],
            const SizedBox(height: 14),
            SectionCard(
              title: 'EVIDENCE · ${guardCase.photos.length} '
                  'PHOTO${guardCase.photos.length == 1 ? '' : 'S'}',
              child: guardCase.photos.isEmpty
                  ? const Text('No photos attached.',
                      style: TextStyle(color: AppColors.textMuted))
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final bytes in guardCase.photos)
                          GestureDetector(
                            onTap: () => _openPhoto(context, bytes),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(bytes,
                                  width: 96, height: 96, fit: BoxFit.cover),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}