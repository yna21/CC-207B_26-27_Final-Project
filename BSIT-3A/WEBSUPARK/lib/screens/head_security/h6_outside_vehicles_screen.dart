import 'package:flutter/material.dart';
import 'package:websupark/screens/head_security/head_sample_data.dart';
import 'package:websupark/screens/head_security/head_widgets.dart';
import 'package:websupark/theme/app_colors.dart';

class OutsideVehiclesScreen extends StatefulWidget {
  const OutsideVehiclesScreen({super.key});

  @override
  State<OutsideVehiclesScreen> createState() => _OutsideVehiclesScreenState();
}

class _OutsideVehiclesScreenState extends State<OutsideVehiclesScreen> {
  // A copy, so "Record exit" changes stay inside this screen.
  // TODO: replace with repository data and recordExit().
  late List<SampleOutsideVehicle> _vehicles;
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _vehicles = List<SampleOutsideVehicle>.from(sampleOutsideVehicles);
  }

  void _recordExit() {
    setState(() {
      _vehicles[_selected] = _vehicles[_selected].withExit(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final onSite = _vehicles.where((v) => v.exit == null).length;
    final sel = _vehicles[_selected];

    return HeadPage(
      eyebrow: 'TEMPORARY ACCESS · EXTERNAL VEHICLE REGISTER',
      title: 'Outside Vehicles',
      subtitle: 'Entry and exit activity for non-campus vehicles',
      children: [
        StatRow(
          cards: [
            StatCard(
              icon: Icons.local_shipping_outlined,
              label: 'CURRENTLY ON SITE',
              value: '$onSite',
              note: 'temporary vehicles',
            ),
            StatCard(
              icon: Icons.login,
              iconColor: AppColors.success,
              label: 'ENTERED TODAY',
              value: '${_vehicles.length}',
            ),
            StatCard(
              icon: Icons.logout,
              iconColor: AppColors.textMuted,
              label: 'EXITED TODAY',
              value: '${_vehicles.length - onSite}',
            ),
          ],
        ),
        const SizedBox(height: 16),
        const InfoBanner(
          icon: Icons.shield_outlined,
          color: AppColors.action,
          text: 'Outside or unregistered vehicles are monitored as temporary access records. They are not automatically classified as violations.',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool stackPanels = constraints.maxWidth < 900;

            final tablePanel = Panel(
              title: 'Entry and exit activity',
              caption: '${_vehicles.length} records today',
              child: LayoutBuilder(
                builder: (context, tableConstraints) {
                  final table = HeadTable(
                    columns: const [
                      HeadColumn('Vehicle / type', flex: 3),
                      HeadColumn('Purpose', flex: 3),
                      HeadColumn('Destination', flex: 3),
                      HeadColumn('Entry', flex: 2),
                      HeadColumn('Exit', flex: 2),
                      HeadColumn('Duration', flex: 2),
                      HeadColumn('Status', flex: 2),
                    ],
                    selectedIndex: _selected,
                    onRowTap: (i) => setState(() => _selected = i),
                    rows: [
                      for (final v in _vehicles)
                        [
                          TwoLineCell(v.plate, v.category, mono: true),
                          Text(v.purpose, style: const TextStyle(fontSize: 13)),
                          Text(
                            v.destination,
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            formatTime(v.entry),
                            style: const TextStyle(fontSize: 12.5),
                          ),
                          Text(
                            v.exit == null ? '-' : formatTime(v.exit!),
                            style: const TextStyle(fontSize: 12.5),
                          ),
                          Text(formatDuration(v.duration), style: monoStyle),
                          v.exit == null
                              ? const StatusPill(
                                  label: 'On site',
                                  color: AppColors.action,
                                )
                              : const StatusPill(
                                  label: 'Exited',
                                  color: AppColors.textMuted,
                                ),
                        ],
                    ],
                  );

                  if (tableConstraints.maxWidth < 760) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(width: 760, child: table),
                    );
                  }

                  return table;
                },
              ),
            );

            final detailsColumn = Column(
              children: [
                Panel(
                  title: 'Selected temporary record',
                  caption: sel.exit == null ? 'Monitored' : 'Exited',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const IconTile(icon: Icons.local_shipping_outlined),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TwoLineCell(
                              sel.plate,
                              sel.category,
                              mono: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DetailRow('Purpose', sel.purpose),
                      DetailRow('Destination', sel.destination),
                      DetailRow('Entry', formatTime(sel.entry)),
                      DetailRow('Duration', formatDuration(sel.duration)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: sel.exit == null ? _recordExit : null,
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Record exit'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Panel(
                  title: 'Live activity',
                  child: HeadTimeline(
                    entries: [
                      TimelineEntry(
                        'Entry recorded',
                        sel.destination,
                        formatTime(sel.entry),
                      ),
                      sel.exit == null
                          ? const TimelineEntry(
                              'Still on site',
                              'Standard monitoring until exit',
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
                const SizedBox(height: 16),
                const InfoBanner(
                  icon: Icons.info_outline,
                  color: AppColors.warning,
                  text:
                      'If the destination or purpose cannot be verified, '
                      'request a field check. Do not create a violation '
                      'automatically.',
                ),
              ],
            );

            if (stackPanels) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  tablePanel,
                  const SizedBox(height: 16),
                  detailsColumn,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: tablePanel),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: detailsColumn),
              ],
            );
          },
        ),
      ],
    );
  }
}
