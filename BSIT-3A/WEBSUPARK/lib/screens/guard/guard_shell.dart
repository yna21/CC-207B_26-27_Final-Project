import 'package:flutter/material.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/screens/guard/guard_routes.dart';
import 'package:websupark/screens/guard/utils/guard_sign_out.dart';
import 'package:websupark/screens/guard/widgets/guard_page.dart';
import 'package:websupark/theme/app_colors.dart';

/// Width from which the bottom bar becomes a sidebar.
const double _sidebarBreakpoint = 600;

/// Width from which the sidebar shows full labels (below it: icons + short
/// labels).
const double _extendedBreakpoint = 900;

/// One entry of the navigation (sidebar or bottom bar).
class _Dest {
  const _Dest(
      this.route, this.label, this.shortLabel, this.icon, this.selectedIcon);

  final String route;
  final String label;
  final String shortLabel;
  final IconData icon;
  final IconData selectedIcon;
}

/// The three main pages of the guard interface.
final List<_Dest> _destinations = [
  _Dest(AppRoutes.guardConsole, 'Patrol Console', 'Patrol',
      Icons.shield_outlined, Icons.shield),
  _Dest(AppRoutes.guardScan, 'Scan Vehicle Pass', 'Scan',
      Icons.center_focus_strong_outlined, Icons.center_focus_strong),
  _Dest(guardRecentChecksRoute, 'Recent Checks', 'Checks', Icons.history,
      Icons.history),
];

/// Which navigation item is highlighted for a page. Vehicle Record, Verify
/// Parking, Report Violation and Report Submitted are steps of a scan, so
/// they keep "Scan" highlighted. Pages without a name (Check Details,
/// Incident Details) return null and keep the current highlight.
String? _highlightFor(String? name) {
  if (name == AppRoutes.guardConsole) return AppRoutes.guardConsole;
  if (name == guardRecentChecksRoute) return guardRecentChecksRoute;
  if (name == AppRoutes.guardScan ||
      name == AppRoutes.guardVehicleRecord ||
      name == AppRoutes.guardVerifyParking ||
      name == AppRoutes.guardReportViolation ||
      name == AppRoutes.guardReportSubmitted) {
    return AppRoutes.guardScan;
  }
  return null;
}

/// Main frame of the guard interface.
///
/// The navigation (sidebar on wide screens, bottom bar on narrow screens)
/// belongs to THIS widget, and every guard screen opens inside the Navigator
/// below it. That is why the navigation never moves or reloads when you go
/// from one screen to another: only the content area changes.
class GuardShell extends StatefulWidget {
  const GuardShell({super.key});

  @override
  State<GuardShell> createState() => _GuardShellState();
}

class _GuardShellState extends State<GuardShell> {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  /// Route name of the highlighted navigation item.
  final ValueNotifier<String> _current =
      ValueNotifier<String>(AppRoutes.guardConsole);

  /// Name of the page that is on top right now (null for pages that were
  /// pushed without a name, like Recent Checks).
  String? _topName = AppRoutes.guardConsole;

  late final _GuardNavObserver _observer = _GuardNavObserver(_onRoute);

  /// The Navigator is built once and kept, so resizing the window does not
  /// restart it.
  late final Widget _navigator = Navigator(
    key: _navKey,
    initialRoute: AppRoutes.guardConsole,
    // Only the Patrol page at the start. (Without this, Flutter would split a
    // route name like '/guard/console' and stack extra pages.)
    onGenerateInitialRoutes: (_, _) =>
        [_generate(RouteSettings(name: AppRoutes.guardConsole))],
    onGenerateRoute: _generate,
    observers: [_observer],
  );

  @override
  void dispose() {
    _current.dispose();
    super.dispose();
  }

