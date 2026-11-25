import 'package:flutter/widgets.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/screens/guard/data/sample_guard_data.dart';
import 'package:websupark/screens/guard/guard_shell.dart';
import 'package:websupark/screens/guard/guard_vehicle.dart';
import 'package:websupark/screens/guard/models/guard_case.dart';
import 'package:websupark/screens/guard/patrol_home_screen.dart';
import 'package:websupark/screens/guard/recent_checks_screen.dart';
import 'package:websupark/screens/guard/report_submitted_screen.dart';
import 'package:websupark/screens/guard/report_violation_screen.dart';
import 'package:websupark/screens/guard/scan_vehicle_pass_screen.dart';
import 'package:websupark/screens/guard/vehicle_record_screen.dart';
import 'package:websupark/screens/guard/verify_parking_screen.dart';

/// Route name of the Recent Checks page. It has no entry in AppRoutes, so it
/// is defined here. It only exists inside the guard shell.
const String guardRecentChecksRoute = 'guard-recent-checks';

/// Reads the arguments given to Navigator.pushNamed, if they have type T.
T? _args<T>(BuildContext context) {
  final a = ModalRoute.of(context)?.settings.arguments;
  return a is T ? a : null;
}

/// If a screen is opened directly (e.g. from the sidebar before any vehicle
/// was scanned) it falls back to sample data instead of crashing.
GuardCase _guardCase(BuildContext context) =>
    _args<GuardCase>(context) ??
    GuardCase(record: sampleVehicleRecord, check: sampleParkingCheck);

/// App-level route table. In AppRouter.routes keep:  ...guardRoutes,
///
/// There is ONE app-level route for the guard: the shell. It holds the
/// sidebar / bottom bar and its own Navigator, and all the screens below open
/// inside it, so the navigation stays in place.
final Map<String, WidgetBuilder> guardRoutes = {
  AppRoutes.guardConsole: (_) => const GuardShell(),
};

/// The guard screens S1 to S6. They are opened by the Navigator INSIDE the
/// shell (see GuardShell), never by the app-level Navigator.
/// (Check Details and Incident Details are opened directly with
/// MaterialPageRoute, so they need no entry here.)
final Map<String, WidgetBuilder> guardPageRoutes = {
  AppRoutes.guardConsole: (_) => const PatrolHomeScreen(),
  AppRoutes.guardScan: (_) => const ScanVehiclePassScreen(),
  // embedded: true hides the Back arrow; Recent Checks is a main page.
  guardRecentChecksRoute: (_) => const RecentChecksScreen(embedded: true),
  AppRoutes.guardVehicleRecord: (context) => VehicleRecordScreen(
        record: _args<GuardVehicle>(context) ?? sampleVehicleRecord,
      ),
  AppRoutes.guardVerifyParking: (context) =>
      VerifyParkingScreen(guardCase: _guardCase(context)),
  AppRoutes.guardReportViolation: (context) =>
      ReportViolationScreen(guardCase: _guardCase(context)),
  AppRoutes.guardReportSubmitted: (context) =>
      ReportSubmittedScreen(guardCase: _guardCase(context)),
};