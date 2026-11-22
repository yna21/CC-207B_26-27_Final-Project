// TODO: replace everything in this file with repository data
// (getAreas, getAreaOccupancy, getAllViolations, getVehiclesInside).
// All names, plates and numbers are fictional.

class SampleArea {
  final String id;
  final String name;
  final int capacity;
  final int occupied;
  const SampleArea(this.id, this.name, this.capacity, this.occupied);

  int get available => capacity - occupied;
  double get ratio => capacity == 0 ? 0 : occupied / capacity;
}

// Capacities here are sample numbers, not the official guideline values.
const sampleAreas = [
  SampleArea('P-1', 'Main Gate', 40, 38),
  SampleArea('P-6', 'CICT', 30, 18),
  SampleArea('P-7', 'Library', 25, 25),
  SampleArea('P-10', 'Admin', 35, 12),
];

class SampleVehicle {
  final String plate;
  final String driver;
  final String mobile;
  final String makeModel;
  final String passNumber; // text, so leading zeros are kept
  final String passType;
  final String areaId; // '-' for Yellow pass (no assigned area)
  final bool inside;
  final DateTime validUntil;
  final String lastActivity;

  const SampleVehicle({
    required this.plate,
    required this.driver,
    required this.mobile,
    required this.makeModel,
    required this.passNumber,
    required this.passType,
    required this.areaId,
    required this.inside,
    required this.validUntil,
    required this.lastActivity,
  });

  bool get expired => validUntil.isBefore(DateTime.now());
  bool get expiringSoon =>
      !expired && validUntil.difference(DateTime.now()).inDays <= 30;
}

const samplePassTypes = [
  'Student with parking',
  'Parent or guardian with parking',
  'Faculty or staff with parking',
  'Without parking privilege',
];

// Not const because DateTime(...) is calculated while the app runs.
final sampleVehicles = [
  SampleVehicle(
    plate: 'ABC 1234',
    driver: 'Juan Dela Cruz',
    mobile: '+63 917 555 0148',
    makeModel: 'White Toyota Vios',
    passNumber: '00921',
    passType: 'Student with parking',
    areaId: 'P-6',
    inside: true,
    validUntil: DateTime(2027, 3, 31),
    lastActivity: 'Nov 21, 10:42 AM · P-7',
  ),
  SampleVehicle(
    plate: 'XYZ 5678',
    driver: 'Maria Santos',
    mobile: '+63 917 555 0172',
    makeModel: 'Gray Honda City',
    passNumber: '00455',
    passType: 'Faculty or staff with parking',
    areaId: 'P-10',
    inside: true,
    validUntil: DateTime(2026, 12, 15),
    lastActivity: 'Nov 21, 08:14 AM · Main gate',
  ),
  SampleVehicle(
    plate: 'KJH 482',
    driver: 'Pedro Reyes',
    mobile: '+63 917 555 0123',
    makeModel: 'Black Mitsubishi Xpander',
    passNumber: '00102',
    passType: 'Parent or guardian with parking',
    areaId: 'P-1',
    inside: false,
    validUntil: DateTime(2027, 1, 31),
    lastActivity: 'Nov 21, 10:36 AM · Main gate exit',
  ),
  SampleVehicle(
    plate: 'MTR 907',
    driver: 'Ana Lim',
    mobile: '+63 917 555 0199',
    makeModel: 'Blue Suzuki Ertiga',
    passNumber: '00733',
    passType: 'Student with parking',
    areaId: 'P-7',
    inside: true,
    validUntil: DateTime(2026, 12, 10),
    lastActivity: 'Nov 21, 09:58 AM · P-1',
  ),
  SampleVehicle(
    plate: 'LZX 614',
    driver: 'Carlo Tan',
    mobile: '+63 917 555 0165',
    makeModel: 'Silver Nissan Almera',
    passNumber: '00850',
    passType: 'Without parking privilege',
    areaId: '-',
    inside: true,
    validUntil: DateTime(2027, 2, 28),
    lastActivity: 'Nov 21, 09:44 AM · Main gate',
  ),
  SampleVehicle(
    plate: 'QRS 221',
    driver: 'Noel Garcia',
    mobile: '+63 917 555 0111',
    makeModel: 'White Hyundai Accent',
    passNumber: '00861',
    passType: 'Without parking privilege',
    areaId: '-',
    inside: true,
    validUntil: DateTime(2026, 10, 31),
    lastActivity: 'Nov 21, 10:00 AM · Main gate',
  ),
  SampleVehicle(
    plate: 'TXY 341',
    driver: 'Liza Ramos',
    mobile: '+63 917 555 0187',
    makeModel: 'Red Toyota Wigo',
    passNumber: '00877',
    passType: 'Without parking privilege',
    areaId: '-',
    inside: false,
    validUntil: DateTime(2027, 4, 30),
    lastActivity: 'Nov 21, 09:10 AM · Main gate exit',
  ),
];

