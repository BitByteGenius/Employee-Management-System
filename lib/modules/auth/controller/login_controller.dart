import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/core/services/storage_service.dart';

class LoginController extends GetxController {
  LoginController({
    required ApiClient apiClient,
    required StorageService storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  final ApiClient _apiClient;
  final StorageService _storage;

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final rememberMe = true.obs;

  String _email = '';
  String _password = '';

  void setEmail(String value) => _email = value;
  void setPassword(String value) => _password = value;

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: {
          'email': _email.trim(),
          'password': _password,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>;

      await _storage.saveTokens(
        accessToken: data['accessToken']?.toString() ?? '',
        refreshToken: data['refreshToken']?.toString() ?? '',
      );
      await _storage.saveUser(user);

      final roleStr = (user['systemRole'] ?? user['role'] ?? '').toString();
      Get.offAllNamed(
        AppRoutes.dashboardForRole(roleStr),
      );
    } catch (error) {
      errorMessage.value = _messageFromError(error);
    } finally {
      isLoading.value = false;
    }
  }

  String _messageFromError(Object error) {
    try {
      final dynamic dioError = error;
      final data = dioError.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}
    return 'Login failed. Please check your email and password.';
  }
}
