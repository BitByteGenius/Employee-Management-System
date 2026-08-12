import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/modules/auth/controller/login_controller.dart';
import 'package:tms/modules/auth/widget/auth_card.dart';
import 'package:tms/modules/auth/widget/auth_layout.dart';
import 'package:tms/modules/auth/widget/login_form.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthLayout(
      child: AuthCard(
        child: LoginForm(),
      ),
    );
  }
}
