import 'package:websupark/data/sample_parking_areas.dart';
import 'package:websupark/models/parking_area.dart';
import 'package:websupark/models/pass_type.dart';
import 'package:websupark/models/vehicle_pass.dart';
import 'package:websupark/models/vehicle_record.dart';
import 'package:websupark/screens/guard/models/past_violation.dart';
import 'package:websupark/screens/guard/models/violation_type.dart';
import 'package:websupark/screens/guard/utils/time_format.dart';

/// What the guard screens show about a vehicle: the team's shared
/// [VehicleRecord] (driver, vehicle, pass) plus guard-only extras
/// (the vehicle's violation history). The shared models stay untouched.
class GuardVehicle {
  final VehicleRecord base;
  final List<PastViolation> pastViolations;

  const GuardVehicle({required this.base, this.pastViolations = const []});

  // ---- from the shared models ----
  String get plate => base.vehicle.plateNumber;
  String get driverName => base.driver.fullName;
  String get mobile => base.driver.mobileNumber;
  String get vehicleColor => base.vehicle.color;
  String get vehicleSummary => '${base.vehicle.color} ${base.vehicle.makeModel}';
  String get passNumber => base.pass.passNumber;
  PassType get passType => base.pass.passType;
  String? get assignedSlot => base.pass.assignedSlot;
  String get passExpiry => formatDate(base.pass.validUntil);

  bool get isPassValid => base.pass.isValidOn(DateTime.now());

  String get passStatusLabel {
    if (isPassValid) return 'Pass valid';
    switch (base.pass.status) {
      case PassStatus.active:
      case PassStatus.expired:
        return 'Pass expired';
      case PassStatus.held:
        return 'Pass on hold';
    }
  }

  /// The assigned area, looked up from the pass's assignedAreaId.
  /// TODO: use the repository's getAreas() when it exists.
  ParkingArea? get assignedArea {
    final id = base.pass.assignedAreaId;
    if (id == null) return null;
    for (final a in sampleParkingAreas) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// "P-6 · CICT" or "P-6 · CICT · Slot A-25"; "None" without an area.
  String get assignedAreaLabel {
    final a = assignedArea;
    if (a == null) return 'None';
    final slot = assignedSlot;
    return slot == null ? '${a.id} · ${a.name}' : '${a.id} · ${a.name} · Slot $slot';
  }

  // ---- violation history (guard-only for now) ----
  int get previousViolationCount => pastViolations.length;

  /// Violations that count toward the "more than three" parking sanction.
  int get parkingViolationCount =>
      pastViolations.where((v) => v.type.isParking).length;

  /// "None" or "2 · Aug 8, 2026" (count and date of the latest).
  String get previousViolationsLabel => pastViolations.isEmpty
      ? 'None'
      : '${pastViolations.length} · ${pastViolations.last.date}';

  /// 1st, 2nd, 3rd ... offense of [type] for this vehicle (as on the ticket).
  int offenseNumberFor(ViolationType type) =>
      pastViolations.where((v) => v.type == type).length + 1;

  GuardVehicle copyWith({List<PastViolation>? pastViolations}) => GuardVehicle(
        base: base,
        pastViolations: pastViolations ?? this.pastViolations,
      );
}