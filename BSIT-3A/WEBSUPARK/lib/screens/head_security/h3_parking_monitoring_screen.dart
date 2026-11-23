import 'package:flutter/material.dart';
import 'package:websupark/screens/head_security/head_sample_data.dart';
import 'package:websupark/screens/head_security/head_widgets.dart';
import 'package:websupark/theme/app_colors.dart';

class ParkingMonitoringScreen extends StatefulWidget {
  const ParkingMonitoringScreen({super.key});

  @override
  State<ParkingMonitoringScreen> createState() =>
      _ParkingMonitoringScreenState();
}

class _ParkingMonitoringScreenState extends State<ParkingMonitoringScreen> {
  int _areaIndex = 0;

  // TODO: sample plates for the slot grid. Replace with EntryExitRecord data.
  static const _plates = [
    'HGC 205',
    'KJH 482',
    'DPL 449',
    'TRX 018',
    'MNR 210',
    'UTS 708',
    'GHT 061',
    'PLK 402',
    'ZBR 734',
    'RPK 732',
    'WCN 988',
    'SVL 230',
  ];

  Widget _slot({
    required String label,
    required bool occupied,
    required String plate,
    required bool mismatch,
  }) {
    final dark = occupied && !mismatch;
    final bg = mismatch
        ? AppColors.warning
        : occupied
        ? AppColors.sidebar
        : AppColors.surface;
    return Container(
      width: 96,
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: occupied ? bg : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: dark ? Colors.white70 : AppColors.textMuted,
            ),
          ),
          Text(
            occupied ? plate : 'AVAILABLE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: dark
                  ? Colors.white
                  : occupied
                  ? AppColors.textPrimary
                  : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final area = sampleAreas[_areaIndex];
    final total = sampleAreas.fold<int>(0, (sum, a) => sum + a.capacity);
    final occupied = sampleAreas.fold<int>(0, (sum, a) => sum + a.occupied);
    final exceptions = sampleViolations
        .where((v) => v.status != ViolationStatus.resolved)
        .length;

    // Open violations where the vehicle was detected in the chosen area.
    final mismatches = sampleViolations
        .where(
          (v) =>
              v.detectedAreaId == area.id &&
              v.status != ViolationStatus.resolved,
        )
        .toList();

    // The grid shows at most 24 slots of the area.
    final shown = area.capacity < 24 ? area.capacity : 24;
    final occupiedShown = (area.ratio * shown).round();

    return HeadPage(
      eyebrow: 'FACILITY INTELLIGENCE · PARKING AREAS',
      title: 'Parking Monitoring',
      subtitle: 'Space occupancy and vehicle locations',
      children: [
        StatRow(
          cards: [
            StatCard(
              icon: Icons.directions_car_outlined,
              label: 'OCCUPIED SPACES',
              value: '$occupied',
              note: '${(occupied / total * 100).toStringAsFixed(1)}%',
              noteColor: AppColors.action,
            ),
            StatCard(
              icon: Icons.local_parking,
              iconColor: AppColors.success,
              label: 'AVAILABLE SPACES',
              value: '${total - occupied}',
              note: 'across ${sampleAreas.length} areas',
              noteColor: AppColors.success,
            ),
            StatCard(
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.warning,
              label: 'LOCATION EXCEPTIONS',
              value: '$exceptions',
              note: 'open',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < sampleAreas.length; i++)
              ChoiceChip(
                label: Text('${sampleAreas[i].id} · ${sampleAreas[i].name}'),
                selected: i == _areaIndex,
                onSelected: (_) => setState(() => _areaIndex = i),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Panel(
                title: '${area.id} · ${area.name}',
                caption: '${area.available} of ${area.capacity} available',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.square_outlined,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(width: 4),
                        Text('Available', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 16),
                        Icon(Icons.square, size: 14, color: AppColors.sidebar),
                        SizedBox(width: 4),
                        Text('Occupied', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 16),
                        Icon(Icons.square, size: 14, color: AppColors.warning),
                        SizedBox(width: 4),
                        Text('Mismatch', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var i = 0; i < shown; i++)
                          _slot(
                            label:
                                '${area.id}-${(i + 1).toString().padLeft(2, '0')}',
                            occupied: i < occupiedShown,
                            plate: i < mismatches.length
                                ? mismatches[i].plate
                                : _plates[i % _plates.length],
                            mismatch:
                                i < occupiedShown && i < mismatches.length,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Slot positions are simulated. Parking location detection is simulated in the browser.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    for (final v in mismatches)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: InfoBanner(
                          icon: Icons.warning_amber_rounded,
                          color: AppColors.warning,
                          title: '${v.plate} · ASSIGNMENT MISMATCH',
                          text:
                              'Assigned ${v.assignedAreaId} · Detected ${v.detectedAreaId} · reported by ${v.reportedBy}',
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Panel(
                    title: 'Zone capacity',
                    caption: 'Tap an area',
                    child: Column(
                      children: [
                        for (var i = 0; i < sampleAreas.length; i++)
                          InkWell(
                            onTap: () => setState(() => _areaIndex = i),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${sampleAreas[i].id} · ${sampleAreas[i].name}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: i == _areaIndex
                                                ? AppColors.action
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${sampleAreas[i].occupied} / ${sampleAreas[i].capacity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  UsageBar(
                                    ratio: sampleAreas[i].ratio,
                                    color: occupancyColor(sampleAreas[i].ratio),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${(sampleAreas[i].ratio * 100).round()}% occupied',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      Text(
                                        '${sampleAreas[i].available} available',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Panel(
                    title: 'Entry / exit activity',
                    child: Column(
                      children: [
                        for (final a in sampleActivities.where(
                          (a) =>
                              a.kind == ActivityKind.entry ||
                              a.kind == ActivityKind.exit ||
                              a.kind == ActivityKind.mismatch,
                        ))
                          ActivityTile(a),
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
