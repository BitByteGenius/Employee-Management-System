import 'package:get/get.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/modules/auth/bindings/auth_binding.dart';
import 'package:tms/modules/auth/views/login_view.dart';
import 'package:tms/modules/auth/views/register_view.dart';
import 'package:tms/modules/splash/bindings/splash_binding.dart';
import 'package:tms/modules/splash/views/splash_view.dart';

abstract final class AuthPages {
  AuthPages._();

  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: SplashView.new,
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: LoginView.new,
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: RegisterView.new,
      binding: AuthBinding(),
    ),
  ];
}
