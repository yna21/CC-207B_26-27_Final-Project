import 'package:websupark/models/parking_area.dart';

/// Where the guard found the vehicle (simulated beacon / GPS reading).
class ParkingCheck {
  final ParkingArea detectedArea;
  final String beacon;
  final double accuracyMeters;
  final String checkedAt; // "10:42:16"
  final String observedAt; // "Sep 30 · 10:42"

  /// false = the vehicle has no open EntryExitRecord ("no open entry").
  final bool hasOpenEntry;

  const ParkingCheck({
    required this.detectedArea,
    required this.beacon,
    required this.accuracyMeters,
    required this.checkedAt,
    required this.observedAt,
    this.hasOpenEntry = true,
  });
}