
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:websupark/models/app_user.dart';
import 'package:websupark/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AppUser? _current;

  @override
  AppUser? get currentUser => _current;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw const AuthException('Unable to sign in. Please try again.');
      }

      final profile = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!profile.exists) {
        await _auth.signOut();
        throw const AuthException(
          'Your account profile was not found. Please contact the administrator.',
        );
      }

      final data = profile.data()!;
      final roleValue = data['role'];

      final role = switch (roleValue) {
        'driver' => UserRole.driver,
        'guard' => UserRole.guard,
        'headSecurity' => UserRole.headSecurity,
        _ => null,
      };

      if (role == null) {
        await _auth.signOut();
        throw const AuthException(
          'Your account has an invalid role. Please contact the administrator.',
        );
      }

      final user = AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? email.trim(),
        fullName: data['fullName'] as String? ?? '',
        role: role,
        driverId: data['driverId'] as String?,
      );

      _current = user;
      return user;
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(switch (e.code) {
        'invalid-email' => 'Please enter a valid email address.',
        'user-not-found' => 'No account was found with that email.',
        'wrong-password' || 'invalid-credential' =>
          'Incorrect email or password.',
        'user-disabled' => 'This account has been disabled.',
        'too-many-requests' =>
          'Too many attempts. Please try again later.',
        _ => 'Unable to sign in. Please try again.',
      });
    } on FirebaseException {
      await _auth.signOut();
      throw const AuthException(
        'Unable to load your account profile. Please try again later.',
      );
    } catch (_) {
      await _auth.signOut();
      throw const AuthException(
        'Something went wrong while signing in. Please try again.',
      );
    }
  }

  @override
  Future<AppUser> signUpDriver({
    required String fullName,
    required String email,
    required String password,
    required String passNumber,
    required String plateNumber,
  }) async {
    throw const AuthException(
      'Driver registration is not connected to Firebase yet.',
    );
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    _current = null;
  }
}
