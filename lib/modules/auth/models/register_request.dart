/// Registration Request.
///
/// Matches your Swagger exactly.
library;

class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String role;

  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.role = 'User',
  });

  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password,
      "role": role,
    };
  }
}