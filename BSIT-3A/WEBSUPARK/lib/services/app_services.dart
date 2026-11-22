
import 'package:websupark/config/firebase_config.dart';
import 'package:websupark/repositories/auth_repository.dart';
import 'package:websupark/repositories/firebase_auth_repository.dart';
import 'package:websupark/repositories/firestore_vehicle_repository.dart';
import 'package:websupark/repositories/in_memory_auth_repository.dart';
import 'package:websupark/repositories/in_memory_vehicle_repository.dart';
import 'package:websupark/repositories/vehicle_repository.dart';

class AppServices {
  AppServices._();

  static VehicleRepository vehicles = FirebaseConfig.isConfigured
      ? FirestoreVehicleRepository()
      : InMemoryVehicleRepository();

  static AuthRepository auth = FirebaseConfig.isConfigured
      ? FirebaseAuthRepository()
      : InMemoryAuthRepository(
          vehicles: vehicles,
          latency: const Duration(milliseconds: 400),
        );
}
