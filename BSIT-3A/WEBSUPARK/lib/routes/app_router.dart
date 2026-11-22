
import 'package:flutter/widgets.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/screens/auth/login_screen.dart';
import 'package:websupark/screens/auth/sign_up_screen.dart';
import 'package:websupark/screens/dev/dev_launcher_screen.dart';
import 'package:websupark/screens/driver/driver_shell.dart';
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
