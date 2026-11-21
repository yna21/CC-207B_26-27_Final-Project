import 'package:websupark/data/sample_parking_areas.dart';
import 'package:websupark/models/driver.dart';
import 'package:websupark/models/parking_area.dart';
import 'package:websupark/models/pass_type.dart';
import 'package:websupark/models/vehicle.dart';
import 'package:websupark/models/vehicle_pass.dart';
import 'package:websupark/models/vehicle_record.dart';
import 'package:websupark/screens/guard/guard_vehicle.dart';
import 'package:websupark/screens/guard/models/parking_check.dart';
import 'package:websupark/screens/guard/models/past_violation.dart';
import 'package:websupark/screens/guard/models/vehicle_check.dart';
import 'package:websupark/screens/guard/models/violation_type.dart';
import 'package:websupark/screens/guard/utils/time_format.dart';

// TODO: all sample data below is replaced by repository data later.

ParkingArea _area(String id) =>
    sampleParkingAreas.firstWhere((a) => a.id == id);

/// Starting content of "Recent checks" (fictional). New checks are added on top.
const sampleRecentChecks = [
  VehicleCheck(id: 'seed-1', plate: 'RFD-310', time: '09:41', location: 'P-4 · COM Gym', status: CheckStatus.cleared),
  VehicleCheck(id: 'seed-2', plate: 'NBX-775', time: '09:22', location: 'P-11 · Roxas Hall', status: CheckStatus.reported, incidentRef: 'INC-2026-1119-182'),
  VehicleCheck(id: 'seed-3', plate: 'GHT-204', time: '09:05', location: 'P-17 · CBM-CTE', status: CheckStatus.cleared),
  VehicleCheck(id: 'seed-4', plate: 'PLM-658', time: '08:47', location: 'P-18 · Baseball / Softball Diamond', status: CheckStatus.cleared),
  VehicleCheck(id: 'seed-5', plate: 'WQA-912', time: '08:30', location: 'P-15 · HOMETEL', status: CheckStatus.cleared),
  VehicleCheck(id: 'seed-6', plate: 'TYC-046', time: '08:12', location: 'P-9 · Road to GSO', status: CheckStatus.reported, incidentRef: 'INC-2026-1119-181'),
  VehicleCheck(id: 'seed-7', plate: 'DLS-381', time: '07:55', location: 'P-2 · COC along AV Hall', status: CheckStatus.cleared),
];

/// Sample vehicle passes, built on the team's Driver / Vehicle / VehiclePass.
/// Pass numbers are 5 digits, kept as text. Try them in the scan screen:
///  00921  student pass, assigned P-6, found in P-14   -> mismatch (2nd offense)
///  00456  faculty pass, assigned P-14, found in P-14  -> cleared
///  00789  yellow pass (no privilege), 3 past parking violations -> mismatch
///  00333  parent pass, vehicle has no open entry      -> no open entry
final List<GuardVehicle> sampleVehicles = [
  GuardVehicle(
    base: VehicleRecord(
      driver: const Driver(
          id: 'drv-1', fullName: 'Daniel Carter', mobileNumber: '+63 917 555 0121'),
      vehicle: const Vehicle(
          id: 'veh-1', plateNumber: 'ABC-123', makeModel: 'Toyota Camry',
          color: 'Blue', driverId: 'drv-1'),
      pass: VehiclePass(
        passNumber: '00921',
        vehicleId: 'veh-1',
        passType: PassType.studentWithParking,
        validUntil: DateTime(2027, 10, 31),
        assignedAreaId: 'P-6',
      ),
    ),
    pastViolations: const [
      PastViolation(type: ViolationType.unauthorizedParking, date: 'Apr 18, 2026'),
    ],
  ),
  GuardVehicle(
    base: VehicleRecord(
      driver: const Driver(
          id: 'drv-2', fullName: 'Maria Santos', mobileNumber: '+63 918 555 0188'),
      vehicle: const Vehicle(
          id: 'veh-2', plateNumber: 'KJH-482', makeModel: 'Honda City',
          color: 'White', driverId: 'drv-2'),
      pass: VehiclePass(
        passNumber: '00456',
        vehicleId: 'veh-2',
        passType: PassType.facultyStaffWithParking,
        validUntil: DateTime(2027, 10, 31),
        assignedAreaId: 'P-14',
      ),
    ),
  ),
  GuardVehicle(
    base: VehicleRecord(
      driver: const Driver(
          id: 'drv-3', fullName: 'Paolo Reyes', mobileNumber: '+63 920 555 0147'),
      vehicle: const Vehicle(
          id: 'veh-3', plateNumber: 'NBX-775', makeModel: 'Mitsubishi Mirage',
          color: 'Silver', driverId: 'drv-3'),
      pass: VehiclePass(
        passNumber: '00789',
        vehicleId: 'veh-3',
        passType: PassType.withoutParking,
        validUntil: DateTime(2027, 10, 31),
      ),
    ),
    pastViolations: const [
      PastViolation(type: ViolationType.parkingOvernight, date: 'Mar 2, 2026'),
      PastViolation(type: ViolationType.unauthorizedParking, date: 'May 20, 2026'),
      PastViolation(type: ViolationType.unauthorizedParking, date: 'Aug 8, 2026'),
    ],
  ),
  GuardVehicle(
    base: VehicleRecord(
      driver: const Driver(
          id: 'drv-4', fullName: 'Liza Gomez', mobileNumber: '+63 919 555 0109'),
      vehicle: const Vehicle(
          id: 'veh-4', plateNumber: 'TRK-220', makeModel: 'Suzuki Ertiga',
          color: 'Red', driverId: 'drv-4'),
      pass: VehiclePass(
        passNumber: '00333',
        vehicleId: 'veh-4',
        passType: PassType.parentGuardianWithParking,
        validUntil: DateTime(2027, 10, 31),
        assignedAreaId: 'P-13',
      ),
    ),
  ),
];

/// TODO: replace with repository.findVehicleBy...(). Returns null if unknown.
GuardVehicle? findVehicleByPassNumber(String passNumber) {
  for (final v in sampleVehicles) {
    if (v.passNumber == passNumber) return v;
  }
  return null;
}

// Simulated location reading (the documentation says detection is simulated).
const _simulatedAreaId = {
  'ABC-123': 'P-14',
  'KJH-482': 'P-14',
  'NBX-775': 'P-13',
  'TRK-220': 'P-13',
};
const _vehiclesWithoutOpenEntry = {'TRK-220'};

/// TODO: replace with the vehicle's open EntryExitRecord from the repository.
bool hasOpenEntry(GuardVehicle vehicle) =>
    !_vehiclesWithoutOpenEntry.contains(vehicle.plate);

ParkingCheck newParkingCheckFor(GuardVehicle vehicle) {
  final now = DateTime.now();
  return ParkingCheck(
    detectedArea: _area(_simulatedAreaId[vehicle.plate] ?? 'P-6'),
    beacon: 'Beacon B2-04',
    accuracyMeters: 1.8,
    checkedAt: formatHms(now),
    observedAt: '${formatMonthDay(now)} · ${formatHm(now)}',
    hasOpenEntry: hasOpenEntry(vehicle),
  );
}

/// Fallbacks used by the guard routes when a screen is opened directly.
final GuardVehicle sampleVehicleRecord = sampleVehicles.first;
final ParkingCheck sampleParkingCheck = newParkingCheckFor(sampleVehicleRecord);