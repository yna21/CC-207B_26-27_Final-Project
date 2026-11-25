import 'package:flutter/material.dart';
import 'package:websupark/screens/guard/data/guard_log.dart';
import 'package:websupark/screens/guard/widgets/recent_check_tile.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/screens/guard/guard_routes.dart';
import 'package:websupark/theme/app_colors.dart';
import 'package:websupark/screens/guard/widgets/guard_widgets.dart';
import 'package:websupark/widgets/status_chip.dart';

class PatrolHomeScreen extends StatelessWidget {
  const PatrolHomeScreen({super.key, this.onViewAll});

  /// Called by "View all". GuardShell uses it to switch to the Checks tab.
  /// When null, Recent Checks opens as a separate page.
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GuardAppBar(
        title: 'Patrol Console',
        subtitle: 'WVSU MAIN CAMPUS',
        showBack: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ShiftCard(),
              const SizedBox(height: 20),
              _VerifyCard(
                onScan: () => Navigator.pushNamed(context, AppRoutes.guardScan),
              ),
              const SizedBox(height: 24),
              _RecentSection(onViewAll: onViewAll),
            ],
          ),
        ),
      ),
    );
  }
}

/// "RECENT CHECKS" header and the latest 5 checks.
class _RecentSection extends StatelessWidget {
  final VoidCallback? onViewAll;
  const _RecentSection({this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'RECENT CHECKS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: onViewAll ??
                  () => Navigator.pushNamed(context, guardRecentChecksRoute),
              child: const Text(
                'View all',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.action,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListenableBuilder(
          listenable: GuardLog.instance,
          builder: (context, _) {
            final checks = GuardLog.instance.checks.take(5).toList();
            if (checks.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No checks yet.',
                    style: TextStyle(color: AppColors.textMuted)),
              );
            }
            return Column(
              children: [
                for (final check in checks) ...[
                  RecentCheckTile(check: check),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Officer M. Reyes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Shift 07:00–15:00 · Unit 12',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusChip(label: 'ON PATROL', kind: StatusKind.success),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ListenableBuilder(
                listenable: GuardLog.instance,
                builder: (context, _) {
                  final n = GuardLog.instance.reportedCount;
                  return Text(
                    '$n violation${n == 1 ? '' : 's'} reported',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  );
                },
              ),
              const Text('3h 42m left',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerifyCard extends StatelessWidget {
  final VoidCallback onScan;
  const _VerifyCard({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.action.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.center_focus_strong_outlined,
                      color: AppColors.action),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verify a parked vehicle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Scan the windshield pass or enter its number.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Uses ElevatedButtonTheme (action blue, full width); only height overridden.
            ElevatedButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.crop_free, size: 20),
              label: const Text(
                'Scan Vehicle Pass',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}