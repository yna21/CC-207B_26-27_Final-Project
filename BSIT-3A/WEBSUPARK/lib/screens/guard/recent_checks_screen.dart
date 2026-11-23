import 'package:flutter/material.dart';
import 'package:websupark/screens/guard/data/guard_log.dart';
import 'package:websupark/screens/guard/models/vehicle_check.dart';
import 'package:websupark/theme/app_colors.dart';
import 'package:websupark/screens/guard/widgets/guard_widgets.dart';
import 'package:websupark/screens/guard/widgets/recent_check_tile.dart';

enum _CheckFilter {
  all('All'),
  cleared('Cleared'),
  mismatch('Mismatch'),
  reported('Reported');

  const _CheckFilter(this.label);
  final String label;
}

/// "View all" from Patrol Home: every check of the shift, with a filter.
/// Each vehicle the guard verifies is added here; reported violations show
/// as REPORTED.
class RecentChecksScreen extends StatefulWidget {
  const RecentChecksScreen({super.key});

  @override
  State<RecentChecksScreen> createState() => _RecentChecksScreenState();
}

class _RecentChecksScreenState extends State<RecentChecksScreen> {
  _CheckFilter _filter = _CheckFilter.all;

  List<VehicleCheck> _apply(List<VehicleCheck> all, _CheckFilter f) {
    switch (f) {
      case _CheckFilter.all:
        return all;
      case _CheckFilter.cleared:
        return all.where((c) => c.status == CheckStatus.cleared).toList();
      case _CheckFilter.mismatch:
        return all.where((c) => c.status == CheckStatus.mismatch).toList();
      case _CheckFilter.reported:
        return all.where((c) => c.status == CheckStatus.reported).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GuardLog.instance,
      builder: (context, _) {
        final all = GuardLog.instance.checks;
        final items = _apply(all, _filter);

        return Scaffold(
          appBar: GuardAppBar(
            title: 'Recent Checks',
            subtitle: '${all.length} CHECKS THIS SHIFT',
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      for (final f in _CheckFilter.values) ...[
                        _FilterChip(
                          label: f.label,
                          count: _apply(all, f).length,
                          selected: _filter == f,
                          onTap: () => setState(() => _filter = f),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                          child: Text('No checks in this filter.',
                              style: TextStyle(color: AppColors.textMuted)),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => RecentCheckTile(check: items[i]),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.navy : AppColors.border),
        ),
        child: Text(
          '$label · $count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}