import 'package:flutter/material.dart';
import 'package:websupark/screens/head_security/head_sample_data.dart';
import 'package:websupark/theme/app_colors.dart';

// ---------- Formatting helpers ----------

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

String formatTime(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${d.hour < 12 ? 'AM' : 'PM'}';
}

/// Turns a Duration into text like "1h 35m".
String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  return h > 0 ? '${h}h ${m}m' : '${m}m';
}

/// Bar color by how full an area is.
Color occupancyColor(double ratio) {
  if (ratio >= 1) return AppColors.danger;
  if (ratio >= 0.85) return AppColors.warning;
  return AppColors.action;
}

String violationLabel(ViolationStatus s) => switch (s) {
  ViolationStatus.pending => 'Pending',
  ViolationStatus.inReview => 'In review',
  ViolationStatus.resolved => 'Resolved',
};

Color violationColor(ViolationStatus s) => switch (s) {
  ViolationStatus.pending => AppColors.danger,
  ViolationStatus.inReview => AppColors.warning,
  ViolationStatus.resolved => AppColors.success,
};

/// Monospace style for plates, pass numbers and incident numbers.
const monoStyle = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.w600,
  fontSize: 13,
  color: AppColors.textPrimary,
);

// ---------- Page frame with the top bar ----------

/// Every head security page uses this: a white top bar (label, title,
/// subtitle, status pill, date, bell) and a scrollable body below it.
class HeadPage extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const HeadPage({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final bool narrow = constraints.maxWidth < 700;

            final controls = Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                const _TopBarPill(),
                _TopBarBox(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatDate(DateTime.now()),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const _TopBarBox(
                  child: Icon(
                    Icons.notifications_none,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            );

            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: narrow ? 16 : 24,
                vertical: 14,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: narrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eyebrow,
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        controls,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eyebrow,
                                style: const TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Wrap(
                                spacing: 12,
                                crossAxisAlignment: WrapCrossAlignment.end,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    subtitle,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        controls,
                      ],
                    ),
            );
          },
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final padding = constraints.maxWidth < 600 ? 12.0 : 24.0;

              return SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TopBarPill extends StatelessWidget {
  const _TopBarPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: AppColors.success),
          SizedBox(width: 6),
          Text(
            'SAMPLE DATA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBarBox extends StatelessWidget {
  final Widget child;
  const _TopBarBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

// ---------- Cards and small pieces ----------

/// A white rounded card. It uses Material (not Container) so list items
/// inside it can show ripples and selected colors correctly.
class Panel extends StatelessWidget {
  final String? title;
  final String? caption; // small muted text on the right of the title
  final Widget child;
  final VoidCallback? onTap;

  const Panel({
    super.key,
    this.title,
    this.caption,
    this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title!.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.6,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (caption != null)
                      Text(
                        caption!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded square with an icon, like the small tiles in the prototype.
class IconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconTile({
    super.key,
    required this.icon,
    this.color = AppColors.action,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// A number card: icon tile, small label, big value and a small note.
/// A number card: icon tile, small label, big value and a small note.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? note;
  final Color? noteColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.note,
    this.noteColor,
    this.onTap,
    this.iconColor = AppColors.action,
  });

  @override
  Widget build(BuildContext context) {
    return Panel(
      onTap: onTap,
      child: Row(
        children: [
          IconTile(icon: icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (note != null) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            note!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: noteColor ?? AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Puts stat cards in one row with equal widths.
class StatRow extends StatelessWidget {
  final List<Widget> cards;

  const StatRow({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;

        if (constraints.maxWidth >= 900) {
          columns = 3;
        } else if (constraints.maxWidth >= 600) {
          columns = 2;
        } else {
          columns = 1;
        }

        const spacing = 16.0;
        final cardWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}

/// A rounded colored label with a dot, such as "• PENDING".
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const StatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A thin rounded progress bar.
class UsageBar extends StatelessWidget {
  final double ratio;
  final Color color;
  final Color background;
  const UsageBar({
    super.key,
    required this.ratio,
    required this.color,
    this.background = AppColors.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: ratio.clamp(0.0, 1.0),
        minHeight: 8,
        color: color,
        backgroundColor: background,
      ),
    );
  }
}

/// A colored message bar (info, warning).
class InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String? title;
  const InfoBanner({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                Text(text, style: const TextStyle(fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One "label ........ value" line for the selected-record panels.
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const DetailRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Table ----------

class HeadColumn {
  final String title;
  final int flex;
  const HeadColumn(this.title, {this.flex = 1});
}

/// Full-width table with a dark header row. Each row is a list of widgets,
/// one per column. Tapping a row calls onRowTap(index).
class HeadTable extends StatelessWidget {
  final List<HeadColumn> columns;
  final List<List<Widget>> rows;
  final int? selectedIndex;
  final Set<int> warningRows;
  final ValueChanged<int>? onRowTap;
  final String emptyText;

  const HeadTable({
    super.key,
    required this.columns,
    required this.rows,
    this.selectedIndex,
    this.warningRows = const {},
    this.onRowTap,
    this.emptyText = 'No records match your search.',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final table = ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: AppColors.sidebar,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      for (final c in columns)
                        Expanded(
                          flex: c.flex,
                          child: Text(
                            c.title.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                for (var i = 0; i < rows.length; i++)
                  Material(
                    color: i == selectedIndex
                        ? AppColors.action.withValues(alpha: 0.08)
                        : warningRows.contains(i)
                        ? AppColors.warningSoft
                        : AppColors.surface,
                    child: InkWell(
                      onTap: onRowTap == null ? null : () => onRowTap!(i),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: Row(
                          children: [
                            for (var j = 0; j < columns.length; j++)
                              Expanded(
                                flex: columns[j].flex,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: rows[i][j],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (rows.isEmpty)
                  Container(
                    width: double.infinity,
                    color: AppColors.surface,
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      emptyText,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ),
              ],
            ),
          ),
        );

        if (constraints.maxWidth < 900) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: 900, child: table),
          );
        }

        return table;
      },
    );
  }
}

/// Bold line with a small muted line below (name + phone, plate + model).
class TwoLineCell extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool mono;
  const TwoLineCell(this.title, this.subtitle, {super.key, this.mono = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: mono
              ? monoStyle
              : const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

// ---------- Filters ----------

class HeadSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const HeadSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: const Icon(Icons.search, size: 20),
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }
}

class HeadDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final double width;
  const HeadDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ---------- Timeline and activity feed ----------

enum TimelineState { done, pending }

class TimelineEntry {
  final String title;
  final String detail;
  final String time;
  final TimelineState state;
  const TimelineEntry(
    this.title,
    this.detail,
    this.time, {
    this.state = TimelineState.done,
  });
}

class HeadTimeline extends StatelessWidget {
  final List<TimelineEntry> entries;
  const HeadTimeline({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  e.state == TimelineState.done
                      ? Icons.check_circle
                      : Icons.schedule,
                  size: 20,
                  color: e.state == TimelineState.done
                      ? AppColors.success
                      : AppColors.warning,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (e.detail.isNotEmpty)
                        Text(
                          e.detail,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  e.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

(IconData, Color) _kindStyle(ActivityKind k) => switch (k) {
  ActivityKind.mismatch => (Icons.warning_amber_rounded, AppColors.warning),
  ActivityKind.entry => (Icons.login, AppColors.success),
  ActivityKind.exit => (Icons.logout, AppColors.textMuted),
  ActivityKind.verified => (Icons.place_outlined, AppColors.action),
  ActivityKind.scan => (Icons.document_scanner_outlined, AppColors.success),
};

/// One line of the activity feed (time, icon, title, detail, tag).
class ActivityTile extends StatelessWidget {
  final SampleActivity activity;
  const ActivityTile(this.activity, {super.key});

  @override
  Widget build(BuildContext context) {
    final style = _kindStyle(activity.kind);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    activity.detail,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  activity.time,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              IconTile(icon: style.$1, color: style.$2, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      activity.detail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(label: activity.tag, color: style.$2),
            ],
          ),
        );
      },
    );
  }
}
