class UserAccount {
  final String fullName;
  final String username;
  final String university;
  final String email;
  final String password;

  UserAccount({
    required this.fullName,
    required this.username,
    required this.university,
    required this.email,
    required this.password,
  });
}

// Global list storing registered users during the app session
final List<UserAccount> registeredAccounts = [];