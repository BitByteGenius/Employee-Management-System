import 'package:tms/core/services/storage_service.dart';
import 'package:tms/modules/auth/models/auth_tokens.dart';
import 'package:tms/modules/auth/models/auth_user.dart';
import 'package:tms/modules/auth/models/login_request.dart';
import 'package:tms/modules/auth/models/register_request.dart';
import 'package:tms/modules/auth/repositories/auth_repository.dart';
import 'package:tms/modules/auth/services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._service, this._storage);

  final AuthService _service;
  final StorageService _storage;

  @override
  Future<AuthUser> login(LoginRequest request) async {
    final response = await _service.login(request);
    await _storage.saveTokens(
      accessToken: response.tokens.accessToken,
      refreshToken: response.tokens.refreshToken,
    );
    await _storage.saveUser(response.user.toJson());
    return response.user;
  }

  @override
  Future<void> register(RegisterRequest request) {
    return _service.register(request);
  }

  @override
  Future<AuthUser?> restoreSession() async {
    final token = await _storage.getAccessToken();
    final user = _storage.getUser();
    if (token == null || token.isEmpty || user == null) return null;
    return AuthUser.fromJson(user);
  }

  @override
  Future<AuthTokens> refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw StateError('No refresh token is available');
    }
    final tokens = await _service.refreshToken(refreshToken);
    await _storage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  @override
  Future<void> logout() async {
    try {
      await _service.logout();
    } finally {
      await _storage.clearSession();
    }
  }

  @override
  bool get isLoggedIn => _storage.getUser() != null;

  @override
  Future<void> forgotPassword(String email) {
    return _service.forgotPassword(email);
  }

  @override
  Future<void> resetPassword(String token, String password) {
    return _service.resetPassword(token, password);
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) {
    return _service.changePassword(currentPassword, newPassword);
  }
}
