enum UserRole { driver, guard, headSecurity }

/// A signed-in account.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.driverId,
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;

  final String? driverId;
}