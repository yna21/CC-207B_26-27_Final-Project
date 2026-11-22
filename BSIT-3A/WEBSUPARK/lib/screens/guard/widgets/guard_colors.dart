import 'package:flutter/material.dart';

/// Two extra colors used only by the guard screens.
/// They live here so the team's shared AppColors file stays unchanged.
class GuardColors {
  GuardColors._();

  /// Readable dark amber for text on AppColors.warningSoft.
  static const Color warningText = Color(0xFF7A4B00);

  /// Dark green for the submit button and the success check.
  static const Color successDark = Color(0xFF0F5C3C);
}