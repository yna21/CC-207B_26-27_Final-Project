import 'package:flutter/material.dart';
import 'package:websupark/screens/head_security/h1_central_overview_screen.dart';
import 'package:websupark/screens/head_security/h2_vehicle_database_screen.dart';
import 'package:websupark/screens/head_security/h3_parking_monitoring_screen.dart';
import 'package:websupark/screens/head_security/h4_violation_management_screen.dart';
import 'package:websupark/screens/head_security/h5_yellow_pass_screen.dart';
import 'package:websupark/screens/head_security/h6_outside_vehicles_screen.dart';
import 'package:websupark/screens/head_security/head_sample_data.dart';
import 'package:websupark/theme/app_colors.dart';

/// Frame of the head-security interface: a dark sidebar on the left
/// and the selected page on the right (desktop layout).
class HeadShell extends StatefulWidget {
  const HeadShell({super.key, this.initialIndex = 0});

  /// Which sidebar item opens first (0 = Central Overview ... 5 = Outside Vehicles).
  final int initialIndex;

  @override
  State<HeadShell> createState() => _HeadShellState();
}

class _HeadShellState extends State<HeadShell> {
  // The sidebar item currently selected.
  late int _index = widget.initialIndex;

  // One page per sidebar item, in the same order as the destinations below.
  final List<Widget> _pages = const [
    CentralOverviewScreen(),
    VehicleDatabaseScreen(),
    ParkingMonitoringScreen(),
    ViolationManagementScreen(),
    YellowPassScreen(),
    OutsideVehiclesScreen(),
  ];

  // Icon with an optional red badge (used for open violations).
  Widget _icon(IconData icon, {int badge = 0}) =>
      badge > 0 ? Badge(label: Text('$badge'), child: Icon(icon)) : Icon(icon);

  @override
  Widget build(BuildContext context) {
    final openCount = sampleViolations
        .where((v) => v.status != ViolationStatus.resolved)
        .length;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 900;
          final shortScreen = constraints.maxHeight < 650;

          return Row(
            children: [
              NavigationRail(
                extended: !compact,
                minExtendedWidth: 260,
                minWidth: 72,
                backgroundColor: AppColors.sidebar,
                indicatorColor: AppColors.action,
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                selectedIndex: _index,
                onDestinationSelected: (i) {
                  setState(() => _index = i);
                },
                selectedIconTheme: const IconThemeData(color: Colors.white),
                unselectedIconTheme: const IconThemeData(color: Colors.white70),
                selectedLabelTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: Colors.white70,
                ),
                leading: compact
                    ? const Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                        child: Icon(Icons.shield_outlined, color: Colors.white),
                      )
                    : shortScreen
                    ? null
                    : const _SidebarHeader(),
                trailing: compact || shortScreen ? null : const _SidebarUser(),
                destinations: [
                  NavigationRailDestination(
                    icon: _icon(Icons.dashboard_outlined),
                    label: const Text('Central Overview'),
                  ),
                  NavigationRailDestination(
                    icon: _icon(Icons.directions_car_outlined),
                    label: const Text('Vehicle Database'),
                  ),
                  NavigationRailDestination(
                    icon: _icon(Icons.map_outlined),
                    label: const Text('Parking Monitoring'),
                  ),
                  NavigationRailDestination(
                    icon: _icon(Icons.warning_amber_outlined, badge: openCount),
                    label: const Text('Violation Management'),
                  ),
                  NavigationRailDestination(
                    icon: _icon(Icons.schedule),
                    label: const Text('Yellow Pass Monitoring'),
                  ),
                  NavigationRailDestination(
                    icon: _icon(Icons.local_shipping_outlined),
                    label: const Text('Outside Vehicles'),
                  ),
                ],
              ),
              Expanded(
                child: IndexedStack(index: _index, children: _pages),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.action,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MAIN GATE',
                      style: TextStyle(color: Colors.white54, fontSize: 10.5),
                    ),
                    Text(
                      'Security Command',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'SITE STATUS',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.circle, size: 7, color: AppColors.success),
                      SizedBox(width: 4),
                      Text(
                        'SAMPLE',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Main Gate · All areas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'OPERATIONS',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10.5,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarUser extends StatelessWidget {
  const _SidebarUser();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.action,
            child: Text(
              'AR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alfaro',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Chief Security Officer',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
