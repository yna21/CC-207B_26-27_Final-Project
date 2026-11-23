import 'package:websupark/models/app_user.dart';

class SampleAccount {
  const SampleAccount({required this.password, required this.user});

  final String password;
  final AppUser user;
}

const List<SampleAccount> sampleAccounts = [
  SampleAccount(
    password: 'Sample123',
    user: AppUser(
      id: 'u-001',
      email: 'yana@example.com',
      fullName: 'Yana Santos',
      role: UserRole.driver,
      driverId: 'd-001',
    ),
  ),
  SampleAccount(
    password: 'Sample123',
    user: AppUser(
      id: 'u-002',
      email: 'guard@example.com',
      fullName: 'Officer M. Reyes',
      role: UserRole.guard,
    ),
  ),
  SampleAccount(
    password: 'Sample123',
    user: AppUser(
      id: 'u-003',
      email: 'head@example.com',
      fullName: 'Chief Security Officer Alfaro',
      role: UserRole.headSecurity,
    ),
  ),
];
