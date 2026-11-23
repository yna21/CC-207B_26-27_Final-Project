import 'package:flutter/material.dart';
import 'package:websupark/screens/guard/models/vehicle_check.dart';
import 'package:websupark/screens/guard/widgets/guard_colors.dart';
import 'package:websupark/screens/guard/widgets/guard_widgets.dart';
import 'package:websupark/theme/app_colors.dart';
import 'package:websupark/widgets/status_chip.dart';

/// One row of the "Recent checks" list (Patrol Home and Recent Checks).
class RecentCheckTile extends StatelessWidget {
  final VehicleCheck check;

  const RecentCheckTile({super.key, required this.check});

  @override
  Widget build(BuildContext context) {
    final Color soft;
    final Color strong;
    final IconData icon;
    final StatusChip chip;

    switch (check.status) {
      case CheckStatus.cleared:
        soft = AppColors.successSoft;
        strong = AppColors.success;
        icon = Icons.directions_car_outlined;
        chip = const StatusChip(label: 'CLEARED', kind: StatusKind.success);
      case CheckStatus.mismatch:
        soft = AppColors.warningSoft;
        strong = GuardColors.warningText;
        icon = Icons.warning_amber_rounded;
        chip = const StatusChip(label: 'MISMATCH', kind: StatusKind.warning);
      case CheckStatus.reported:
        soft = AppColors.dangerSoft;
        strong = AppColors.danger;
        icon = Icons.flag_outlined;
        chip = const StatusChip(label: 'REPORTED', kind: StatusKind.danger);
      case CheckStatus.noEntry:
        soft = AppColors.action.withValues(alpha: 0.12);
        strong = AppColors.primary;
        icon = Icons.login;
        chip = const StatusChip(label: 'NO ENTRY', kind: StatusKind.neutral);
    }

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: soft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: strong, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(check.plate, style: monoStyle.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    '${check.time} · ${check.location}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                  if (check.driverName != null)
                    Text(
                      '${check.driverName} · ${check.passTypeLabel ?? ''}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  if (check.incidentRef != null)
                    Text(
                      check.incidentRef!,
                      style: monoStyle.copyWith(
                          fontSize: 10.5, color: AppColors.danger),
                    ),
                ],
              ),
            ),
            chip,
          ],
        ),
      ),
    );
  }
}