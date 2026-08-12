import 'auth_tokens.dart';
import 'auth_user.dart';

/// ------------------------------------------------------------
/// Login Response
/// ------------------------------------------------------------
///
/// Returned by:
/// POST /auth/login
/// ------------------------------------------------------------

class LoginResponse {
  final AuthUser user;
  final AuthTokens tokens;

  const LoginResponse({
    required this.user,
    required this.tokens,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    AuthTokens parsedTokens;
    if (json.containsKey("tokens") && json["tokens"] is Map<String, dynamic>) {
      parsedTokens = AuthTokens.fromJson(json["tokens"]);
    } else {
      parsedTokens = AuthTokens(
        accessToken: json["accessToken"]?.toString() ?? "",
        refreshToken: json["refreshToken"]?.toString() ?? "",
      );
    }

    final userJson = json["user"] is Map<String, dynamic>
        ? json["user"] as Map<String, dynamic>
        : json;

    return LoginResponse(
      user: AuthUser.fromJson(userJson),
      tokens: parsedTokens,
    );
  }
}