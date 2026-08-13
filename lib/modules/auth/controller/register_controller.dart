import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/core/routes/app_pages.dart';

class RegisterController extends GetxController {
  RegisterController(this._apiClient);

  final ApiClient _apiClient;

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final selectedRole = 'employee'.obs;
  final availableRoles = const ['admin', 'employee'];

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';

  void setFirstName(String value) => _firstName = value;
  void setLastName(String value) => _lastName = value;
  void setEmail(String value) => _email = value;
  void setPassword(String value) => _password = value;

  Future<void> register() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _apiClient.dio.post(
        ApiEndpoints.register,
        data: {
          'firstName': _firstName.trim(),
          'lastName': _lastName.trim(),
          'email': _email.trim(),
          'password': _password,
          'role': selectedRole.value,
        },
      );
      _showPendingApprovalDialog();
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
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) {
          return errors
              .map((item) {
                if (item is Map && item['msg'] != null) {
                  return item['msg'].toString();
                }
                return item.toString();
              })
              .join('\n');
        }
        return data['message'].toString();
      }
    } catch (_) {}
    return 'Registration failed. Please check the form and try again.';
  }

  void _showPendingApprovalDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.hourglass_top_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text('Pending Approval'),
          ],
        ),
        content: Text(
          'Registration submitted successfully!\n\n'
          "Your account has been registered as '${selectedRole.value}'. "
          'A Super Admin must approve it before you can log in.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('Return to Login'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
