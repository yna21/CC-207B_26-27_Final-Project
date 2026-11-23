import 'package:flutter/material.dart';
import 'package:websupark/screens/head_security/head_sample_data.dart';
import 'package:websupark/screens/head_security/head_widgets.dart';
import 'package:websupark/theme/app_colors.dart';

class VehicleDatabaseScreen extends StatefulWidget {
  const VehicleDatabaseScreen({super.key});

  @override
  State<VehicleDatabaseScreen> createState() => _VehicleDatabaseScreenState();
}

class _VehicleDatabaseScreenState extends State<VehicleDatabaseScreen> {
  final ScrollController _tableController = ScrollController();

  String _query = '';
  String? _passType; // null means "All pass types"
  String _entry = 'All'; // All, Inside or Outside

  bool _hasMismatch(SampleVehicle v) => sampleViolations.any(
    (x) => x.plate == v.plate && x.status != ViolationStatus.resolved,
  );

  (String, Color) _status(SampleVehicle v) {
    if (v.expired) return ('Expired', AppColors.danger);
    if (!v.inside) return ('Outside', AppColors.textMuted);
    if (_hasMismatch(v)) return ('Inside · Mismatch', AppColors.warning);
    return ('Inside · Authorized', AppColors.success);
  }

  List<SampleVehicle> get _results {
    final q = _query.trim().toLowerCase();
    return sampleVehicles.where((v) {
      final matchesText =
          q.isEmpty ||
          v.plate.toLowerCase().contains(q) ||
          v.driver.toLowerCase().contains(q) ||
          v.passNumber.contains(q) ||
          v.areaId.toLowerCase().contains(q);
      final matchesType = _passType == null || v.passType == _passType;
      final matchesEntry = _entry == 'All' || (_entry == 'Inside') == v.inside;
      return matchesText && matchesType && matchesEntry;
    }).toList();
  }

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final inside = sampleVehicles.where((v) => v.inside).length;
    final expiring = sampleVehicles.where((v) => v.expiringSoon).length;
    final expired = sampleVehicles.where((v) => v.expired).length;

    // Rows with an open violation are highlighted in amber.
    final warningRows = <int>{
      for (var i = 0; i < results.length; i++)
        if (_hasMismatch(results[i])) i,
    };

    return HeadPage(
      eyebrow: 'REGISTRY · ACCESS CONTROL',
      title: 'Vehicle Database',
      subtitle: 'Registered vehicles, passes and parking assignments',
      children: [
        StatRow(
          cards: [
            StatCard(
              icon: Icons.storage_outlined,
              label: 'REGISTERED VEHICLES',
              value: '${sampleVehicles.length}',
            ),
            StatCard(
              icon: Icons.login,
              iconColor: AppColors.success,
              label: 'CURRENTLY INSIDE',
              value: '$inside',
            ),
            StatCard(
              icon: Icons.event_outlined,
              iconColor: AppColors.warning,
              label: 'EXPIRING IN 30 DAYS',
              value: '$expiring',
              note: 'review passes',
            ),
            StatCard(
              icon: Icons.block,
              iconColor: AppColors.danger,
              label: 'EXPIRED PASSES',
              value: '$expired',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 260,
              child: HeadSearchField(
                hint: 'Search plate, driver, pass number, area...',
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            HeadDropdown<String>(
              value: _entry,
              width: 130,
              items: const [
                DropdownMenuItem(value: 'All', child: Text('Entry: All')),
                DropdownMenuItem(value: 'Inside', child: Text('Inside')),
                DropdownMenuItem(value: 'Outside', child: Text('Outside')),
              ],
              onChanged: (value) => setState(() => _entry = value ?? 'All'),
            ),
            HeadDropdown<String?>(
              value: _passType,
              width: 240,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All pass types'),
                ),
                for (final t in samplePassTypes)
                  DropdownMenuItem<String?>(
                    value: t,
                    child: Text(t, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (value) => setState(() => _passType = value),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${results.length} record(s)',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
        ),
        const SizedBox(height: 8),
        Scrollbar(
          controller: _tableController,
          thumbVisibility: true,
          scrollbarOrientation: ScrollbarOrientation.bottom,
          child: SingleChildScrollView(
            controller: _tableController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: 900,
              child: HeadTable(
                columns: const [
                  HeadColumn('Driver information', flex: 3),
                  HeadColumn('Vehicle information', flex: 3),
                  HeadColumn('Pass number', flex: 2),
                  HeadColumn('Parking', flex: 1),
                  HeadColumn('Expiration', flex: 2),
                  HeadColumn('Entry status', flex: 3),
                  HeadColumn('Last activity', flex: 3),
                ],
                warningRows: warningRows,
                emptyText: 'No vehicles match your search.',
                rows: [
                  for (final v in results)
                    [
                      TwoLineCell(v.driver, v.mobile),
                      TwoLineCell(v.plate, v.makeModel, mono: true),
                      Text(v.passNumber, style: monoStyle),
                      Text(v.areaId, style: monoStyle),
                      Text(
                        formatDate(v.validUntil),
                        style: TextStyle(
                          fontSize: 12.5,
                          color: v.expired
                              ? AppColors.danger
                              : AppColors.textPrimary,
                        ),
                      ),
                      StatusPill(label: _status(v).$1, color: _status(v).$2),
                      Text(
                        v.lastActivity,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
