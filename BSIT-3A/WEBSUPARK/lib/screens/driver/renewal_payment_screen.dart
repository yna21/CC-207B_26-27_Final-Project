import 'package:flutter/material.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/screens/driver/driver_common.dart';
import 'package:websupark/screens/driver/renewal_common.dart';
import 'package:websupark/theme/app_colors.dart';

/// Renewal step 1 of 3: choose how to pay.
/// Only one method exists (Admin Cashier), so the driver taps it to select it
/// and "Continue" stays disabled until then.
class RenewalPaymentScreen extends StatefulWidget {
  const RenewalPaymentScreen({super.key});

  @override
  State<RenewalPaymentScreen> createState() => _RenewalPaymentScreenState();
}

class _RenewalPaymentScreenState extends State<RenewalPaymentScreen> {
  bool _cashierSelected = false;

  @override
  Widget build(BuildContext context) {
    return RenewalScaffold(
      title: 'Vehicle Pass Renewal',
      subtitle: 'Step 1 of 3',
      icon: Icons.refresh,
      step: 1,
      children: [
        const RenewalHeading(
          title: 'Pay at Cashier',
          subtitle:
              'Select your preferred payment method for the $renewalFee renewal fee.',
        ),
        const SizedBox(height: 28),
        // Two columns on a wide screen, one column (same order) on a phone.
        DriverColumns(
          gap: 12,
          left: [
            _PaymentOption(
              label: 'Pay directly at the Admin Cashier.',
              selected: _cashierSelected,
              onTap: () => setState(() => _cashierSelected = !_cashierSelected),
            ),
          ],
          right: [
            const RenewalRowsCard(
              rows: [RenewalRow('Renewal fee', renewalFee)],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // null disables the button until a method is selected.
                onPressed: _cashierSelected
                    ? () => Navigator.pushNamed(
                          context,
                          AppRoutes.driverRenewalDetails,
                        )
                    : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A tappable payment method card with a round selector on the right.
class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      // The blue outline shows which option is selected.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const DriverIconBox(icon: Icons.person_outline, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              // Round selector: empty ring, or ring with a dot when selected.
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
