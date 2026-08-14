import 'package:get/get.dart';
import 'package:tms/modules/admin/bindings/admin_dashboard_binding.dart';
import 'package:tms/modules/admin/views/admin_dashboard_view.dart';
import 'package:tms/modules/auth/bindings/auth_binding.dart';
import 'package:tms/modules/auth/views/login_view.dart';
import 'package:tms/modules/auth/views/register_view.dart';
import 'package:tms/modules/employee/bindings/employee_dashboard_binding.dart';
import 'package:tms/modules/employee/views/employee_dashboard_view.dart';
import 'package:tms/modules/splash/bindings/splash_binding.dart';
import 'package:tms/modules/splash/views/splash_view.dart';
import 'package:tms/modules/super_admin/bindings/super_admin_dashboard_binding.dart';

import 'package:tms/modules/super_admin/views/super_admin_shell_view.dart';

part 'app_routes.dart';

/// Centralized page management for the application.
class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.superAdminDashboard,
      page: () => const SuperAdminShellView(
        initialRoute: AppRoutes.superAdminDashboard,
      ),
      binding: SuperAdminDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.accessControl,
      page: () => const SuperAdminShellView(
        initialRoute: AppRoutes.accessControl,
      ),
      binding: SuperAdminDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.employeeDashboard,
      page: () => const EmployeeDashboardView(),
      binding: EmployeeDashboardBinding(),
    ),
  ];
}
