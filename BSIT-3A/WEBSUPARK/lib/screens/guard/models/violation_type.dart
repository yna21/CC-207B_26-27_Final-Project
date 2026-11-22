/// The violations printed on the WVSU Traffic Violation Ticket
/// (Guidelines on Motor Vehicle Pass, Entry and Parking, 2023 edition).
enum ViolationType {
  parkingOnURoad('Parking on U-road'),
  disregardingTrafficSigns('Disregarding Traffic Signs'),
  parkingOvernight('Parking Overnight'),
  overSpeeding('Over Speeding'),
  obstructionOfTrafficFlow('Obstruction of Traffic Flow'),
  blowingOfHorns('Blowing of Horns'),
  openMuffler('Open Muffler'),
  unauthorizedParking('Unauthorized Parking'),
  recklessDriving('Reckless Driving');

  const ViolationType(this.label);

  final String label;

  /// Counts toward "more than three parking violations" (Sanctions, no. 2).
  /// ASSUMPTION: confirm with the Security Office which types count.
  bool get isParking =>
      this == parkingOnURoad ||
      this == parkingOvernight ||
      this == obstructionOfTrafficFlow ||
      this == unauthorizedParking;
}

/// 1 -> "1st", 2 -> "2nd", 3 -> "3rd", 4 -> "4th" ...
String ordinal(int n) {
  final lastTwo = n % 100;
  if (lastTwo >= 11 && lastTwo <= 13) return '${n}th';
  switch (n % 10) {
    case 1:
      return '${n}st';
    case 2:
      return '${n}nd';
    case 3:
      return '${n}rd';
    default:
      return '${n}th';
  }
}