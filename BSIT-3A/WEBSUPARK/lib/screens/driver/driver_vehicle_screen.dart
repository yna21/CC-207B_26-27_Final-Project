import 'package:flutter/material.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/screens/driver/driver_common.dart';
import 'package:websupark/theme/app_colors.dart';
import 'package:websupark/widgets/status_chip.dart';

// ---------------------------------------------------------------------------
// SAMPLE DATA (layout only)
// TODO: replace with repository data
// ---------------------------------------------------------------------------
const String _vehicleName = 'White Toyota Vios'; // TODO: replace with repository data
const String _plateNumber = 'ABC-1234'; // TODO: replace with repository data
const String _passNumber = 'BLUE-025'; // TODO: replace with repository data
const String _passExpiration = 'March 31, 2027'; // TODO: replace with repository data

class _Detail {
  const _Detail(this.label, this.value);

  final String label;
  final String value;
}

// TODO: replace with repository data
const List<_Detail> _details = [
  _Detail('Name', 'Yana'),
  _Detail('Mobile number', '+63 917 555 0148'),
  _Detail('Vehicle plate number', _plateNumber),
  _Detail('Vehicle color', 'White'),
  _Detail('Vehicle type', 'Toyota Vios'),
  _Detail('Vehicle pass number', _passNumber),
  _Detail('Pass type', 'Blue Pass'),
  _Detail('Pass expiration', _passExpiration),
  _Detail('Assigned parking area', 'Parking Area A'),
  _Detail('Assigned parking number', 'A-025'),
];

/// D5 My Vehicle: registration details and the pass renewal entry point.
class DriverVehicleScreen extends StatelessWidget {
  const DriverVehicleScreen({super.key});

  // Opens step 1 of the renewal flow (see renewal_payment_screen.dart).
  void _startRenewal(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.driverRenewalPayment);
  }

  @override
  Widget build(BuildContext context) {
    return DriverPage(
      children: [
        // The prototype shows a pencil icon but no edit screen,
        // so the icon does nothing for now.
        const DriverHeader(
          title: 'My Vehicle',
          subtitle: 'Registered driver and pass details',
          icon: Icons.edit_outlined,
        ),
        const SizedBox(height: 16),
        // Two columns on a wide screen, one column (same order) on a phone.
        DriverColumns(
          left: const [
            _VehicleBanner(),
            SizedBox(height: 20),
            DriverSectionHeader(title: 'Registration Details'),
            SizedBox(height: 10),
            _DetailsCard(),
          ],
          right: [
            // "Learn more" has no screen in the prototype, so it does nothing yet.
            const DriverSectionHeader(
              title: 'Vehicle Pass Renewal',
              action: 'Learn more',
            ),
            const SizedBox(height: 10),
            _RenewalTile(onTap: () => _startRenewal(context)),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // The theme gives every button the blue style; this one is red.
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                onPressed: () => _startRenewal(context),
                child: const Text(
                  'RENEW VEHICLE PASS',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Dark blue card at the top: vehicle, plate, pass and Active chip.
class _VehicleBanner extends StatelessWidget {
  const _VehicleBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          DriverIconBox(
            icon: Icons.directions_car_outlined,
            iconColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            size: 38,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _vehicleName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '$_plateNumber  ·  $_passNumber',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          const StatusChip(label: 'ACTIVE', kind: StatusKind.success),
        ],
      ),
    );
  }
}

/// White card listing every registration detail, one per row.
class _DetailsCard extends StatelessWidget {
  const _DetailsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          children: [
            for (var i = 0; i < _details.length; i++) ...[
              _DetailRow(detail: _details[i]),
              // A thin line between rows, but not after the last one.
              if (i != _details.length - 1)
                const Divider(height: 1, color: AppColors.border),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.detail});

  final _Detail detail;

  @override
  Widget build(BuildContext context) {
    // DriverInfoRow puts the value under the label on very narrow screens.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: DriverInfoRow(label: detail.label, value: detail.value),
    );
  }
}

/// Pale blue tile explaining when renewal opens.
class _RenewalTile extends StatelessWidget {
  const _RenewalTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.autorenew, size: 20, color: AppColors.primary),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Renew before $_passExpiration',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Renewal opens 30 days before expiration. Bring your current pass and registration.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.3,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
