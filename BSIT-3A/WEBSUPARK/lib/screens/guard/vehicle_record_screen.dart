import 'package:flutter/material.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/screens/guard/data/guard_log.dart';
import 'package:websupark/screens/guard/data/sample_guard_data.dart';
import 'package:websupark/screens/guard/guard_vehicle.dart';
import 'package:websupark/screens/guard/models/guard_case.dart';
import 'package:websupark/screens/guard/widgets/guard_colors.dart';
import 'package:websupark/screens/guard/widgets/guard_widgets.dart';
import 'package:websupark/theme/app_colors.dart';

class VehicleRecordScreen extends StatelessWidget {
  final GuardVehicle record;

  const VehicleRecordScreen({super.key, required this.record});

  /// Opens Verify Parking. That screen saves the check to "Recent checks".
  void _verify(BuildContext context) {
    // TODO: replace with the real beacon / GPS reading.
    Navigator.pushNamed(
      context,
      AppRoutes.guardVerifyParking,
      arguments: GuardCase(record: record, check: newParkingCheckFor(record)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportedToday = GuardLog.instance.violationsFor(record.plate).length;
    final inside = hasOpenEntry(record);
    final lastChecked = GuardLog.instance.lastCheckTimeFor(record.plate);

    return Scaffold(
      appBar: GuardAppBar(
          title: 'Vehicle Record', subtitle: 'PASS ${record.passNumber}'),
      body: SafeArea(
        child: ScreenBody(
          bottom: ElevatedButton.icon(
            onPressed: () => _verify(context),
            icon: const Icon(Icons.location_on_outlined, size: 20),
            label: const Text('Verify Parking Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56)),
          ),
          children: [
            _StatusBanner(record: record),
            const SizedBox(height: 14),
            SectionCard(
              title: 'VEHICLE INFORMATION',
              child: Column(
                children: [
                  DetailRow("Driver's name", record.driverName),
                  DetailRow('Mobile number', record.mobile),
                  DetailRow('Vehicle number', record.plate,
                      valueStyle: monoStyle.copyWith(fontSize: 14)),
                  DetailRow('Vehicle color', record.vehicleColor),
                  DetailRow('Vehicle pass number', record.passNumber,
                      valueStyle: monoStyle.copyWith(fontSize: 14)),
                  DetailRow('Assigned parking', record.assignedAreaLabel,
                      valueStyle: monoStyle.copyWith(fontSize: 13)),
                  DetailRow('Pass type', record.passType.label),
                  DetailRow('Pass color', record.passType.colorName),
                  DetailRow('Pass expiration', record.passExpiry),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              title: 'SECURITY INFORMATION',
              child: Column(
                children: [
                  DetailRow(
                    'Previous violations',
                    record.previousViolationsLabel,
                    valueStyle: TextStyle(
                      fontSize: 14,
                      color: record.previousViolationCount > 0
                          ? GuardColors.warningText
                          : AppColors.textPrimary,
                    ),
                  ),
                  DetailRow(
                    'Current violation',
                    reportedToday == 0
                        ? 'None reported'
                        : '$reportedToday reported this shift',
                    valueStyle: TextStyle(
                      fontSize: 14,
                      color: reportedToday == 0
                          ? AppColors.success
                          : GuardColors.warningText,
                    ),
                  ),
                  DetailRow(
                    'Entry status',
                    inside ? 'Inside · open entry' : 'No open entry',
                    valueStyle: TextStyle(
                      fontSize: 14,
                      color: inside ? AppColors.success : GuardColors.warningText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // IntrinsicHeight lets both tiles share the same height.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.event_available_outlined,
                      caption: 'VALID UNTIL',
                      value: record.passExpiry,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.schedule,
                      caption: 'LAST CHECKED',
                      value: lastChecked == null
                          ? 'Not checked today'
                          : 'Today · $lastChecked',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Guidelines, Rules and Regulations no. 5.
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.action.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.action),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'A valid pass is displayed on the passenger side (right-hand) of the front windshield and can be read from outside.',
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final GuardVehicle record;
  const _StatusBanner({required this.record});

  @override
  Widget build(BuildContext context) {
    final valid = record.isPassValid;
    final Color strong = valid ? AppColors.success : AppColors.danger;
    final Color soft = valid ? AppColors.successSoft : AppColors.dangerSoft;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: strong.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                color: valid ? GuardColors.successDark : AppColors.danger,
                shape: BoxShape.circle),
            child: Icon(valid ? Icons.verified_outlined : Icons.block,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    Text(record.plate, style: monoStyle.copyWith(fontSize: 22)),
                    Text(
                      '● ${record.passStatusLabel.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: strong,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${record.driverName} · ${record.vehicleSummary}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: strong,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String caption;
  final String value;

  const _InfoTile(
      {required this.icon, required this.caption, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.action, size: 20),
            const SizedBox(height: 10),
            CaptionLabel(caption),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}