import 'package:flutter/material.dart';
import 'package:websupark/screens/head_security/head_sample_data.dart';
import 'package:websupark/screens/head_security/head_widgets.dart';
import 'package:websupark/theme/app_colors.dart';

class ViolationManagementScreen extends StatefulWidget {
  const ViolationManagementScreen({super.key});

  @override
  State<ViolationManagementScreen> createState() =>
      _ViolationManagementScreenState();
}

class _ViolationManagementScreenState extends State<ViolationManagementScreen> {
  final ScrollController _tableController = ScrollController();

  // A copy, so changes stay inside this screen.
  // TODO: replace with getAllViolations() and an update call.

  late List<SampleViolation> _violations;
  String? _selectedId;
  String _query = '';
  ViolationStatus? _statusFilter; // null means "Status: All"

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _violations = List<SampleViolation>.from(sampleViolations);
    _selectedId = _violations.first.incidentNumber;
  }

  int _count(ViolationStatus s) =>
      _violations.where((v) => v.status == s).length;

  List<SampleViolation> get _filtered {
    final q = _query.trim().toLowerCase();
    return _violations.where((v) {
      final matchesText =
          q.isEmpty ||
          v.plate.toLowerCase().contains(q) ||
          v.incidentNumber.toLowerCase().contains(q) ||
          v.reportedBy.toLowerCase().contains(q);
      final matchesStatus = _statusFilter == null || v.status == _statusFilter;
      return matchesText && matchesStatus;
    }).toList();
  }

  SampleViolation? get _selected {
    for (final v in _violations) {
      if (v.incidentNumber == _selectedId) return v;
    }
    return null;
  }

  void _updateStatus(ViolationStatus newStatus) {
    setState(() {
      final i = _violations.indexWhere((v) => v.incidentNumber == _selectedId);
      if (i == -1) return;
      _violations[i] = _violations[i].copyWith(status: newStatus);
    });
  }

  Widget _detailPanels(SampleViolation v) {
    final driver =
        sampleVehicles
            .where((x) => x.plate == v.plate)
            .map((x) => x.driver)
            .firstOrNull ??
        'Unknown driver';
    final color = violationColor(v.status);
    final reviewTitle = switch (v.status) {
      ViolationStatus.pending => 'Awaiting review',
      ViolationStatus.inReview => 'Under review',
      ViolationStatus.resolved => 'Resolved',
    };

    return Column(
      children: [
        Panel(
          title: 'Selected incident',
          caption: v.incidentNumber,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoBanner(
                icon: Icons.warning_amber_rounded,
                color: color,
                title: v.plate,
                text: v.type,
              ),
              const SizedBox(height: 8),
              DetailRow('Driver', driver),
              DetailRow(
                'Assigned / detected',
                '${v.assignedAreaId} → ${v.detectedAreaId}',
              ),
              DetailRow('Reported', v.reportedAt),
              DetailRow('Security guard', v.reportedBy),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.action.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GUARD NOTES',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.action,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(v.notes, style: const TextStyle(fontSize: 12.5)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Update status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final s in ViolationStatus.values)
                    ChoiceChip(
                      label: Text(violationLabel(s)),
                      selected: v.status == s,
                      onSelected: (_) => _updateStatus(s),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          title: 'Review history',
          child: HeadTimeline(
            entries: [
              TimelineEntry(
                'Incident submitted',
                'By ${v.reportedBy}',
                v.reportedAt,
              ),
              const TimelineEntry(
                'Visible to head security and driver',
                'Record saved',
                '',
              ),
              TimelineEntry(
                reviewTitle,
                '',
                '',
                state: v.status == ViolationStatus.resolved
                    ? TimelineState.done
                    : TimelineState.pending,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final selected = _selected;
    final selectedIndex = filtered.indexWhere(
      (v) => v.incidentNumber == _selectedId,
    );

    return HeadPage(
      eyebrow: 'INCIDENT RESPONSE · SECURITY OPERATIONS',
      title: 'Violation Management',
      subtitle: 'Reported violations, review queue and resolution history',
      children: [
        StatRow(
          cards: [
            StatCard(
              icon: Icons.report_gmailerrorred_outlined,
              iconColor: AppColors.danger,
              label: 'PENDING',
              value: '${_count(ViolationStatus.pending)}',
            ),
            StatCard(
              icon: Icons.find_in_page_outlined,
              iconColor: AppColors.warning,
              label: 'IN REVIEW',
              value: '${_count(ViolationStatus.inReview)}',
            ),
            StatCard(
              icon: Icons.check_circle_outline,
              iconColor: AppColors.success,
              label: 'RESOLVED',
              value: '${_count(ViolationStatus.resolved)}',
            ),
            StatCard(
              icon: Icons.bar_chart,
              label: 'TOTAL VIOLATIONS',
              value: '${_violations.length}',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: HeadSearchField(
                hint: 'Search incident, plate, guard...',
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(width: 12),
            HeadDropdown<ViolationStatus?>(
              value: _statusFilter,
              width: 160,
              items: [
                const DropdownMenuItem<ViolationStatus?>(
                  value: null,
                  child: Text('Status: All'),
                ),
                for (final s in ViolationStatus.values)
                  DropdownMenuItem<ViolationStatus?>(
                    value: s,
                    child: Text(violationLabel(s)),
                  ),
              ],
              onChanged: (value) => setState(() => _statusFilter = value),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final tablePanel = Panel(
              title: 'Reported violations and history',
              caption: '${filtered.length} records',
              child: LayoutBuilder(
                builder: (context, tableConstraints) {
                  final tableWidth = tableConstraints.maxWidth < 800
                      ? 800.0
                      : tableConstraints.maxWidth;

                  return Scrollbar(
                    controller: _tableController,
                    thumbVisibility: true,
                    scrollbarOrientation: ScrollbarOrientation.bottom,
                    child: SingleChildScrollView(
                      controller: _tableController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: tableWidth,
                        child: HeadTable(
                          columns: const [
                            HeadColumn('Incident / vehicle', flex: 3),
                            HeadColumn('Violation', flex: 2),
                            HeadColumn('Date / time', flex: 2),
                            HeadColumn('Location', flex: 2),
                            HeadColumn('Reported by', flex: 2),
                            HeadColumn('Status', flex: 2),
                          ],
                          selectedIndex: selectedIndex >= 0
                              ? selectedIndex
                              : null,
                          onRowTap: (i) => setState(
                            () => _selectedId = filtered[i].incidentNumber,
                          ),
                          emptyText: 'No violations match your search.',
                          rows: [
                            for (final v in filtered)
                              [
                                TwoLineCell(v.plate, v.incidentNumber),
                                Text(
                                  v.type,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  v.reportedAt,
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                                Text(v.detectedAreaId, style: monoStyle),
                                Text(
                                  v.reportedBy,
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                                StatusPill(
                                  label: violationLabel(v.status),
                                  color: violationColor(v.status),
                                ),
                              ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );

            final detailPanel = selected == null
                ? const Panel(
                    title: 'Selected incident',
                    child: Text('Select a violation from the list.'),
                  )
                : _detailPanels(selected);

            if (constraints.maxWidth < 900) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [tablePanel, const SizedBox(height: 16), detailPanel],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: tablePanel),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: detailPanel),
              ],
            );
          },
        ),
      ],
    );
  }
}
