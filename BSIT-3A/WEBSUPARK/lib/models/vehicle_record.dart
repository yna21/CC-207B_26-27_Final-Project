import 'package:websupark/models/driver.dart';
import 'package:websupark/models/vehicle.dart';
import 'package:websupark/models/vehicle_pass.dart';

class VehicleRecord {
  const VehicleRecord({
    required this.driver,
    required this.vehicle,
    required this.pass,
  });

  final Driver driver;
  final Vehicle vehicle;
  final VehiclePass pass;
}