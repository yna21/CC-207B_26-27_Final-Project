const int passNumberLength = 5;

String? validatePassNumberInput(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return 'Enter the pass number';
  if (!RegExp(r'^\d+$').hasMatch(text)) return 'Use digits only';
  if (text.length != passNumberLength) {
    return 'A pass number has $passNumberLength digits';
  }
  return null;
}

String? parsePassNumber(String? raw) {
  if (validatePassNumberInput(raw) != null) return null;
  return raw!.trim();
}