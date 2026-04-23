/// Result payload handed to [ClientOnboardingAccountTemplate.onSubmit].
class ClientOnboardingAccountResult {
  final String email;
  final String password;
  final String phone;

  const ClientOnboardingAccountResult({
    required this.email,
    required this.password,
    required this.phone,
  });
}
