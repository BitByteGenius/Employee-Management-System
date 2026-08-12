import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/modules/auth/models/auth_tokens.dart';
import 'package:tms/modules/auth/models/login_request.dart';
import 'package:tms/modules/auth/models/login_response.dart';
import 'package:tms/modules/auth/models/register_request.dart';
import 'package:tms/modules/auth/services/auth_service.dart';

class AuthServiceImpl implements AuthService {
  AuthServiceImpl(this._client);

  final ApiClient _client;

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return LoginResponse.fromJson(data);
  }

  @override
  Future<void> register(RegisterRequest request) async {
    await _client.dio.post(ApiEndpoints.register, data: request.toJson());
  }

  @override
  Future<AuthTokens> refreshToken(String refreshToken) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': refreshToken},
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return AuthTokens.fromJson(data);
  }

  @override
  Future<void> logout() async {
    await _client.dio.post(ApiEndpoints.logout);
  }

  @override
  Future<void> forgotPassword(String email) {
    throw UnsupportedError('Forgot password is not enabled by the backend.');
  }

  @override
  Future<void> resetPassword(String token, String password) {
    throw UnsupportedError('Reset password is not enabled by the backend.');
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) {
    throw UnsupportedError('Change password is not enabled by the backend.');
  }
}
