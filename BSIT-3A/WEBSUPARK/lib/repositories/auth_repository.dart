import 'package:websupark/models/app_user.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class AuthRepository {
  /// The signed-in user, or null.
  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> signUpDriver({
    required String fullName,
    required String email,
    required String password,
    required String passNumber,
    required String plateNumber,
  });

  Future<void> signOut();
}