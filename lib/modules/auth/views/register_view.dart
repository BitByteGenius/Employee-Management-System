import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/modules/auth/controller/register_controller.dart';
import 'package:tms/modules/auth/widget/auth_card.dart';
import 'package:tms/modules/auth/widget/auth_layout.dart';
import 'package:tms/shared/buttons/primary_button.dart';
import 'package:tms/shared/forms/app_text_field.dart';
import 'package:tms/shared/forms/password_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RegisterController>();

    return AuthLayout(
      child: AuthCard(
        title: 'Create Account',
        subtitle: 'Request access to the TeamOrbit workspace',
        child: Form(
          key: ctrl.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _firstNameCtrl,
                label: 'First name',
                prefixIcon: Icons.person_outline,
                onChanged: ctrl.setFirstName,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter first name' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _lastNameCtrl,
                label: 'Last name',
                prefixIcon: Icons.person_outline,
                onChanged: ctrl.setLastName,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter last name' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailCtrl,
                label: 'Email',
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                onChanged: ctrl.setEmail,
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Enter valid email' : null,
              ),
              const SizedBox(height: 16),
              Text('Request Role', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 6),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: ctrl.selectedRole.value,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: ctrl.availableRoles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role == 'admin' ? 'Admin' : 'Employee'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) ctrl.selectedRole.value = val;
                  },
                ),
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: _passwordCtrl,
                onChanged: ctrl.setPassword,
                validator: (v) =>
                    v == null || v.length < 8 ? 'Minimum 8 characters required' : null,
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: _confirmPwdCtrl,
                label: 'Confirm password',
                validator: (v) =>
                    v != _passwordCtrl.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 24),
              Obx(() {
                final err = ctrl.errorMessage.value;
                if (err == null || err.isEmpty) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    err,
                    style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                  ),
                );
              }),
              Obx(
                () => PrimaryButton(
                  text: ctrl.isLoading.value ? 'Registering...' : 'Register Account',
                  onPressed: ctrl.isLoading.value ? null : ctrl.register,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  TextButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.login),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
