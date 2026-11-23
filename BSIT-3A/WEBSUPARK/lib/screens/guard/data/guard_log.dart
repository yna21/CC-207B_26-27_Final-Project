
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:websupark/models/app_user.dart';
import 'package:websupark/screens/guard/data/sample_guard_data.dart';
import 'package:websupark/screens/guard/models/past_violation.dart';
import 'package:websupark/screens/guard/models/vehicle_check.dart';
import 'package:websupark/screens/guard/utils/time_format.dart';
import 'package:websupark/services/app_services.dart';

class GuardLog extends ChangeNotifier {
  GuardLog._() {
    _checks.addAll(sampleRecentChecks);
    unawaited(_loadChecks());
  }

  static final GuardLog instance = GuardLog._();

  final List<VehicleCheck> _checks = [];
  final Map<String, List<PastViolation>> _violations = {};

  int _incidentSeq = 182;

  void _notify() => scheduleMicrotask(notifyListeners);

  /// Newest first.
  List<VehicleCheck> get checks => List.unmodifiable(_checks);

  int get reportedCount =>
      _checks.where((c) => c.status == CheckStatus.reported).length;

  /// Loads saved checks without changing the existing screen interface.
  Future<void> _loadChecks() async {
    try {
      final savedChecks = await AppServices.vehicleChecks.getAll();

      if (savedChecks.isEmpty) return;

      // Keep checks created locally while the Firestore request was running.
      final localChecks = _checks
          .where((check) => check.id.startsWith('chk-'))
          .toList();

      _checks
        ..clear()
        ..addAll(localChecks)
        ..addAll(
          savedChecks.where(
            (saved) => !_checks.any((local) => local.id == saved.id),
          ),
        );

      _notify();
    } catch (e) {
      debugPrint('Unable to load vehicle checks: $e');
    }
  }

  /// Saves a check using the currently signed-in guard's account.
  Future<void> _persistCheck(VehicleCheck check) async {
    try {
      final user = AppServices.auth.currentUser;

      if (user == null || user.role != UserRole.guard) {
        debugPrint('Vehicle check not saved: no signed-in guard.');
        return;
      }

      await AppServices.vehicleChecks.save(
        check,
        guardUid: user.id,
        guardName: user.fullName,
      );
    } catch (e) {
      debugPrint('Unable to save vehicle check: $e');
    }
  }

  /// Adds a check immediately and saves it in the background.
  String recordCheck({
    required String plate,
    required String location,
    required CheckStatus status,
    String? driverName,
    String? passTypeLabel,
  }) {
    if (_checks.isNotEmpty) {
      final last = _checks.first;
      if (last.plate == plate &&
          last.location == location &&
          last.status == status) {
        return last.id;
      }
    }

    final check = VehicleCheck(
      id: 'chk-${DateTime.now().microsecondsSinceEpoch}',
      plate: plate,
      time: formatHm(DateTime.now()),
      location: location,
      status: status,
      driverName: driverName,
      passTypeLabel: passTypeLabel,
    );

    _checks.insert(0, check);
    _notify();

    unawaited(_persistCheck(check));

    return check.id;
  }

  /// Updates a check to REPORTED and saves the change.
  void markReported(
    String? checkId, {
    required String plate,
    required String location,
    required String incidentRef,
  }) {
    final i =
        checkId == null ? -1 : _checks.indexWhere((c) => c.id == checkId);

    late final VehicleCheck updatedCheck;

    if (i >= 0) {
      updatedCheck = _checks[i].copyWith(
        status: CheckStatus.reported,
        incidentRef: incidentRef,
      );
      _checks[i] = updatedCheck;
    } else {
      updatedCheck = VehicleCheck(
        id: 'chk-${DateTime.now().microsecondsSinceEpoch}',
        plate: plate,
        time: formatHm(DateTime.now()),
        location: location,
        status: CheckStatus.reported,
        incidentRef: incidentRef,
      );
      _checks.insert(0, updatedCheck);
    }

    _notify();
    unawaited(_persistCheck(updatedCheck));
  }

  /// Time of the latest check of [plate] in this shift, or null.
  String? lastCheckTimeFor(String plate) {
    for (final c in _checks) {
      if (c.plate == plate) return c.time;
    }
    return null;
  }

  /// Generates the next incident reference.
  String nextIncidentRef() {
    final now = DateTime.now();
    _incidentSeq++;
    return 'INC-${now.year}-${monthDayCode(now)}-$_incidentSeq';
  }

  /// Existing in-memory violation history.
  /// Firestore violation history will be integrated in the next stage.
  List<PastViolation> violationsFor(String plate) =>
      List.unmodifiable(_violations[plate] ?? const []);

  void addViolation(String plate, PastViolation violation) {
    (_violations[plate] ??= []).add(violation);
  }
}
