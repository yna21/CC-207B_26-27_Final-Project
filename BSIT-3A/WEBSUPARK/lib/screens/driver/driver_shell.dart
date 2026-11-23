import 'package:flutter/material.dart';
import 'package:websupark/screens/driver/driver_alerts_screen.dart';
import 'package:websupark/screens/driver/driver_assignment_screen.dart';
import 'package:websupark/screens/driver/driver_common.dart';
import 'package:websupark/screens/driver/driver_home_screen.dart';
import 'package:websupark/screens/driver/driver_vehicle_screen.dart';
import 'package:websupark/screens/driver/driver_violations_screen.dart';
import 'package:websupark/theme/app_colors.dart';

/// Frame of the driver interface: five pages with navigation.
/// Phone: bottom navigation bar. Tablet or desktop: side navigation menu.
/// Each tab shows one real screen (D1 to D5 in the prototype checklist).
class DriverShell extends StatefulWidget {
  const DriverShell({super.key, this.initialIndex = 0});

  /// Which tab opens first (0 = Home ... 4 = Vehicle).
  final int initialIndex;

  @override
  State<DriverShell> createState() => _DriverShellState();
}

/// One tab. The phone bar and the side menu both use this list,
/// so their icons and labels can never disagree.
class _Tab {
  const _Tab(this.icon, this.label);

  final IconData icon;
  final String label;
}

const List<_Tab> _tabs = [
  _Tab(Icons.home_outlined, 'Home'),
  _Tab(Icons.local_parking, 'Assignment'),
  _Tab(Icons.notifications_none, 'Alerts'),
  _Tab(Icons.warning_amber_outlined, 'Violations'),
  _Tab(Icons.directions_car_outlined, 'Vehicle'),
];

class _DriverShellState extends State<DriverShell> {
  // The tab currently shown. It changes when a tab is tapped.
  late int _index = widget.initialIndex;

  // A GlobalKey lets Flutter move the pages from the phone layout to the
  // wide layout (when the window is resized) without losing what the user
  // typed or scrolled.
  final GlobalKey _pagesKey = GlobalKey();

  // One page per tab, in the same order as the navigation.
  final List<Widget> _pages = const [
    DriverHomeScreen(), // D1
    DriverAssignmentScreen(), // D2
    DriverAlertsScreen(), // D3
    DriverViolationsScreen(), // D4
    DriverVehicleScreen(), // D5
  ];

  // IndexedStack keeps every page alive, so switching tabs does not lose
  // what the user typed or scrolled. DriverTextScale limits huge text sizes.
  Widget _buildPages() {
    return DriverTextScale(
      key: _pagesKey,
      child: IndexedStack(index: _index, children: _pages),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder gives the real window size, so the layout can change
    // when the window is resized.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= driverWideBreakpoint) {
          return _buildWide(constraints);
        }
        return _buildPhone();
      },
    );
  }

  // Phone layout: a centered phone-width column with a bottom bar.
  Widget _buildPhone() {
    return ColoredBox(
      color: AppColors.border,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Scaffold(
            body: SafeArea(child: _buildPages()),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                for (final tab in _tabs)
                  NavigationDestination(icon: Icon(tab.icon), label: tab.label),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Wide layout: side menu on the left, the page fills the rest.
  Widget _buildWide(BoxConstraints constraints) {
    // On a big desktop window the menu shows the labels next to the icons.
    final extended = constraints.maxWidth >= 1100;
    // On a short screen (a phone turned sideways) only the selected tab
    // shows its label, so the five tabs still fit.
    final shortScreen = constraints.maxHeight < 480;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              backgroundColor: AppColors.surface,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              extended: extended,
              labelType: extended
                  ? NavigationRailLabelType.none
                  : (shortScreen
                      ? NavigationRailLabelType.selected
                      : NavigationRailLabelType.all),
              destinations: [
                for (final tab in _tabs)
                  NavigationRailDestination(
                    icon: Icon(tab.icon),
                    label: Text(tab.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1, color: AppColors.border),
            Expanded(child: _buildPages()),
          ],
        ),
      ),
    );
  }
}
