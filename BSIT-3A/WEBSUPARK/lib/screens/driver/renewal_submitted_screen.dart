import 'package:flutter/material.dart';
import 'package:websupark/screens/driver/renewal_common.dart';
import 'package:websupark/theme/app_colors.dart';
import 'package:websupark/widgets/status_chip.dart';

const String _referenceNumber = 'RN-2027-0148'; // TODO: replace with repository data

/// Confirmation shown after the renewal request is submitted.
class RenewalSubmittedScreen extends StatelessWidget {
  const RenewalSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RenewalScaffold(
      title: 'Renewal Submitted',
      subtitle: 'Your application has been received',
      icon: Icons.receipt_long_outlined,
      // A narrow centered column looks best for a confirmation message.
      contentMaxWidth: 520,
      // No step: the progress bar is only for steps 1 to 3.
      children: [
        const SizedBox(height: 16),
        // Green circle with a white check mark.
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 34, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Renewal request submitted',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            children: [
              TextSpan(text: 'Your reference number is '),
              TextSpan(
                text: _referenceNumber,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: ". We'll notify you when your renewed pass is ready.",
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const RenewalRowsCard(
          rows: [
            // NOTE: the prototype says "Bank transfer" here, but the flow
            // above only offers the Admin Cashier. Check with the team.
            RenewalRow('Payment method', 'At Cashier'),
            RenewalRow('Amount due', renewalFee),
            RenewalRow(
              'Status',
              'FOR VERIFICATION',
              trailing: StatusChip(
                label: 'FOR VERIFICATION',
                kind: StatusKind.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            // The renewal steps were removed from the stack on submit,
            // so going back reveals the driver tabs, still on Vehicle.
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to My Vehicle'),
          ),
        ),
      ],
    );
  }
}
