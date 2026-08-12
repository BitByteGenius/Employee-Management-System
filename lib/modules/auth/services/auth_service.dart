import '../models/auth_tokens.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';

abstract interface class AuthService {
  /// Authenticate user.
  Future<LoginResponse> login(LoginRequest request);

  /// Register a new user.
  Future<void> register(RegisterRequest request);

  /// Refresh JWT tokens.
  Future<AuthTokens> refreshToken(String refreshToken);

  /// Request password reset link.
  Future<void> forgotPassword(String email);

  /// Reset password using token.
  Future<void> resetPassword(String token, String password);

  /// Change password for authenticated user.
  Future<void> changePassword(String currentPassword, String newPassword);

  /// Logout current user.
  Future<void> logout();
}