enum ViolationStatus { pending, inReview, resolved }

class SampleViolation {
  final String incidentNumber;
  final String plate;
  final String type;
  final String assignedAreaId;
  final String detectedAreaId;
  final String reportedBy;
  final String reportedAt;
  final ViolationStatus status;
  final String notes;

  const SampleViolation({
    required this.incidentNumber,
    required this.plate,
    required this.type,
    required this.assignedAreaId,
    required this.detectedAreaId,
    required this.reportedBy,
    required this.reportedAt,
    required this.status,
    required this.notes,
  });

  // Fields are final, so a "change" means making a copy.
  SampleViolation copyWith({ViolationStatus? status}) => SampleViolation(
    incidentNumber: incidentNumber,
    plate: plate,
    type: type,
    assignedAreaId: assignedAreaId,
    detectedAreaId: detectedAreaId,
    reportedBy: reportedBy,
    reportedAt: reportedAt,
    status: status ?? this.status,
    notes: notes,
  );
}

const sampleViolations = [
  SampleViolation(
    incidentNumber: 'INC-2026-1121-001',
    plate: 'ABC 1234',
    type: 'Wrong space',
    assignedAreaId: 'P-6',
    detectedAreaId: 'P-7',
    reportedBy: 'Officer M. Reyes',
    reportedAt: 'Nov 21, 10:42 AM',
    status: ViolationStatus.pending,
    notes: 'Vehicle parked in P-7. Assigned area P-6 is clear. Pass visible.',
  ),
  SampleViolation(
    incidentNumber: 'INC-2026-1121-002',
    plate: 'MTR 907',
    type: 'Wrong space',
    assignedAreaId: 'P-7',
    detectedAreaId: 'P-1',
    reportedBy: 'Officer J. Patel',
    reportedAt: 'Nov 21, 09:58 AM',
    status: ViolationStatus.inReview,
    notes: 'Parked in P-1 near the gate.',
  ),
  SampleViolation(
    incidentNumber: 'INC-2026-1120-003',
    plate: 'LZX 614',
    type: 'Unauthorized',
    assignedAreaId: '-',
    detectedAreaId: 'P-10',
    reportedBy: 'Officer J. Patel',
    reportedAt: 'Nov 20, 11:05 AM',
    status: ViolationStatus.pending,
    notes: 'Yellow pass vehicle parked inside the Admin area.',
  ),
  SampleViolation(
    incidentNumber: 'INC-2026-1120-007',
    plate: 'XYZ 5678',
    type: 'Unauthorized',
    assignedAreaId: 'P-10',
    detectedAreaId: 'P-6',
    reportedBy: 'Officer M. Reyes',
    reportedAt: 'Nov 20, 02:15 PM',
    status: ViolationStatus.resolved,
    notes: 'Driver contacted and moved the vehicle.',
  ),
  SampleViolation(
    incidentNumber: 'INC-2026-1119-004',
    plate: 'KJH 482',
    type: 'Wrong space',
    assignedAreaId: 'P-1',
    detectedAreaId: 'P-6',
    reportedBy: 'Officer M. Reyes',
    reportedAt: 'Nov 19, 03:30 PM',
    status: ViolationStatus.resolved,
    notes: 'Moved after the guard talked to the driver.',
  ),
];

