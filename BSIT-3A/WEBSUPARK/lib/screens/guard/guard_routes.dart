import 'package:flutter/widgets.dart';
import 'package:websupark/screens/guard/data/sample_guard_data.dart';
import 'package:websupark/screens/guard/models/guard_case.dart';
import 'package:websupark/screens/guard/guard_vehicle.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/screens/guard/patrol_home_screen.dart';
import 'package:websupark/screens/guard/report_submitted_screen.dart';
import 'package:websupark/screens/guard/report_violation_screen.dart';
import 'package:websupark/screens/guard/scan_vehicle_pass_screen.dart';
import 'package:websupark/screens/guard/vehicle_record_screen.dart';
import 'package:websupark/screens/guard/verify_parking_screen.dart';
import 'package:websupark/widgets/phone_frame.dart';

/// Reads the arguments given to Navigator.pushNamed, if they have type T.
T? _args<T>(BuildContext context) {
  final a = ModalRoute.of(context)?.settings.arguments;
  return a is T ? a : null;
}

/// If a screen is opened directly (e.g. after a hot restart) it falls back
/// to sample data instead of crashing.
GuardCase _guardCase(BuildContext context) =>
    _args<GuardCase>(context) ??
    GuardCase(record: sampleVehicleRecord, check: sampleParkingCheck);

/// The security guard flow S1 to S6, in the order of the prototype.
/// In AppRouter.routes add:  ...guardRoutes,
/// (Recent Checks and Incident Details are opened directly with
/// MaterialPageRoute, so they need no entry in AppRoutes.)
final Map<String, WidgetBuilder> guardRoutes = {
  AppRoutes.guardConsole: (_) => const PhoneFrame(child: PatrolHomeScreen()),
  AppRoutes.guardScan: (_) =>
      const PhoneFrame(child: ScanVehiclePassScreen()),
  AppRoutes.guardVehicleRecord: (context) => PhoneFrame(
        child: VehicleRecordScreen(
          record: _args<GuardVehicle>(context) ?? sampleVehicleRecord,
        ),
      ),
  AppRoutes.guardVerifyParking: (context) =>
      PhoneFrame(child: VerifyParkingScreen(guardCase: _guardCase(context))),
  AppRoutes.guardReportViolation: (context) =>
      PhoneFrame(child: ReportViolationScreen(guardCase: _guardCase(context))),
  AppRoutes.guardReportSubmitted: (context) =>
      PhoneFrame(child: ReportSubmittedScreen(guardCase: _guardCase(context))),
};