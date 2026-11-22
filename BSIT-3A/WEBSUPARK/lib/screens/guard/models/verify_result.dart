import 'package:websupark/screens/guard/models/parking_check.dart';
import 'package:websupark/screens/guard/guard_vehicle.dart';

/// The three outcomes of verifyParking(vehicleId, detectedAreaId).
enum VerifyResult { cleared, mismatch, noOpenEntry }

/// Ordinary program logic (not AI): the detected area against the assigned area.
VerifyResult verifyParking(GuardVehicle record, ParkingCheck check) {
  if (!check.hasOpenEntry) return VerifyResult.noOpenEntry;
  final assigned = record.assignedArea;
  return (assigned != null && assigned.id == check.detectedArea.id)
      ? VerifyResult.cleared
      : VerifyResult.mismatch;
}