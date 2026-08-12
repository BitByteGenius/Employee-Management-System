import 'package:flutter/material.dart';

import 'app_text_field.dart';

class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.onChanged,
    this.validator,
  });

  final TextEditingController? controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      obscureText: true,
      prefixIcon: Icons.lock_outline,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
