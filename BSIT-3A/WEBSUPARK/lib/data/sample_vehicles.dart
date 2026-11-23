import 'package:websupark/models/driver.dart';
import 'package:websupark/models/pass_type.dart';
import 'package:websupark/models/vehicle.dart';
import 'package:websupark/models/vehicle_pass.dart';

// SAMPLE DATA: all names, plates and numbers are fictional.
// Assigned areas follow the WVSU guidelines (P-6 for students, P-7 for
// faculty and staff, and so on). 

final List<Driver> sampleDrivers = [
  const Driver(id: 'd-001', fullName: 'Yana Santos', mobileNumber: '+63 917 555 0148'),
  const Driver(id: 'd-002', fullName: 'Daniel Carter', mobileNumber: '+63 917 555 0182'),
  const Driver(id: 'd-003', fullName: 'Priya Nair', mobileNumber: '+63 917 555 0168'),
  const Driver(id: 'd-004', fullName: 'Marcus Lee', mobileNumber: '+63 917 555 0194'),
  const Driver(id: 'd-005', fullName: 'Noah Williams', mobileNumber: '+63 917 555 0131'),
];

final List<Vehicle> sampleVehicles = [
  const Vehicle(id: 'v-001', plateNumber: 'ABC-1234', makeModel: 'Toyota Vios', color: 'White', driverId: 'd-001'),
  const Vehicle(id: 'v-002', plateNumber: 'ABC-123', makeModel: 'Toyota Camry', color: 'Blue', driverId: 'd-002'),
  const Vehicle(id: 'v-003', plateNumber: 'KJH-482', makeModel: 'Honda CR-V', color: 'White', driverId: 'd-003'),
  const Vehicle(id: 'v-004', plateNumber: 'MTR-907', makeModel: 'Ford Escape', color: 'Gray', driverId: 'd-004'),
  const Vehicle(id: 'v-005', plateNumber: 'RPK-732', makeModel: 'Subaru Outback', color: 'Green', driverId: 'd-005'),
];

final List<VehiclePass> sampleVehiclePasses = [
  VehiclePass(
    passNumber: '00921',
    vehicleId: 'v-001',
    passType: PassType.studentWithParking,
    assignedAreaId: 'P-6',
    validUntil: DateTime(2027, 3, 31),
  ),
  VehiclePass(
    passNumber: '00347',
    vehicleId: 'v-002',
    passType: PassType.facultyStaffWithParking,
    assignedAreaId: 'P-7',
    validUntil: DateTime(2027, 10, 31),
  ),
  VehiclePass(
    passNumber: '00512',
    vehicleId: 'v-003',
    passType: PassType.studentWithParking,
    assignedAreaId: 'P-4',
    validUntil: DateTime(2027, 3, 31),
  ),
  VehiclePass(
    passNumber: '00688',
    vehicleId: 'v-004',
    passType: PassType.facultyStaffWithParking,
    assignedAreaId: 'P-14',
    validUntil: DateTime(2027, 3, 31),
  ),
  // Yellow pass (no parking privilege)
  VehiclePass(
    passNumber: '00099',
    vehicleId: 'v-005',
    passType: PassType.withoutParking,
    status: PassStatus.expired,
    validUntil: DateTime(2026, 9, 28),
  ),
];