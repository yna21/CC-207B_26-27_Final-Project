import 'package:flutter/material.dart';
import 'package:websupark/screens/head_security/head_sample_data.dart';
import 'package:websupark/screens/head_security/head_widgets.dart';
import 'package:websupark/theme/app_colors.dart';

class CentralOverviewScreen extends StatelessWidget {
  const CentralOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Everything below is calculated from the sample lists.
    final total = sampleAreas.fold<int>(0, (sum, a) => sum + a.capacity);
    final occupied = sampleAreas.fold<int>(0, (sum, a) => sum + a.occupied);
    final double pct = total == 0 ? 0 : occupied / total;
    final inside = sampleVehicles.where((v) => v.inside).length;
    final outside = sampleVehicles.length - inside;
    final open = sampleViolations
        .where((v) => v.status != ViolationStatus.resolved)
        .toList();
    final yellowInside = sampleYellowPasses.where((p) => p.exit == null).length;
    final outsideOnSite = sampleOutsideVehicles
        .where((v) => v.exit == null)
        .length;

    return HeadPage(
      eyebrow: 'COMMAND CENTER · MAIN GATE',
      title: 'Central Overview',
      subtitle: 'Parking occupancy and field activity',
      children: [
        StatRow(
          cards: [
            StatCard(
              icon: Icons.local_parking,
              label: 'TOTAL SPACES',
              value: '$total',
              note: '${sampleAreas.length} areas',
            ),
            StatCard(
              icon: Icons.directions_car_outlined,
              label: 'OCCUPIED',
              value: '$occupied',
              note: '${(pct * 100).toStringAsFixed(1)}%',
              noteColor: AppColors.action,
            ),
            StatCard(
              icon: Icons.check_circle_outline,
              iconColor: AppColors.success,
              label: 'AVAILABLE',
              value: '${total - occupied}',
              note: '${((1 - pct) * 100).toStringAsFixed(1)}%',
              noteColor: AppColors.success,
            ),
            StatCard(
              icon: Icons.login,
              label: 'VEHICLES INSIDE',
              value: '$inside',
              note: 'registered',
            ),
            StatCard(
              icon: Icons.logout,
              iconColor: AppColors.textMuted,
              label: 'VEHICLES OUTSIDE',
              value: '$outside',
              note: 'registered',
            ),
            StatCard(
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.danger,
              label: 'VIOLATIONS',
              value: '${sampleViolations.length}',
              note: 'total',
              noteColor: AppColors.danger,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Panel(
                    title: 'Parking-area occupancy',
                    caption: '$occupied / $total spaces',
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.sidebar,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${(pct * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    UsageBar(
                                      ratio: pct,
                                      color: AppColors.action,
                                      background: Colors.white24,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '$occupied occupied · ${total - occupied} available',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (final a in sampleAreas)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${a.id} · ${a.name}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${a.occupied} / ${a.capacity} occupied · ${(a.ratio * 100).round()}%',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                UsageBar(
                                  ratio: a.ratio,
                                  color: occupancyColor(a.ratio),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Panel(
                    title: 'Real-time field feed',
                    caption: 'Guard activity',
                    child: Column(
                      children: [
                        for (final a in sampleActivities) ActivityTile(a),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Panel(
                    title: 'Urgent violations',
                    caption: '${open.length} require action',
                    child: open.isEmpty
                        ? const Text('No open violations.')
                        : Column(
                            children: [
                              for (final v in open.take(3))
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: violationColor(v.status)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: violationColor(v.status)
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              v.plate,
                                              style: monoStyle,
                                            ),
                                          ),
                                          StatusPill(
                                            label: violationLabel(v.status),
                                            color: violationColor(v.status),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        v.type,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        'Assigned ${v.assignedAreaId} → detected ${v.detectedAreaId} · ${v.reportedAt}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),
                  Panel(
                    title: 'Monitoring summary',
                    child: Column(
                      children: [
                        DetailRow(
                          'Yellow pass vehicles inside',
                          '$yellowInside',
                        ),
                        DetailRow('Outside vehicles on site', '$outsideOnSite'),
                        DetailRow('Open violations', '${open.length}'),
                        DetailRow('Vehicles currently inside', '$inside'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
