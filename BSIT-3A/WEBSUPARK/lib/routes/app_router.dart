
import 'package:flutter/widgets.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/screens/auth/login_screen.dart';
import 'package:websupark/screens/auth/sign_up_screen.dart';
import 'package:websupark/screens/dev/dev_launcher_screen.dart';
import 'package:websupark/screens/driver/driver_shell.dart';
import 'package:websupark/screens/driver/renewal_details_screen.dart';
import 'package:websupark/screens/driver/renewal_payment_screen.dart';
import 'package:websupark/screens/driver/renewal_review_screen.dart';
import 'package:websupark/screens/driver/renewal_submitted_screen.dart';
import 'package:websupark/screens/guard/guard_flow_screen.dart';
import 'package:websupark/screens/guard/guard_routes.dart';
import 'package:websupark/screens/head_security/head_shell.dart';

class AppRouter {
  AppRouter._();

  static final Map<String, WidgetBuilder> routes = {
    // Sign in, sign up and development shortcuts.
    AppRoutes.login: (_) => const LoginScreen(),
    AppRoutes.signUp: (_) => const SignUpScreen(),
    AppRoutes.devLauncher: (_) => const DevLauncherScreen(),

    // Driver
    AppRoutes.driverHome: (_) => const DriverShell(initialIndex: 0),
    AppRoutes.driverAssignment: (_) => const DriverShell(initialIndex: 1),
    AppRoutes.driverAlerts: (_) => const DriverShell(initialIndex: 2),
    AppRoutes.driverViolations: (_) => const DriverShell(initialIndex: 3),
    AppRoutes.driverVehicle: (_) => const DriverShell(initialIndex: 4),

    // Driver: vehicle pass renewal (steps 1 to 3, then confirmation).
    AppRoutes.driverRenewalPayment: (_) => const RenewalPaymentScreen(),
    AppRoutes.driverRenewalDetails: (_) => const RenewalDetailsScreen(),
    AppRoutes.driverRenewalReview: (_) => const RenewalReviewScreen(),
    AppRoutes.driverRenewalSubmitted: (_) => const RenewalSubmittedScreen(),

    // Guard: a chain of screens S1 to S6. Each temporary button
    // points to the next screen in the prototype flow.
    AppRoutes.guardConsole: (_) => const GuardFlowScreen(
          title: 'Patrol Console',
          screenCode: 'S1',
          nextRoute: AppRoutes.guardScan,
          nextLabel: 'Scan Vehicle Pass',
        ),
    AppRoutes.guardScan: (_) => const GuardFlowScreen(
          title: 'Scan Vehicle Pass',
          screenCode: 'S2',
          nextRoute: AppRoutes.guardVehicleRecord,
          nextLabel: 'Open Vehicle Record',
        ),
    AppRoutes.guardVehicleRecord: (_) => const GuardFlowScreen(
          title: 'Vehicle Record',
          screenCode: 'S3',
          nextRoute: AppRoutes.guardVerifyParking,
          nextLabel: 'Verify Parking Location',
        ),
    AppRoutes.guardVerifyParking: (_) => const GuardFlowScreen(
          title: 'Verify Parking',
          screenCode: 'S4',
          nextRoute: AppRoutes.guardReportViolation,
          nextLabel: 'Report Violation',
        ),
    AppRoutes.guardReportViolation: (_) => const GuardFlowScreen(
          title: 'Report Violation',
          screenCode: 'S5',
          nextRoute: AppRoutes.guardReportSubmitted,
          nextLabel: 'Submit Violation',
        ),
    AppRoutes.guardReportSubmitted: (_) => const GuardFlowScreen(
          title: 'Report Submitted',
          screenCode: 'S6',
          nextRoute: AppRoutes.guardConsole,
          nextLabel: 'Return to Patrol',
        ),
    
    // Head security: all six sidebar names open the same shell,
    // on a different sidebar item.
    // Guard screens
    ...guardRoutes,

    // Head security
    AppRoutes.headOverview: (_) => const HeadShell(initialIndex: 0),
    AppRoutes.headVehicles: (_) => const HeadShell(initialIndex: 1),
    AppRoutes.headParking: (_) => const HeadShell(initialIndex: 2),
    AppRoutes.headViolations: (_) => const HeadShell(initialIndex: 3),
    AppRoutes.headYellowPass: (_) => const HeadShell(initialIndex: 4),
    AppRoutes.headOutsideVehicles: (_) => const HeadShell(initialIndex: 5),
  };
}
