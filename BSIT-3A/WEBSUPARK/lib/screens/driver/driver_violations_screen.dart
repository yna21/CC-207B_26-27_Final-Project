import 'package:flutter/material.dart';
import 'package:websupark/screens/driver/driver_common.dart';
import 'package:websupark/theme/app_colors.dart';
import 'package:websupark/widgets/status_chip.dart';

// ---------------------------------------------------------------------------
// SAMPLE DATA (layout only)
// TODO: replace with repository data
// ---------------------------------------------------------------------------
const String _schoolYear = '2026-2027'; // TODO: replace with repository data

class _Violation {
  const _Violation({
    required this.date,
    required this.title,
    required this.location,
    required this.reference,
    required this.isResolved,
  });

  final String date;
  final String title;
  final String location;
  final String reference;
  final bool isResolved;
}

// TODO: replace with repository data
const List<_Violation> _violations = [
  _Violation(
    date: 'Sept. 28',
    title: 'Wrong Parking Area',
    location: 'B-014',
    reference: 'PV-0928-14',
    isResolved: false,
  ),
  _Violation(
    date: 'Sept. 10',
    title: 'Wrong Parking Area',
    location: 'C-021',
    reference: 'PV-0910-07',
    isResolved: true,
  ),
];

/// D4 My Violations: summary counts, violation history and a help note.
class DriverViolationsScreen extends StatelessWidget {
  const DriverViolationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DriverPage(
      children: [
        const DriverHeader(
          title: 'My Violations',
          subtitle: 'Review your parking history',
          icon: Icons.help_outline,
        ),
        const SizedBox(height: 16),
        // Two columns on a wide screen, one column (same order) on a phone.
        DriverColumns(
          leftFlex: 2,
          rightFlex: 3,
          left: const [_SummaryCard()],
          right: [
            const DriverSectionHeader(
              title: 'Violation History',
              action: _schoolYear,
            ),
            const SizedBox(height: 10),
            for (final violation in _violations)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ViolationCard(violation: violation),
              ),
            const SizedBox(height: 2),
            const _ClarifyNote(),
          ],
        ),
      ],
    );
  }
}

/// Dark blue card with total / pending / resolved counts.
/// The counts are calculated from the list, never typed by hand.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    final total = _violations.length;
    final resolved = _violations.where((v) => v.isResolved).length;
    final pending = total - resolved;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryStat(
              value: '$total',
              label: 'TOTAL RECORDS',
              valueColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryStat(
              value: '$pending',
              label: 'PENDING',
              valueColor: AppColors.warningSoft,
              boxed: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryStat(
              value: '$resolved',
              label: 'RESOLVED',
              valueColor: AppColors.successSoft,
              boxed: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.value,
    required this.label,
    required this.valueColor,
    this.boxed = false,
  });

  final String value;
  final String label;
  final Color valueColor;
  final bool boxed; // true = translucent box behind the number

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: boxed
          ? BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            )
          : null,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: 0.6,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

/// One violation record with a Pending / Resolved chip.
class _ViolationCard extends StatelessWidget {
  const _ViolationCard({required this.violation});

  final _Violation violation;

  @override
  Widget build(BuildContext context) {
    final resolved = violation.isResolved;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                DriverIconBox(
                  icon: Icons.warning_amber_rounded,
                  iconColor: resolved ? AppColors.success : AppColors.warning,
                  backgroundColor:
                      resolved ? AppColors.successSoft : AppColors.warningSoft,
                  size: 38,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        violation.date,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        violation.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  label: resolved ? 'RESOLVED' : 'PENDING',
                  kind: resolved ? StatusKind.success : StatusKind.warning,
                ),
              ],
            ),
            const Divider(height: 24, color: AppColors.border),
            Row(
              children: [
                Expanded(
                  child: _Detail(
                    label: 'Parking location',
                    value: violation.location,
                  ),
                ),
                Expanded(
                  child: _Detail(
                    label: 'Reference',
                    value: violation.reference,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Pale blue note at the bottom: what to do to clarify a record.
class _ClarifyNote extends StatelessWidget {
  const _ClarifyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need to clarify a record?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Visit the Parking Services Office within 5 working days and bring your vehicle pass.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
