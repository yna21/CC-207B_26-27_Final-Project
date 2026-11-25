import 'package:flutter/material.dart';
import 'package:websupark/screens/head_security/head_sample_data.dart';
import 'package:websupark/screens/head_security/head_widgets.dart';
import 'package:websupark/theme/app_colors.dart';

class YellowPassScreen extends StatefulWidget {
  const YellowPassScreen({super.key});

  @override
  State<YellowPassScreen> createState() => _YellowPassScreenState();
}

class _YellowPassScreenState extends State<YellowPassScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final passes = sampleYellowPasses;
    final inside = passes.where((p) => p.exit == null).length;
    final longest = passes.isEmpty
        ? Duration.zero
        : passes.map((p) => p.duration).reduce((a, b) => a > b ? a : b);
    final sel = passes[_selected];

    return HeadPage(
      eyebrow: 'TEMPORARY ACCESS · YELLOW PASS',
      title: 'Yellow Pass Monitoring',
      subtitle: 'Entry and exit duration of Yellow pass vehicles',
      children: [
        StatRow(
          cards: [
            StatCard(
              icon: Icons.confirmation_number_outlined,
              iconColor: AppColors.warning,
              label: 'ACTIVE YELLOW PASSES',
              value: '$inside',
              note: 'inside campus',
            ),
            StatCard(
              icon: Icons.logout,
              iconColor: AppColors.success,
              label: 'EXITED',
              value: '${passes.length - inside}',
            ),
            StatCard(
              icon: Icons.timer_outlined,
              label: 'LONGEST STAY',
              value: formatDuration(longest),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const InfoBanner(
          icon: Icons.info_outline,
          color: AppColors.warning,
          text: 'Duration is calculated from the entry and exit scans. No time limit is enforced, so a long stay is not a violation.',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 900) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Panel(
                    title: 'Yellow pass records',
                    caption: '$inside active · ${passes.length} total',
                    child: LayoutBuilder(
                      builder: (context, tableConstraints) {
                        final tableWidth = tableConstraints.maxWidth < 760
                            ? 760.0
                            : tableConstraints.maxWidth;

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: tableWidth,
                            child: HeadTable(
                              columns: const [
                                HeadColumn('Vehicle / pass', flex: 3),
                                HeadColumn('Purpose', flex: 3),
                                HeadColumn('Entry', flex: 2),
                                HeadColumn('Exit', flex: 2),
                                HeadColumn('Duration', flex: 2),
                                HeadColumn('Status', flex: 2),
                              ],
                              selectedIndex: _selected,
                              onRowTap: (i) => setState(() => _selected = i),
                              rows: [
                                for (final p in passes)
                                  [
                                    TwoLineCell(
                                      p.plate,
                                      'Pass ${p.passNumber}',
                                      mono: true,
                                    ),
                                    Text(
                                      p.purpose,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    Text(
                                      formatTime(p.entry),
                                      style: const TextStyle(fontSize: 12.5),
                                    ),
                                    Text(
                                      p.exit == null
                                          ? '-'
                                          : formatTime(p.exit!),
                                      style: const TextStyle(fontSize: 12.5),
                                    ),
                                    Text(
                                      formatDuration(p.duration),
                                      style: monoStyle,
                                    ),
                                    p.exit == null
                                        ? const StatusPill(
                                            label: 'Inside',
                                            color: AppColors.warning,
                                          )
                                        : const StatusPill(
                                            label: 'Exited',
                                            color: AppColors.success,
                                          ),
                                  ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Panel(
                        title: 'Selected yellow pass',
                        caption: 'Pass ${sel.passNumber}',
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.warning,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'YP',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  sel.plate,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            DetailRow('Purpose', sel.purpose),
                            DetailRow('Entry', formatTime(sel.entry)),
                            DetailRow(
                              'Exit',
                              sel.exit == null
                                  ? 'Not yet'
                                  : formatTime(sel.exit!),
                            ),
                            DetailRow('Duration', formatDuration(sel.duration)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Panel(
                        title: 'Entry to exit timeline',
                        child: HeadTimeline(
                          entries: [
                            TimelineEntry(
                              'Entry recorded',
                              'Pass ${sel.passNumber}',
                              formatTime(sel.entry),
                            ),
                            sel.exit == null
                                ? const TimelineEntry(
                                    'Exit not yet recorded',
                                    'Timeline closes when the guard records the exit',
                                    '-',
                                    state: TimelineState.pending,
                                  )
                                : TimelineEntry(
                                    'Exit recorded',
                                    '',
                                    formatTime(sel.exit!),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Panel(
                    title: 'Yellow pass records',
                    caption: '$inside active · ${passes.length} total',
                    child: LayoutBuilder(
                      builder: (context, tableConstraints) {
                        final tableWidth = tableConstraints.maxWidth < 760
                            ? 760.0
                            : tableConstraints.maxWidth;

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: tableWidth,
                            child: HeadTable(
                              columns: const [
                                HeadColumn('Vehicle / pass', flex: 3),
                                HeadColumn('Purpose', flex: 3),
                                HeadColumn('Entry', flex: 2),
                                HeadColumn('Exit', flex: 2),
                                HeadColumn('Duration', flex: 2),
                                HeadColumn('Status', flex: 2),
                              ],
                              selectedIndex: _selected,
                              onRowTap: (i) => setState(() => _selected = i),
                              rows: [
                                for (final p in passes)
                                  [
                                    TwoLineCell(
                                      p.plate,
                                      'Pass ${p.passNumber}',
                                      mono: true,
                                    ),
                                    Text(
                                      p.purpose,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    Text(
                                      formatTime(p.entry),
                                      style: const TextStyle(fontSize: 12.5),
                                    ),
                                    Text(
                                      p.exit == null
                                          ? '-'
                                          : formatTime(p.exit!),
                                      style: const TextStyle(fontSize: 12.5),
                                    ),
                                    Text(
                                      formatDuration(p.duration),
                                      style: monoStyle,
                                    ),
                                    p.exit == null
                                        ? const StatusPill(
                                            label: 'Inside',
                                            color: AppColors.warning,
                                          )
                                        : const StatusPill(
                                            label: 'Exited',
                                            color: AppColors.success,
                                          ),
                                  ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Panel(
                        title: 'Selected yellow pass',
                        caption: 'Pass ${sel.passNumber}',
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.warning,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'YP',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  sel.plate,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            DetailRow('Purpose', sel.purpose),
                            DetailRow('Entry', formatTime(sel.entry)),
                            DetailRow(
                              'Exit',
                              sel.exit == null
                                  ? 'Not yet'
                                  : formatTime(sel.exit!),
                            ),
                            DetailRow('Duration', formatDuration(sel.duration)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Panel(
                        title: 'Entry to exit timeline',
                        child: HeadTimeline(
                          entries: [
                            TimelineEntry(
                              'Entry recorded',
                              'Pass ${sel.passNumber}',
                              formatTime(sel.entry),
                            ),
                            sel.exit == null
                                ? const TimelineEntry(
                                    'Exit not yet recorded',
                                    'Timeline closes when the guard records the exit',
                                    '-',
                                    state: TimelineState.pending,
                                  )
                                : TimelineEntry(
                                    'Exit recorded',
                                    '',
                                    formatTime(sel.exit!),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
