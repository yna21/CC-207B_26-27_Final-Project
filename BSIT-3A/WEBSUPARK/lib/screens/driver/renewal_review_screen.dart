import 'package:flutter/material.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/screens/driver/driver_common.dart';
import 'package:websupark/screens/driver/renewal_common.dart';
import 'package:websupark/theme/app_colors.dart';

// The three renewal steps. After submitting, they are removed from the
// navigation stack so "Back" cannot return to a form that was already sent.
const Set<String> _renewalStepRoutes = {
  AppRoutes.driverRenewalPayment,
  AppRoutes.driverRenewalDetails,
  AppRoutes.driverRenewalReview,
};

/// Renewal step 3 of 3: review the details and confirm.
/// "Submit renewal" stays disabled until the checkbox is ticked.
class RenewalReviewScreen extends StatefulWidget {
  const RenewalReviewScreen({super.key});

  @override
  State<RenewalReviewScreen> createState() => _RenewalReviewScreenState();
}

class _RenewalReviewScreenState extends State<RenewalReviewScreen> {
  bool _confirmed = false;

  void _submit() {
    // TODO: send the renewal request to the repository
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.driverRenewalSubmitted,
      // Keep removing routes until one that is NOT a renewal step is found.
      (route) => !_renewalStepRoutes.contains(route.settings.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RenewalScaffold(
      title: 'Vehicle Pass Renewal',
      subtitle: 'Step 3 of 3',
      icon: Icons.refresh,
      step: 3,
      children: [
        const RenewalHeading(
          title: 'Review your renewal',
          subtitle: 'Make sure the information below is correct before submitting.',
        ),
        const SizedBox(height: 18),
        // Two columns on a wide screen, one column (same order) on a phone.
        DriverColumns(
          gap: 10,
          left: [
            const RenewalRowsCard(
              rows: [
                RenewalRow('Vehicle', renewalVehicle),
                RenewalRow('Plate number', renewalPlate),
                RenewalRow('Current pass', renewalPass),
                RenewalRow('Valid until', renewalValidUntil),
                RenewalRow('Payment', 'At Cashier'),
                RenewalRow('Renewal fee', renewalFee),
              ],
            ),
          ],
          right: [
            Row(
              children: [
                Checkbox(
                  value: _confirmed,
                  visualDensity: VisualDensity.compact,
                  onChanged: (value) => setState(() => _confirmed = value ?? false),
                ),
                const Expanded(
                  child: Text(
                    'I confirm that the information provided is accurate and complete.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmed ? _submit : null,
                child: const Text('Submit renewal'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
