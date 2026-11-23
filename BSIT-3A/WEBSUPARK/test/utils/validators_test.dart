import 'package:flutter_test/flutter_test.dart';
import 'package:websupark/utils/validators.dart';

void main() {
  test('email validator', () {
    expect(validateEmail('yana@example.com'), isNull);
    expect(validateEmail(''), isNotNull);
    expect(validateEmail('not-an-email'), isNotNull);
  });

  test('password validator needs 8 characters with letters and numbers', () {
    expect(validatePassword('Sample123'), isNull);
    expect(validatePassword('short1'), isNotNull);
    expect(validatePassword('onlyletters'), isNotNull);
    expect(validatePassword('12345678'), isNotNull);
  });

  test('confirm password must match', () {
    expect(validateConfirmPassword('Sample123', 'Sample123'), isNull);
    expect(validateConfirmPassword('Other123', 'Sample123'), isNotNull);
  });

  test('plate numbers are compared without spaces, dashes or capitals', () {
    expect(normalizePlate('abc-123'), 'ABC123');
    expect(validatePlateNumber('ABC 1234'), isNull);
    expect(validatePlateNumber('AB'), isNotNull);
  });
}