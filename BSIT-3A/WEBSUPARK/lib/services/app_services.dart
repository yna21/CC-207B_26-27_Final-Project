import 'package:websupark/repositories/auth_repository.dart';
import 'package:websupark/repositories/in_memory_auth_repository.dart';
import 'package:websupark/repositories/in_memory_vehicle_repository.dart';
import 'package:websupark/repositories/vehicle_repository.dart';

class AppServices {
  AppServices._();

  static VehicleRepository vehicles = InMemoryVehicleRepository();

  static AuthRepository auth = InMemoryAuthRepository(
    vehicles: vehicles,
    latency: const Duration(milliseconds: 400),
  );
}