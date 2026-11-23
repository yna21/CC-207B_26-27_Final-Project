import 'package:flutter_test/flutter_test.dart';
import 'package:websupark/data/sample_parking_areas.dart';
import 'package:websupark/data/sample_vehicles.dart';
import 'package:websupark/repositories/in_memory_vehicle_repository.dart';

void main() {
  final repository = InMemoryVehicleRepository();

  test('finds a vehicle record by pass number', () async {
    final record = await repository.findByPassNumber('00921');
    expect(record, isNotNull);
    expect(record!.driver.fullName, 'Yana Santos');
    expect(record.vehicle.plateNumber, 'ABC-1234');
    expect(record.pass.passNumber, '00921');
  });

  test('returns null for an unknown pass number', () async {
    expect(await repository.findByPassNumber('99999'), isNull);
  });

  test('pass numbers and plate numbers are unique', () {
    final passNumbers = sampleVehiclePasses.map((p) => p.passNumber).toList();
    final plates = sampleVehicles.map((v) => v.plateNumber).toList();
    expect(passNumbers.toSet().length, passNumbers.length);
    expect(plates.toSet().length, plates.length);
  });

  test('every pass points to an existing vehicle and driver', () {
    for (final pass in sampleVehiclePasses) {
      final vehicle = sampleVehicles.firstWhere((v) => v.id == pass.vehicleId);
      expect(sampleDrivers.any((d) => d.id == vehicle.driverId), isTrue);
    }
  });

  test('assigned areas exist and allow the pass type', () {
    for (final pass in sampleVehiclePasses) {
      final areaId = pass.assignedAreaId;
      if (areaId == null) continue; // Yellow pass: no parking privilege
      final area = sampleParkingAreas.firstWhere((a) => a.id == areaId);
      expect(
        area.allowedPassTypes.contains(pass.passType),
        isTrue,
        reason: 'Pass ${pass.passNumber} is not allowed in $areaId',
      );
    }
  });

  test('pass validity depends on status and date', () async {
    final valid = (await repository.findByPassNumber('00921'))!;
    final expired = (await repository.findByPassNumber('00099'))!;
    final today = DateTime(2026, 11, 18);
    expect(valid.pass.isValidOn(today), isTrue);
    expect(expired.pass.isValidOn(today), isFalse);
  });
}
