import 'dart:async';

import 'package:flutter/material.dart';
import 'package:websupark/screens/guard/models/vehicle_check.dart';
import 'package:websupark/screens/head_security/head_sample_data.dart';
import 'package:websupark/screens/head_security/head_widgets.dart';
import 'package:websupark/services/app_services.dart';
import 'package:websupark/theme/app_colors.dart';

/// "Real-time field feed" on H1: shows the vehicle checks that guards saved
/// in Firestore. It reloads every 10 seconds and has a Refresh button.
class GuardActivityFeed extends StatefulWidget {
  const GuardActivityFeed({super.key});

  @override
  State<GuardActivityFeed> createState() => _GuardActivityFeedState();
}

class _GuardActivityFeedState extends State<GuardActivityFeed> {
  List<VehicleCheck>? _checks; // null until the first load finishes
  Object? _error; // the last error, if loading failed
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    // Quietly reload every 10 seconds so new guard records appear.
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Reads all vehicle checks from the shared repository.
  Future<void> _load({bool showSpinner = false}) async {
    if (showSpinner) setState(() => _loading = true);
    try {
      final checks = await AppServices.vehicleChecks.getAll();
      if (!mounted) return;
      setState(() {
        _checks = checks;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  /// Turns one saved vehicle check into a line of the existing feed design.
  SampleActivity _toActivity(VehicleCheck c) {
    final who = c.driverName ?? 'Unknown driver';
    final ref = c.incidentRef == null ? '' : ' · ${c.incidentRef}';
    final detail = '${c.plate} · ${c.location} · $who$ref';
    return switch (c.status) {
      CheckStatus.cleared => SampleActivity(
          c.time, 'Vehicle cleared', detail, ActivityKind.verified, 'Cleared'),
      CheckStatus.mismatch => SampleActivity(c.time, 'Parking mismatch found',
          detail, ActivityKind.mismatch, 'Needs review'),
      CheckStatus.reported => SampleActivity(c.time, 'Violation reported',
          detail, ActivityKind.mismatch, 'Reported'),
      CheckStatus.noEntry => SampleActivity(
          c.time, 'No entry on record', detail, ActivityKind.scan, 'Review'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Panel(
      title: 'Real-time field feed',
      caption: 'Guard activity',
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    final checks = _checks;

    // First load still running.
    if (_loading && checks == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Loading failed and there is nothing older to show.
    if (_error != null && checks == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Could not load guard activity.',
            style: TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_error',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          TextButton(
            onPressed: () => _load(showSpinner: true),
            child: const Text('Try again'),
          ),
        ],
      );
    }

    // Loaded, but no guard has saved a check yet.
    if (checks == null || checks.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No guard activity yet. Checks saved by guards appear here.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          TextButton(
            onPressed: () => _load(showSpinner: true),
            child: const Text('Refresh'),
          ),
        ],
      );
    }

    return Column(
      children: [
        for (final c in checks) ActivityTile(_toActivity(c)),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _load(showSpinner: true),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh'),
          ),
        ),
      ],
    );
  }
}