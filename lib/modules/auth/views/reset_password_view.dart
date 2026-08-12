import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/modules/auth/widget/auth_card.dart';
import 'package:tms/modules/auth/widget/auth_layout.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: AuthCard(
        title: 'Reset Password',
        subtitle: 'Password reset is not enabled by the active backend routes.',
        child: TextButton(
          onPressed: () => Get.offAllNamed(AppRoutes.login),
          child: const Text('Back to Login'),
        ),
      ),
    );
  }
}
