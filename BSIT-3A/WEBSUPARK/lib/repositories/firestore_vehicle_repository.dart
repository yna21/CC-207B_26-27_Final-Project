
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:websupark/models/driver.dart';
import 'package:websupark/models/pass_type.dart';
import 'package:websupark/models/vehicle.dart';
import 'package:websupark/models/vehicle_pass.dart';
import 'package:websupark/models/vehicle_record.dart';
import 'package:websupark/repositories/vehicle_repository.dart';

class FirestoreVehicleRepository implements VehicleRepository {
  FirestoreVehicleRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<VehicleRecord?> findByPassNumber(String passNumber) async {
    // 1. Find the vehicle pass.
    final passSnapshot = await _firestore
        .collection('vehicle_passes')
        .doc(passNumber.trim())
        .get();

    if (!passSnapshot.exists) return null;

    final passData = passSnapshot.data()!;

    // 2. Retrieve the vehicle linked to the pass.
    final vehicleId = passData['vehicleId'] as String;

    final vehicleSnapshot = await _firestore
        .collection('vehicles')
        .doc(vehicleId)
        .get();

    if (!vehicleSnapshot.exists) return null;

    final vehicleData = vehicleSnapshot.data()!;

    // 3. Retrieve the driver linked to the vehicle.
    final driverId = vehicleData['driverId'] as String;

    final driverSnapshot = await _firestore
        .collection('drivers')
        .doc(driverId)
        .get();

    if (!driverSnapshot.exists) return null;

    final driverData = driverSnapshot.data()!;

    // 4. Convert Firestore documents into existing models.
    final driver = Driver(
      id: driverSnapshot.id,
      fullName: driverData['fullName'] as String,
      mobileNumber: driverData['mobileNumber'] as String,
      isSample: driverData['isSample'] as bool? ?? false,
    );

    final vehicle = Vehicle(
      id: vehicleSnapshot.id,
      plateNumber: vehicleData['plateNumber'] as String,
      makeModel: vehicleData['makeModel'] as String,
      color: vehicleData['color'] as String,
      driverId: driverId,
    );

    final pass = VehiclePass(
      passNumber: passSnapshot.id,
      vehicleId: vehicleId,
      passType: PassType.values.byName(
        passData['passType'] as String,
      ),
      assignedAreaId: passData['assignedAreaId'] as String?,
      assignedSlot: passData['assignedSlot'] as String?,
      validUntil: (passData['validUntil'] as Timestamp).toDate(),
      status: PassStatus.values.byName(
        passData['status'] as String,
      ),
    );

    return VehicleRecord(
      driver: driver,
      vehicle: vehicle,
      pass: pass,
    );
  }
}
