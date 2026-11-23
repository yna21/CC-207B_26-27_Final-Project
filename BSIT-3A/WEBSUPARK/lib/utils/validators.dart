String? validateFullName(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return 'Enter your full name';
  if (text.length < 2) return 'Name is too short';
  return null;
}

String? validateEmail(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return 'Enter your email';
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? validatePassword(String? value) {
  final text = value ?? '';
  if (text.isEmpty) return 'Enter a password';
  if (text.length < 8) return 'Use at least 8 characters';
  if (!RegExp(r'[A-Za-z]').hasMatch(text) || !RegExp(r'\d').hasMatch(text)) {
    return 'Use both letters and numbers';
  }
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  if ((value ?? '').isEmpty) return 'Confirm your password';
  if (value != password) return 'Passwords do not match';
  return null;
}

String normalizePlate(String value) =>
    value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

String? validatePlateNumber(String? value) {
  final plate = normalizePlate(value ?? '');
  if (plate.isEmpty) return 'Enter the plate number';
  if (plate.length < 5 || plate.length > 8) {
    return 'Enter a valid plate number';
  }
  return null;
}