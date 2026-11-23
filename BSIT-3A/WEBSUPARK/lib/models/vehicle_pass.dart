import 'package:websupark/models/pass_type.dart';

enum PassStatus { active, expired, held }

class VehiclePass {
  const VehiclePass({
    required this.passNumber,
    required this.vehicleId,
    required this.passType,
    required this.validUntil,
    this.status = PassStatus.active,
    this.assignedAreaId,
    this.assignedSlot,
  });

  final String passNumber;
  final String vehicleId;
  final PassType passType;

  final String? assignedAreaId;

  final String? assignedSlot;
  final DateTime validUntil;
  final PassStatus status;

  bool isValidOn(DateTime date) =>
      status == PassStatus.active && !date.isAfter(validUntil);
}