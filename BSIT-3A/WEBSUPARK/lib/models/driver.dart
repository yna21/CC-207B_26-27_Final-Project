class Driver {
  const Driver({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    this.isSample = true,
  });

  final String id;
  final String fullName;
  final String mobileNumber;

  final bool isSample;
}