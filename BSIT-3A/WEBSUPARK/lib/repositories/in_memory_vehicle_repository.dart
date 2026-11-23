import 'package:websupark/data/sample_vehicles.dart';
import 'package:websupark/models/driver.dart';
import 'package:websupark/models/vehicle.dart';
import 'package:websupark/models/vehicle_pass.dart';
import 'package:websupark/models/vehicle_record.dart';
import 'package:websupark/repositories/vehicle_repository.dart';

/// Keeps the sample data in memory. Used until the Firestore version exists.
class InMemoryVehicleRepository implements VehicleRepository {
  InMemoryVehicleRepository({
    List<Driver>? drivers,
    List<Vehicle>? vehicles,
    List<VehiclePass>? passes,
    this.latency = Duration.zero,
  })  : _drivers = {for (final d in drivers ?? sampleDrivers) d.id: d},
        _vehicles = {for (final v in vehicles ?? sampleVehicles) v.id: v},
        _passesByNumber = {
          for (final p in passes ?? sampleVehiclePasses) p.passNumber: p,
        };

  /// Artificial delay, so loading states can be seen during development.
  final Duration latency;

  final Map<String, Driver> _drivers;
  final Map<String, Vehicle> _vehicles;
  final Map<String, VehiclePass> _passesByNumber;

  @override
  Future<VehicleRecord?> findByPassNumber(String passNumber) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);

    final pass = _passesByNumber[passNumber];
    if (pass == null) return null;
    final vehicle = _vehicles[pass.vehicleId];
    if (vehicle == null) return null;
    final driver = _drivers[vehicle.driverId];
    if (driver == null) return null;

    return VehicleRecord(driver: driver, vehicle: vehicle, pass: pass);
  }
}