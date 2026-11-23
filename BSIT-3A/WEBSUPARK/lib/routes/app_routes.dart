import 'package:websupark/models/app_user.dart';

class AppRoutes {
  AppRoutes._();

  static const String root = '/';

  // Sign in and sign up.
  static const String login = '/login';
  static const String signUp = '/sign-up';

  // Development shortcuts (reachable only in debug mode).
  static const String devLauncher = '/dev';

  // Driver interface (mobile).
  static const String driverHome = '/driver/home';
  static const String driverAssignment = '/driver/assignment';
  static const String driverAlerts = '/driver/alerts';
  static const String driverViolations = '/driver/violations';
  static const String driverVehicle = '/driver/vehicle';
  // Vehicle pass renewal.
  static const String driverRenewalPayment = '/driver/renewal/payment';
  static const String driverRenewalDetails = '/driver/renewal/details';
  static const String driverRenewalReview = '/driver/renewal/review';
  static const String driverRenewalSubmitted = '/driver/renewal/submitted';

  // Security guard interface (mobile).
  static const String guardConsole = '/guard/console';
  static const String guardScan = '/guard/scan';
  static const String guardVehicleRecord = '/guard/vehicle-record';
  static const String guardVerifyParking = '/guard/verify-parking';
  static const String guardReportViolation = '/guard/report-violation';
  static const String guardReportSubmitted = '/guard/report-submitted';

  // Head security interface (desktop). These are the sidebar pages.
  static const String headOverview = '/head/overview';
  static const String headVehicles = '/head/vehicles';
  static const String headParking = '/head/parking';
  static const String headViolations = '/head/violations';
  static const String headYellowPass = '/head/yellow-pass';
  static const String headOutsideVehicles = '/head/outside-vehicles';

  static String homeForRole(UserRole role) => switch (role) {
        UserRole.driver => driverHome,
        UserRole.guard => guardConsole,
        UserRole.headSecurity => headOverview,
      };
}