enum ActivityKind { mismatch, entry, exit, verified, scan }

class SampleActivity {
  final String time;
  final String title;
  final String detail;
  final ActivityKind kind;
  final String tag;
  const SampleActivity(this.time, this.title, this.detail, this.kind, this.tag);
}

// TODO: replace with the latest EntryExitRecord and Violation events.
const sampleActivities = [
  SampleActivity(
    '10:44 AM',
    'Parking mismatch reported',
    'ABC 1234 · Assigned P-6, detected P-7 · Officer M. Reyes',
    ActivityKind.mismatch,
    'Needs review',
  ),
  SampleActivity(
    '10:43 AM',
    'Vehicle entry recorded',
    'KJH 482 · Pass 00102 · Main gate',
    ActivityKind.entry,
    'Cleared',
  ),
  SampleActivity(
    '10:42 AM',
    'Vehicle location verified',
    'ABC 1234 detected in P-7',
    ActivityKind.verified,
    'Logged',
  ),
  SampleActivity(
    '10:40 AM',
    'Pass number confirmed',
    'XYZ 5678 · Pass 00455',
    ActivityKind.scan,
    'Cleared',
  ),
  SampleActivity(
    '10:38 AM',
    'Vehicle exit recorded',
    'LZX 614 · Main gate',
    ActivityKind.exit,
    'Logged',
  ),
];

class SampleYellowPass {
  final String plate;
  final String passNumber;
  final String purpose;
  final DateTime entry;
  final DateTime? exit; // null while still inside
  const SampleYellowPass(
    this.plate,
    this.passNumber,
    this.purpose,
    this.entry,
    this.exit,
  );

  // Yellow pass tracking = exit minus entry. No time limit is enforced.
  Duration get duration => (exit ?? DateTime.now()).difference(entry);
}

final sampleYellowPasses = [
  SampleYellowPass(
    'LZX 614',
    '00850',
    'Student drop-off',
    DateTime.now().subtract(const Duration(minutes: 95)),
    null,
  ),
  SampleYellowPass(
    'QRS 221',
    '00861',
    'Document submission',
    DateTime.now().subtract(const Duration(minutes: 40)),
    null,
  ),
  SampleYellowPass(
    'TXY 341',
    '00877',
    'Parent pick-up',
    DateTime.now().subtract(const Duration(minutes: 120)),
    DateTime.now().subtract(const Duration(minutes: 70)),
  ),
];

class SampleOutsideVehicle {
  final String plate;
  final String category;
  final String purpose;
  final String destination;
  final DateTime entry;
  final DateTime? exit;
  const SampleOutsideVehicle(
    this.plate,
    this.category,
    this.purpose,
    this.destination,
    this.entry,
    this.exit,
  );

  Duration get duration => (exit ?? DateTime.now()).difference(entry);

  SampleOutsideVehicle withExit(DateTime time) =>
      SampleOutsideVehicle(plate, category, purpose, destination, entry, time);
}

final sampleOutsideVehicles = [
  SampleOutsideVehicle(
    'DEF 111',
    'Delivery rider',
    'Meal delivery',
    'Canteen',
    DateTime.now().subtract(const Duration(minutes: 8)),
    null,
  ),
  SampleOutsideVehicle(
    'GHI 222',
    'Courier',
    'Document pickup',
    'Registrar',
    DateTime.now().subtract(const Duration(minutes: 30)),
    null,
  ),
  SampleOutsideVehicle(
    'JKL 333',
    'Visitor',
    'Visitor appointment',
    'Admission Office',
    DateTime.now().subtract(const Duration(hours: 2)),
    DateTime.now().subtract(const Duration(hours: 1)),
  ),
];
