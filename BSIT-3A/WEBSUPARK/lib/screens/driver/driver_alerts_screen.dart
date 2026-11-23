import 'package:flutter/material.dart';
import 'package:websupark/screens/driver/driver_common.dart';
import 'package:websupark/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// SAMPLE DATA (layout only)
// TODO: replace with repository data
// ---------------------------------------------------------------------------
enum _Category { parking, account }

enum _Filter { all, parking, account }

class _AlertItem {
  const _AlertItem({
    required this.id,
    required this.category,
    required this.icon,
    required this.color,
    this.softColor,
    required this.title,
    required this.message,
    required this.time,
    this.startsUnread = false,
  });

  final String id;
  final _Category category;
  final IconData icon;
  final Color color; // icon color
  final Color? softColor; // icon background (null = default pale blue)
  final String title;
  final String message;
  final String time;
  final bool startsUnread;
}

// TODO: replace with repository data
const List<_AlertItem> _alerts = [
  _AlertItem(
    id: 'n1',
    category: _Category.parking,
    icon: Icons.local_parking,
    color: AppColors.primary,
    title: 'Parking Reminder',
    message:
        'Your vehicle is registered to Parking Area A. Please park only in your assigned area.',
    time: 'Today · 7:30 AM',
    startsUnread: true,
  ),
  _AlertItem(
    id: 'n2',
    category: _Category.parking,
    icon: Icons.local_parking,
    color: AppColors.success,
    softColor: AppColors.successSoft,
    title: 'Parking Availability',
    message: 'Parking Area A currently has 8 available spaces.',
    time: 'Today · 7:15 AM',
    startsUnread: true,
  ),
  _AlertItem(
    id: 'n3',
    category: _Category.parking,
    icon: Icons.warning_amber_rounded,
    color: AppColors.danger,
    softColor: AppColors.dangerSoft,
    title: 'Violation Notice',
    message:
        'Your vehicle ABC-1234 has been reported for parking outside its assigned area.',
    time: 'Sept. 28 · 2:42 PM',
    startsUnread: true,
  ),
  _AlertItem(
    id: 'n4',
    category: _Category.account,
    icon: Icons.event_outlined,
    color: AppColors.warning,
    softColor: AppColors.warningSoft,
    title: 'Pass Expiration',
    message: 'Your Blue Vehicle Pass will expire in 15 days.',
    time: 'Sept. 16 · 9:00 AM',
  ),
];

/// D3 Notifications: filter chips and a list of alerts.
/// This screen is a StatefulWidget because it remembers which filter is
/// selected and which alerts the driver has already read.
class DriverAlertsScreen extends StatefulWidget {
  const DriverAlertsScreen({super.key});

  @override
  State<DriverAlertsScreen> createState() => _DriverAlertsScreenState();
}

class _DriverAlertsScreenState extends State<DriverAlertsScreen> {
  _Filter _filter = _Filter.all;

  // Ids of alerts the driver has read during this session.
  final Set<String> _readIds = {};

  // Alerts that match the selected filter.
  List<_AlertItem> get _visibleAlerts => switch (_filter) {
        _Filter.all => _alerts,
        _Filter.parking =>
          _alerts.where((a) => a.category == _Category.parking).toList(),
        _Filter.account =>
          _alerts.where((a) => a.category == _Category.account).toList(),
      };

  bool _isUnread(_AlertItem alert) =>
      alert.startsUnread && !_readIds.contains(alert.id);

  void _markAllAsRead() {
    setState(() => _readIds.addAll(_alerts.map((a) => a.id)));
  }

  @override
  Widget build(BuildContext context) {
    // A list reads best in a narrower column, even on a wide screen.
    return DriverPage(
      maxWidth: 720,
      children: [
        const DriverHeader(
          title: 'Notifications',
          subtitle: 'Parking updates and reminders',
          icon: Icons.tune,
        ),
        const SizedBox(height: 16),
        // Wrap moves a chip to the next line when the screen is too narrow.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChip(
              label: 'All · ${_alerts.length}',
              selected: _filter == _Filter.all,
              onTap: () => setState(() => _filter = _Filter.all),
            ),
            _FilterChip(
              label: 'Parking',
              selected: _filter == _Filter.parking,
              onTap: () => setState(() => _filter = _Filter.parking),
            ),
            _FilterChip(
              label: 'Account',
              selected: _filter == _Filter.account,
              onTap: () => setState(() => _filter = _Filter.account),
            ),
          ],
        ),
        const SizedBox(height: 18),
        DriverSectionHeader(
          title: 'Recent',
          action: 'Mark all as read',
          onActionTap: _markAllAsRead,
        ),
        const SizedBox(height: 10),
        for (final alert in _visibleAlerts)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AlertCard(
              alert: alert,
              isUnread: _isUnread(alert),
              onTap: () => setState(() => _readIds.add(alert.id)),
            ),
          ),
      ],
    );
  }
}

/// Rounded filter pill. Filled blue when selected.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// One notification: icon, title, message, time and an unread dot.
class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.isUnread,
    required this.onTap,
  });

  final _AlertItem alert;
  final bool isUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DriverIconBox(
                icon: alert.icon,
                iconColor: alert.color,
                backgroundColor: alert.softColor,
                size: 38,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert.message,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      alert.time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnread)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
