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
import 'package:tms/modules/super_admin/acces%20controll/bindings/access_control_binding.dart';
import 'package:tms/modules/super_admin/dashboard/bindings/super_admin_dashboard_binding.dart';
import 'package:tms/modules/super_admin/projects/blindings/project_blindings.dart';

import 'package:tms/modules/super_admin/dashboard/views/super_admin_shell_view.dart';
import 'package:tms/modules/super_admin/projects/view/projects_overview_screen.dart';

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
      binding: AccessControlBinding(),
    ),
   GetPage(
  name: AppRoutes.superAdminProject,
  page: () => const SuperAdminShellView(
    initialRoute: AppRoutes.superAdminProject,
  ),
  binding: SuperAdminProjectBinding(),
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
