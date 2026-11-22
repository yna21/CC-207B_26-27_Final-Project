/// Result shown in the "Recent checks" list.
enum CheckStatus { cleared, mismatch, reported, noEntry }

class VehicleCheck {
  final String id;
  final String plate;
  final String time; // "10:36"
  final String location; // "P-6 · CICT"
  final CheckStatus status;
  final String? incidentRef; // set once a violation was reported
  final String? driverName;
  final String? passTypeLabel;

  const VehicleCheck({
    required this.id,
    required this.plate,
    required this.time,
    required this.location,
    required this.status,
    this.incidentRef,
    this.driverName,
    this.passTypeLabel,
  });

  VehicleCheck copyWith({CheckStatus? status, String? incidentRef}) =>
      VehicleCheck(
        id: id,
        plate: plate,
        time: time,
        location: location,
        status: status ?? this.status,
        incidentRef: incidentRef ?? this.incidentRef,
        driverName: driverName,
        passTypeLabel: passTypeLabel,
      );
}