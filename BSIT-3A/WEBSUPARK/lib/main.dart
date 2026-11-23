import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:websupark/config/firebase_config.dart';
import 'package:websupark/routes/app_router.dart';
import 'package:websupark/screens/auth/login_screen.dart';
import 'package:websupark/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (FirebaseConfig.isConfigured) {
    await Firebase.initializeApp(options: FirebaseConfig.options);
  }

  runApp(const WebsuParkApp());
}

class WebsuParkApp extends StatelessWidget {
  const WebsuParkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WEBSUPARK',
      theme: AppTheme.light,
      routes: AppRouter.routes,
      home: const LoginScreen(),
    );
  }
}