  Route<dynamic> _generate(RouteSettings settings) {
    final builder =
        guardPageRoutes[settings.name] ?? guardPageRoutes[AppRoutes.guardConsole]!;
    // Every page has the same width as Verify Parking, Record and Report.
    const maxWidth = 720.0;
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) =>
          GuardPage(maxWidth: maxWidth, child: builder(context)),
    );
  }

  /// Called by the observer whenever a page becomes the top page.
  void _onRoute(Route<dynamic>? route) {
    if (route == null) return;
    _topName = route.settings.name;

    final highlight = _highlightFor(_topName);
    if (highlight != null) {
      // After the frame, because this can run while Flutter is building.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _current.value = highlight;
      });
    }
  }

  /// A sidebar / bottom bar button was tapped.
  void _go(_Dest dest) {
    final nav = _navKey.currentState;
    if (nav == null) return;

    // Patrol is the first page of the stack: go back to it.
    if (dest.route == AppRoutes.guardConsole) {
      nav.popUntil((route) => route.isFirst);
      return;
    }

    // Already on that page.
    if (_topName == dest.route) return;

    nav.pushNamedAndRemoveUntil(dest.route, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= _sidebarBreakpoint;
        final extended = box.maxWidth >= _extendedBreakpoint;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Flex(
            direction: wide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (wide)
                ValueListenableBuilder<String>(
                  valueListenable: _current,
                  builder: (context, selected, _) => _Sidebar(
                    extended: extended,
                    selected: selected,
                    onSelect: _go,
                    onSignOut: () => confirmGuardSignOut(context),
                  ),
                ),
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: !wide, // the bottom bar already uses it
                  child: _navigator,
                ),
              ),
              if (!wide)
                ValueListenableBuilder<String>(
                  valueListenable: _current,
                  builder: (context, selected, _) =>
                      _BottomBar(selected: selected, onSelect: _go),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Tells the shell which page is on top.
class _GuardNavObserver extends NavigatorObserver {
  _GuardNavObserver(this.onRoute);

  final void Function(Route<dynamic>? route) onRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onRoute(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onRoute(previousRoute);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      onRoute(newRoute);
}

// ---------------------------------------------------------------------------
// Sidebar (tablet / laptop)
// ---------------------------------------------------------------------------

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.extended,
    required this.selected,
    required this.onSelect,
    required this.onSignOut,
  });

  final bool extended;
  final String selected;
  final ValueChanged<_Dest> onSelect;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final sidePad = extended ? 12.0 : 8.0;

    return Container(
      width: extended ? 248 : 92,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(sidePad + 8, 24, sidePad + 8, 20),
              child: _Brand(extended: extended),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: sidePad),
                children: [
                  for (final d in _destinations)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _SideButton(
                        icon: d.route == selected ? d.selectedIcon : d.icon,
                        label: extended ? d.label : d.shortLabel,
                        tooltip: d.label,
                        extended: extended,
                        selected: d.route == selected,
                        onTap: () => onSelect(d),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: EdgeInsets.all(sidePad),
              child: _SideButton(
                icon: Icons.logout,
                label: 'Sign out',
                tooltip: 'Sign out',
                extended: extended,
                danger: true,
                onTap: onSignOut,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.action,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.local_parking, color: Colors.white, size: 24),
    );

    if (!extended) return Center(child: logo);

    return Row(
      children: [
        logo,
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WEBSUPARK',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Security Guard',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.extended,
    required this.onTap,
    this.selected = false,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final bool extended;
  final bool selected;
  final bool danger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected
        ? Colors.white
        : (danger ? AppColors.danger : AppColors.textMuted);

    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: extended ? TextAlign.start : TextAlign.center,
      style: TextStyle(
        fontSize: extended ? 14 : 10.5,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: fg,
      ),
    );

    return Tooltip(
      message: tooltip,
      child: Material(
        color: selected ? AppColors.action : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: extended ? 14 : 4,
              vertical: extended ? 13 : 10,
            ),
            child: extended
                ? Row(
                    children: [
                      Icon(icon, size: 22, color: fg),
                      const SizedBox(width: 12),
                      Expanded(child: text),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 22, color: fg),
                      const SizedBox(height: 4),
                      text,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom bar (phone)
// ---------------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<_Dest> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (final d in _destinations)
                Expanded(
                  child: _BarItem(
                    dest: d,
                    selected: d.route == selected,
                    onTap: () => onSelect(d),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.dest,
    required this.selected,
    required this.onTap,
  });

  final _Dest dest;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.action : AppColors.textMuted;

    return Tooltip(
      message: dest.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 28,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.action.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                selected ? dest.selectedIcon : dest.icon,
                size: 21,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  dest.shortLabel,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}