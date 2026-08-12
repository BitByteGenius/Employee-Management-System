/// ------------------------------------------------------------
/// Authentication Tokens
/// ------------------------------------------------------------
///
/// Returned after successful login.
/// ------------------------------------------------------------
library;

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json["accessToken"] ?? "",
      refreshToken: json["refreshToken"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
    };
  }
}