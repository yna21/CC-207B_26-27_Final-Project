import 'package:flutter/material.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/services/app_services.dart';
import 'package:websupark/theme/app_colors.dart';

/// Asks the guard to confirm, signs out, and returns to the sign-in page.
/// Every guard screen is removed from the navigation stack, so the Back
/// button cannot return to the guard screens afterwards.
Future<void> confirmGuardSignOut(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Sign out?'),
      content: const Text('You will return to the sign-in page.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          child: const Text('Sign out'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  // ASSUMPTION: AuthRepository has signOut(). See the note in the chat if
  // your repository uses a different name.
  await AppServices.auth.signOut();

  if (!context.mounted) return;

  // rootNavigator: the guard screens live in the Navigator inside the shell.
  // Signing out must clear the whole app, not only that inner Navigator.
  Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
    AppRoutes.login,
    (_) => false,
  );
}