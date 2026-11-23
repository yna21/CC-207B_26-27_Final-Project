import 'package:websupark/data/sample_accounts.dart';
import 'package:websupark/models/app_user.dart';
import 'package:websupark/repositories/auth_repository.dart';
import 'package:websupark/repositories/vehicle_repository.dart';
import 'package:websupark/utils/pass_number.dart';
import 'package:websupark/utils/validators.dart';

class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository({
    required this._vehicles,
    List<SampleAccount>? accounts,
    this.latency = Duration.zero,
  }) {
    for (final account in accounts ?? sampleAccounts) {
      _accounts[account.user.email.toLowerCase()] = account;
    }
  }

  final Duration latency;

  final VehicleRepository _vehicles;
  final Map<String, SampleAccount> _accounts = {};
  AppUser? _current;

  @override
  AppUser? get currentUser => _current;

  Future<void> _wait() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await _wait();
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthException('Incorrect email or password.');
    }
    _current = account.user;
    return account.user;
  }

  @override
  Future<AppUser> signUpDriver({
    required String fullName,
    required String email,
    required String password,
    required String passNumber,
    required String plateNumber,
  }) async {
    await _wait();

    final emailKey = email.trim().toLowerCase();
    if (_accounts.containsKey(emailKey)) {
      throw const AuthException('An account with this email already exists.');
    }

    final pass = parsePassNumber(passNumber);
    if (pass == null) {
      throw const AuthException('Enter a valid pass number.');
    }

    final record = await _vehicles.findByPassNumber(pass);
    if (record == null) {
      throw const AuthException('No vehicle was found for that pass number.');
    }
    if (normalizePlate(record.vehicle.plateNumber) !=
        normalizePlate(plateNumber)) {
      throw const AuthException('The plate number does not match that pass.');
    }

    final driverId = record.driver.id;
    final alreadyLinked =
        _accounts.values.any((a) => a.user.driverId == driverId);
    if (alreadyLinked) {
      throw const AuthException('This vehicle already has an account.');
    }

    final user = AppUser(
      id: 'u-${DateTime.now().microsecondsSinceEpoch}',
      email: email.trim(),
      fullName: fullName.trim(),
      role: UserRole.driver,
      driverId: driverId,
    );
    _accounts[emailKey] = SampleAccount(password: password, user: user);
    _current = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    _current = null;
  }
}