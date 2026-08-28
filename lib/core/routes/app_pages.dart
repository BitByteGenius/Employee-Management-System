import 'package:get/get.dart';
import 'package:tms/modules/admin/dashboard/bindings/admin_dashboard_binding.dart';
import 'package:tms/modules/admin/dashboard/views/admin_shell_view.dart';
import 'package:tms/modules/auth/bindings/auth_binding.dart';
import 'package:tms/modules/auth/views/login_view.dart';
import 'package:tms/modules/auth/views/register_view.dart';
import 'package:tms/modules/department/bindings/department_binding.dart';
import 'package:tms/modules/employee/dashboard/bindings/employee_dashboard_binding.dart';
import 'package:tms/modules/employee/dashboard/views/employee_shell_view.dart';
import 'package:tms/modules/splash/bindings/splash_binding.dart';
import 'package:tms/modules/splash/views/splash_view.dart';
import 'package:tms/modules/super_admin/acces%20controll/bindings/access_control_binding.dart';
import 'package:tms/modules/super_admin/dashboard/bindings/super_admin_dashboard_binding.dart';

import 'package:tms/modules/super_admin/dashboard/views/super_admin_shell_view.dart';
import 'package:tms/modules/super_admin/projects/blindings/project_blindings.dart';

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
      name: AppRoutes.departments,
      page: () => const SuperAdminShellView(
        initialRoute: AppRoutes.departments),
      binding: DepartmentBinding()
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
      page: () => const AdminShellView(
        initialRoute: AppRoutes.adminDashboard,
      ),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.workforce,
      page: () => const AdminShellView(
        initialRoute: AppRoutes.workforce,
      ),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.timeTracking,
      page: () => const AdminShellView(
        initialRoute: AppRoutes.timeTracking,
      ),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.adminProject,
      page: () => const AdminShellView(
        initialRoute: AppRoutes.adminProject,
      ),
      binding: AdminDashboardBinding(),
    ),
    
    // Employee Routes
    GetPage(
      name: AppRoutes.employeeDashboard,
      page: () => const EmployeeShellView(
        initialRoute: AppRoutes.employeeDashboard,
      ),
      binding: EmployeeDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.employeeTasks,
      page: () => const EmployeeShellView(
        initialRoute: AppRoutes.employeeTasks,
      ),
      binding: EmployeeDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.employeeProjects,
      page: () => const EmployeeShellView(
        initialRoute: AppRoutes.employeeProjects,
      ),
      binding: EmployeeDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.employeeTimeTracking,
      page: () => const EmployeeShellView(
        initialRoute: AppRoutes.employeeTimeTracking,
      ),
      binding: EmployeeDashboardBinding(),
    ),
  ];
}
