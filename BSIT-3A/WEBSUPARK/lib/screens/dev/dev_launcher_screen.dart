import 'package:flutter/material.dart';
import 'package:websupark/routes/app_routes.dart';

class DevLauncherScreen extends StatelessWidget {
  const DevLauncherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget button(String label, String route) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: SizedBox(
          width: 280,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, route),
            child: Text(label),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Developer shortcuts')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            button('Open Driver (temporary)', AppRoutes.driverHome),
            button('Open Guard (temporary)', AppRoutes.guardConsole),
            button('Open Head Security (temporary)', AppRoutes.headOverview),
          ],
        ),
      ),
    );
  }
}