import '../models/auth_user.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/auth_tokens.dart';

abstract interface class AuthRepository {
  Future<AuthUser> login(LoginRequest request);

  Future<void> register(RegisterRequest request);

  Future<AuthUser?> restoreSession();

  Future<AuthTokens> refreshToken();

  Future<void> forgotPassword(String email);

  Future<void> resetPassword(String token, String password);

  Future<void> changePassword(String currentPassword, String newPassword);

  Future<void> logout();

  bool get isLoggedIn;
}
