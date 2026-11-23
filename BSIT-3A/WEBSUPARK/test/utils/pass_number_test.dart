import 'package:flutter_test/flutter_test.dart';
import 'package:websupark/utils/pass_number.dart';

void main() {
  test('accepts a 5-digit number and keeps the leading zeros', () {
    expect(validatePassNumberInput('00921'), isNull);
    expect(parsePassNumber('00921'), '00921');
  });

  test('ignores spaces around the number', () {
    expect(parsePassNumber('  00921 '), '00921');
  });

  test('rejects empty, short, long and non-digit input', () {
    expect(validatePassNumberInput(null), isNotNull);
    expect(validatePassNumberInput(''), isNotNull);
    expect(validatePassNumberInput('921'), isNotNull);
    expect(validatePassNumberInput('009211'), isNotNull);
    expect(validatePassNumberInput('0092A'), isNotNull);
    expect(parsePassNumber('0092A'), isNull);
  });
}