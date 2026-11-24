
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:websupark/screens/guard/models/vehicle_check.dart';
import 'package:websupark/repositories/vehicle_check_repository.dart';

class FirestoreVehicleCheckRepository
    implements VehicleCheckRepository {
  FirestoreVehicleCheckRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _checks =>
      _firestore.collection('vehicle_checks');

  @override
  Future<void> save(
    VehicleCheck check, {
    required String guardUid,
    required String guardName,
  }) async {
    await _checks.doc(check.id).set({
      'plate': check.plate,
      'time': check.time,
      'location': check.location,
      'status': check.status.name,
      'incidentRef': check.incidentRef,
      'driverName': check.driverName,
      'passTypeLabel': check.passTypeLabel,
      'guardUid': guardUid,
      'guardName': guardName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<VehicleCheck>> getAll() async {
    final snapshot = await _checks
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return VehicleCheck(
        id: doc.id,
        plate: data['plate'] as String,
        time: data['time'] as String,
        location: data['location'] as String,
        status: CheckStatus.values.byName(data['status'] as String),
        incidentRef: data['incidentRef'] as String?,
        driverName: data['driverName'] as String?,
        passTypeLabel: data['passTypeLabel'] as String?,
      );
    }).toList();
  }
}
