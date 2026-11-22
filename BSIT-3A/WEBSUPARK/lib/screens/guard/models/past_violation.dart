import 'package:websupark/screens/guard/models/violation_type.dart';

/// One earlier violation of a vehicle (used for the offense number).
class PastViolation {
  final ViolationType type;
  final String date; // "Apr 18, 2026"

  const PastViolation({required this.type, required this.date});
}