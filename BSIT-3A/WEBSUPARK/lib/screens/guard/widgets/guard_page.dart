import 'package:flutter/material.dart';

/// Centers a guard page and limits how wide it can grow, so forms and cards
/// never stretch across a very wide screen. Used for every page that opens
/// inside the guard shell (named routes and pushed pages alike).
class GuardPage extends StatelessWidget {
  const GuardPage({super.key, required this.child, this.maxWidth = 720});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}