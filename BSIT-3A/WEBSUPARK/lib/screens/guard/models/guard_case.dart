import 'dart:typed_data';

import 'package:websupark/screens/guard/models/parking_check.dart';
import 'package:websupark/screens/guard/guard_vehicle.dart';
import 'package:websupark/screens/guard/models/violation_type.dart';

/// Everything the guard flow carries from screen to screen (S3 to S6 and
/// Incident Details). Passed as the `arguments` of Navigator.pushNamed.
class GuardCase {
  final GuardVehicle record;
  final ParkingCheck check;

  /// The entry in "Recent checks" created when the parking was verified.
  final String? checkId;

  // Filled in when the report is submitted.
  final String? incidentRef;
  final String? syncedAt;
  final ViolationType? violationType;
  final int? offenseNumber;
  final String? notes;
  final List<Uint8List> photos;

  const GuardCase({
    required this.record,
    required this.check,
    this.checkId,
    this.incidentRef,
    this.syncedAt,
    this.violationType,
    this.offenseNumber,
    this.notes,
    this.photos = const [],
  });

  GuardCase copyWith({
    String? checkId,
    String? incidentRef,
    String? syncedAt,
    ViolationType? violationType,
    int? offenseNumber,
    String? notes,
    List<Uint8List>? photos,
  }) =>
      GuardCase(
        record: record,
        check: check,
        checkId: checkId ?? this.checkId,
        incidentRef: incidentRef ?? this.incidentRef,
        syncedAt: syncedAt ?? this.syncedAt,
        violationType: violationType ?? this.violationType,
        offenseNumber: offenseNumber ?? this.offenseNumber,
        notes: notes ?? this.notes,
        photos: photos ?? this.photos,
      );
}