import 'package:flutter_test/flutter_test.dart';
import 'package:websupark/models/app_user.dart';
import 'package:websupark/repositories/auth_repository.dart';
import 'package:websupark/repositories/in_memory_auth_repository.dart';
import 'package:websupark/repositories/in_memory_vehicle_repository.dart';

void main() {
  late InMemoryAuthRepository auth;

  setUp(() {
    auth = InMemoryAuthRepository(vehicles: InMemoryVehicleRepository());
  });

  test('signs in with a sample account, ignoring email capitals', () async {
    final user =
        await auth.signIn(email: 'YANA@example.com', password: 'Sample123');
    expect(user.role, UserRole.driver);
    expect(auth.currentUser, user);
  });

  test('rejects a wrong password', () async {
    expect(
      auth.signIn(email: 'yana@example.com', password: 'wrong'),
      throwsA(isA<AuthException>()),
    );
  });

  test('sign out clears the current user', () async {
    await auth.signIn(email: 'guard@example.com', password: 'Sample123');
    await auth.signOut();
    expect(auth.currentUser, isNull);
  });

  test('sign up links a new driver to the vehicle', () async {
    final user = await auth.signUpDriver(
      fullName: 'Priya Nair',
      email: 'priya@example.com',
      password: 'Sample123',
      passNumber: '00512',
      plateNumber: 'kjh 482',
    );
    expect(user.role, UserRole.driver);
    expect(user.driverId, 'd-003');

    await auth.signOut();
    final again =
        await auth.signIn(email: 'priya@example.com', password: 'Sample123');
    expect(again.driverId, 'd-003');
  });

  test('sign up rejects a plate that does not match the pass', () async {
    expect(
      auth.signUpDriver(
        fullName: 'Priya Nair',
        email: 'priya@example.com',
        password: 'Sample123',
        passNumber: '00512',
        plateNumber: 'ZZZ-999',
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('sign up rejects a duplicate email and an already linked vehicle',
      () async {
    expect(
      auth.signUpDriver(
        fullName: 'Someone',
        email: 'yana@example.com',
        password: 'Sample123',
        passNumber: '00512',
        plateNumber: 'KJH-482',
      ),
      throwsA(isA<AuthException>()),
    );
    expect(
      auth.signUpDriver(
        fullName: 'Someone',
        email: 'new@example.com',
        password: 'Sample123',
        passNumber: '00921', // vehicle already has an account
        plateNumber: 'ABC-1234',
      ),
      throwsA(isA<AuthException>()),
    );
  });
}
