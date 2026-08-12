import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/modules/auth/controller/login_controller.dart';
import 'package:tms/shared/buttons/primary_button.dart';
import 'package:tms/shared/forms/app_text_field.dart';
import 'package:tms/shared/forms/password_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LoginController>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: ctrl.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FlutterLogo(size: 80),
          const SizedBox(height: 24),
          Text('Welcome Back!', style: textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue to your TeamOrbit account.',
            style: textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Obx(() {
            final err = ctrl.errorMessage.value;
            if (err == null || err.isEmpty) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Text(
                err,
                style: textTheme.bodyMedium?.copyWith(color: Colors.red.shade900),
                textAlign: TextAlign.center,
              ),
            );
          }),
          AppTextField(
            controller: _emailCtrl,
            label: 'Email Address',
            prefixIcon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
            onChanged: ctrl.setEmail,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required.';
              if (!GetUtils.isEmail(v)) return 'Please enter a valid email.';
              return null;
            },
          ),
          const SizedBox(height: 20),
          PasswordField(
            controller: _passwordCtrl,
            onChanged: ctrl.setPassword,
            label: "Password",
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required.';
              if (v.length < 6) return 'Password must be at least 6 characters.';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Row(
                  children: [
                    Checkbox(
                      value: ctrl.rememberMe.value,
                      onChanged: (val) {
                        if (val != null) ctrl.rememberMe.value = val;
                      },
                    ),
                    const Text('Remember Me'),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                child: const Text('Forgot Password?'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Obx(
            () => PrimaryButton(
              text: ctrl.isLoading.value ? 'Signing In...' : 'Sign In',
              onPressed: ctrl.isLoading.value ? null : ctrl.login,
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR'),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              text: "Don't have an account? ",
              style: textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: 'Register Now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(AppRoutes.register),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
