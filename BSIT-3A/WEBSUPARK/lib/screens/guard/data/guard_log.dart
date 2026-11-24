import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:websupark/screens/guard/data/sample_guard_data.dart';
import 'package:websupark/screens/guard/models/guard_case.dart';
import 'package:websupark/screens/guard/models/past_violation.dart';
import 'package:websupark/screens/guard/models/vehicle_check.dart';
import 'package:websupark/screens/guard/utils/time_format.dart';

/// In-memory record of what the guard did in this session:
/// the "Recent checks" list, reported incidents and new violations.
/// TODO: later replace with the shared repository / Firestore.
class GuardLog extends ChangeNotifier {
  GuardLog._() {
    _checks.addAll(sampleRecentChecks);
  }

  static final GuardLog instance = GuardLog._();

  final List<VehicleCheck> _checks = [];
  final Map<String, List<PastViolation>> _violations = {};

  /// The full case (vehicle, reading, and the report once submitted) of each
  /// check made in this session, by check id. Lets a tapped card open its
  /// details.
  final Map<String, GuardCase> _cases = {};
  int _checkSeq = 0;
  int _incidentSeq = 182;

  /// Listeners are told after the current frame, so a screen can log a check
  /// from initState without causing "setState during build" errors.
  void _notify() => scheduleMicrotask(notifyListeners);

  /// Newest first.
  List<VehicleCheck> get checks => List.unmodifiable(_checks);

  int get reportedCount =>
      _checks.where((c) => c.status == CheckStatus.reported).length;

  /// Adds a check at the top of "Recent checks" and returns its id.
  /// Checking the same vehicle in the same place again (same result) reuses
  /// the latest entry instead of adding a duplicate.
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
    final id = 'chk-${++_checkSeq}';
    _checks.insert(
      0,
      VehicleCheck(
        id: id,
        plate: plate,
        time: formatHm(DateTime.now()),
        location: location,
        status: status,
        driverName: driverName,
        passTypeLabel: passTypeLabel,
      ),
    );
    _notify();
    return id;
  }

  /// A submitted violation: the check becomes "REPORTED".
  void markReported(
    String? checkId, {
    required String plate,
    required String location,
    required String incidentRef,
  }) {
    final i = checkId == null ? -1 : _checks.indexWhere((c) => c.id == checkId);
    if (i >= 0) {
      _checks[i] = _checks[i]
          .copyWith(status: CheckStatus.reported, incidentRef: incidentRef);
    } else {
      _checks.insert(
        0,
        VehicleCheck(
          id: 'chk-${++_checkSeq}',
          plate: plate,
          time: formatHm(DateTime.now()),
          location: location,
          status: CheckStatus.reported,
          incidentRef: incidentRef,
        ),
      );
    }
    _notify();
  }

  /// Remembers (or updates) the case of a check. Does nothing without a
  /// check id.
  void saveCase(GuardCase guardCase) {
    final id = guardCase.checkId;
    if (id != null) _cases[id] = guardCase;
  }

  /// The saved case of a check, or null (for example the starting sample
  /// checks, which have no vehicle record behind them).
  GuardCase? caseFor(String checkId) => _cases[checkId];

  /// Time of the latest check of [plate] in this shift, or null.
  String? lastCheckTimeFor(String plate) {
    for (final c in _checks) {
      if (c.plate == plate) return c.time;
    }
    return null;
  }

  /// "INC-2026-1120-183"
  String nextIncidentRef() {
    final now = DateTime.now();
    _incidentSeq++;
    return 'INC-${now.year}-${monthDayCode(now)}-$_incidentSeq';
  }

  /// Violations reported in this session, so the next scan of the same
  /// vehicle shows them (and the offense number goes up).
  List<PastViolation> violationsFor(String plate) =>
      List.unmodifiable(_violations[plate] ?? const []);

  void addViolation(String plate, PastViolation violation) {
    (_violations[plate] ??= []).add(violation);
  }
}