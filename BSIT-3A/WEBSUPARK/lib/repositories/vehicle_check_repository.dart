
import 'package:websupark/screens/guard/models/vehicle_check.dart';

abstract class VehicleCheckRepository {
  Future<void> save(VehicleCheck check, {
    required String guardUid,
    required String guardName,
  });

  Future<List<VehicleCheck>> getAll();
}
