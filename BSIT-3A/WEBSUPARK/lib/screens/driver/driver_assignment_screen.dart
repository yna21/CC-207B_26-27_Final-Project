import 'package:flutter/material.dart';
import 'package:websupark/screens/driver/driver_common.dart';
import 'package:websupark/theme/app_colors.dart';
import 'package:websupark/widgets/status_chip.dart';

// ---------------------------------------------------------------------------
// SAMPLE DATA (layout only)
// TODO: replace with repository data
// ---------------------------------------------------------------------------
const String _areaName = 'AREA A'; // TODO: replace with repository data
const String _parkingNumber = 'A-025'; // TODO: replace with repository data
const String _passName = 'Blue Pass'; // TODO: replace with repository data
const String _passCode = 'BLUE-025'; // TODO: replace with repository data
const String _locationName = 'North Campus · Area A'; // TODO: replace with repository data
const String _passValidUntil = 'March 31, 2027'; // TODO: replace with repository data
const int _openSpaces = 8; // TODO: replace with repository data
const int _totalSpaces = 50; // TODO: replace with repository data

/// How one parking slot looks on the map.
enum _SlotState { yours, available, occupied }

class _Slot {
  const _Slot(this.id, this.state);

  final String id;
  final _SlotState state;
}

// TODO: replace with repository data
const List<_Slot> _topRow = [
  _Slot('A-021', _SlotState.occupied),
  _Slot('A-022', _SlotState.available),
  _Slot('A-023', _SlotState.occupied),
  _Slot('A-024', _SlotState.available),
  _Slot('A-025', _SlotState.yours),
];

// TODO: replace with repository data
const List<_Slot> _bottomRow = [
  _Slot('A-026', _SlotState.occupied),
  _Slot('A-027', _SlotState.available),
  _Slot('A-028', _SlotState.occupied),
  _Slot('A-029', _SlotState.available),
  _Slot('A-030', _SlotState.occupied),
];

/// D2 My Parking Assignment: assigned area, slot map and pass validity.
class DriverAssignmentScreen extends StatelessWidget {
  const DriverAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverPage(
      children: [
        DriverHeader(
          title: 'My Parking Assignment',
          subtitle: 'Your designated parking location',
          icon: Icons.help_outline,
        ),
        SizedBox(height: 16),
        // Two columns on a wide screen, one column (same order) on a phone.
        DriverColumns(
          leftFlex: 2,
          rightFlex: 3,
          left: [_AssignmentCard()],
          right: [
            DriverSectionHeader(
              title: 'Parking Map',
              action: 'Area A · $_openSpaces available',
            ),
            SizedBox(height: 10),
            _MapCard(),
            SizedBox(height: 12),
            _PassValidCard(),
          ],
        ),
      ],
    );
  }
}

/// Dark blue card: assigned area, slot number and pass.
class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              DriverIconBox(
                icon: Icons.local_parking,
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
                      'ASSIGNED PARKING AREA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _areaName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const StatusChip(label: 'ACTIVE', kind: StatusKind.success),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: _InfoBox(
                  label: 'Assigned Parking No.',
                  value: _parkingNumber,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _InfoBox(label: 'Vehicle Pass', value: _passName),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Translucent box inside the dark card.
class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// White card with the slot map: two rows of slots and an entry lane.
class _MapCard extends StatelessWidget {
  const _MapCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.primary),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _locationName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '$_openSpaces / $_totalSpaces open',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _SlotRow(slots: _topRow),
            const SizedBox(height: 10),
            // Entry lane between the two rows.
            const Row(
              children: [
                Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  'ENTRY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                ),
                Text(
                  'ONE WAY',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const _SlotRow(slots: _bottomRow),
            const SizedBox(height: 14),
            // Wrap moves a legend item to the next line when there is no room.
            const SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  _LegendItem(color: AppColors.navy, label: 'Your space'),
                  _LegendItem(color: AppColors.successSoft, label: 'Available'),
                  _LegendItem(color: AppColors.border, label: 'Occupied'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.slots});

  final List<_Slot> slots;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final slot in slots)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _SlotTile(slot: slot),
            ),
          ),
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({required this.slot});

  final _Slot slot;

  @override
  Widget build(BuildContext context) {
    // background, text color, border color for each state
    final (background, foreground, border) = switch (slot.state) {
      _SlotState.yours => (AppColors.navy, Colors.white, AppColors.navy),
      _SlotState.available => (
          AppColors.successSoft,
          AppColors.success,
          AppColors.success,
        ),
      _SlotState.occupied => (
          AppColors.border,
          AppColors.textMuted,
          AppColors.border,
        ),
    };

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      // FittedBox shrinks the icon and text to fit when a tile gets narrow.
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (slot.state == _SlotState.yours)
                Icon(Icons.directions_car, size: 14, color: foreground),
              Text(
                slot.id,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

/// "Pass Valid Until" card at the bottom.
class _PassValidCard extends StatelessWidget {
  const _PassValidCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            DriverIconBox(icon: Icons.event_available_outlined),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pass Valid Until',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  SizedBox(height: 2),
                  Text(
                    _passValidUntil,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _passCode,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
