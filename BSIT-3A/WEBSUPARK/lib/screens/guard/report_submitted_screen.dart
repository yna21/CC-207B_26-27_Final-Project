import 'package:flutter/material.dart';
import 'package:websupark/screens/guard/models/guard_case.dart';
import 'package:websupark/screens/guard/guard_vehicle.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/screens/guard/incident_details_screen.dart';
import 'package:websupark/theme/app_colors.dart';
import 'package:websupark/screens/guard/widgets/guard_colors.dart';
import 'package:websupark/screens/guard/widgets/guard_widgets.dart';
import 'package:websupark/screens/guard/widgets/guard_page.dart';

class ReportSubmittedScreen extends StatelessWidget {
  final GuardCase guardCase;

  const ReportSubmittedScreen({super.key, required this.guardCase});

  GuardVehicle get record => guardCase.record;
  String get incidentRef => guardCase.incidentRef ?? '-';
  String get syncedAt => guardCase.syncedAt ?? '-';

  // Goes back to the Patrol Console (S1) and clears the report flow.
  void _returnToPatrol(BuildContext context) =>
      Navigator.of(context).popUntil((route) =>
          route.settings.name == AppRoutes.guardConsole || route.isFirst);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GuardAppBar(
        title: 'Report Submitted',
        subtitle: 'INCIDENT LOGGED',
        showBack: false,
      ),
      body: SafeArea(
        child: ScreenBody(
          bottom: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () => _returnToPatrol(context),
              icon: const Icon(Icons.shield_outlined, size: 20),
              label: const Text('Return to Patrol',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56)),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      GuardPage(child: IncidentDetailsScreen(guardCase: guardCase)),
                ),
              ),
              icon: const Icon(Icons.description_outlined, size: 20),
              label: const Text('View Incident Details',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
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
        ),
          children: [
            Center(
              child: Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.2),
                ),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                      color: GuardColors.successDark, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 36),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '● SUCCESSFULLY SUBMITTED',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: AppColors.success,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Violation recorded',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${guardCase.violationType?.label ?? 'Parking'} violation for vehicle ${record.plate} '
              'has been added to the active incident queue.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13.5, height: 1.4, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text(
                    'INCIDENT REFERENCE',
                    style: TextStyle(
                      fontSize: 10.5,
                      letterSpacing: 0.6,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    incidentRef,
                    style: monoStyle.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_done_outlined,
                          size: 14, color: Color(0xFF7FD8A8)),
                      const SizedBox(width: 6),
                      Text(
                        'Synced to Command Center · $syncedAt',
                        style: const TextStyle(
                            fontSize: 11.5, color: Color(0xFF7FD8A8)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const SectionCard(
              title: 'WHAT HAPPENS NEXT',
              child: Column(
                children: [
                  _NextStepRow(
                    icon: Icons.task_outlined,
                    title: 'Incident saved',
                    subtitle: 'Vehicle record and evidence attached',
                    done: true,
                  ),
                  SizedBox(height: 12),
                  _NextStepRow(
                    icon: Icons.sensors,
                    title: 'Dispatch notified',
                    subtitle: 'Sector supervisor received the alert',
                    done: true,
                  ),
                  SizedBox(height: 12),
                  _NextStepRow(
                    icon: Icons.schedule,
                    title: 'Follow-up pending',
                    subtitle: 'Continue patrol; no on-site hold required',
                    done: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.action.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.alt_route, color: AppColors.action, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NEXT ACTION',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Resume patrol of the main campus.',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
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

class _NextStepRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool done;

  const _NextStepRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: done ? AppColors.successSoft : AppColors.background,
            shape: BoxShape.circle,
          ),
          child: Icon(icon,
              size: 20, color: done ? AppColors.success : AppColors.textMuted),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11.5, color: AppColors.textMuted)),
            ],
          ),
        ),
        if (done) const Icon(Icons.check, size: 20, color: AppColors.success),
      ],
    );
  }
}