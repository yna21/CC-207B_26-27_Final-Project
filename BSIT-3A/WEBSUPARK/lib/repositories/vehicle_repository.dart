import 'package:websupark/models/vehicle_record.dart';

/// The one place screens ask for vehicle data. Screens depend on this
/// class only, so the in-memory version can later be swapped for a
/// Firestore version without changing any screen.
abstract class VehicleRepository {
  /// Finds the vehicle, owner and pass for a pass number such as '00921'.
  /// Returns null when no vehicle has that pass number.
  Future<VehicleRecord?> findByPassNumber(String passNumber);
}