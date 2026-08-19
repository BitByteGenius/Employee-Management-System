part of 'app_pages.dart';

/// Contains all the route names for the application.
abstract class AppRoutes {
  // Startup
  static const String splash = '/splash';

  // Authentication
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // super admin Dashboards
  static const String superAdminDashboard = '/super-admin/dashboard';
  static const String accessControl = '/super-admin/access-control';
  static const String departments = '/super-admin/departments';
  static const String superAdminProject = '/super-admin/projects';

  static const String adminDashboard = '/admin/dashboard';
  static const String employeeDashboard = '/employee/dashboard';

  // Core Features
  static const String projects = '/projects';
  static const String tasks = '/tasks';
  static const String reports = '/reports';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  /// Returns the dashboard route based on the user's role.
  static String dashboardForRole(String role) {
    final normalized = role.toLowerCase().trim();
    if (normalized.contains('super')) {
      return superAdminDashboard;
    } else if (normalized.contains('admin')) {
      return adminDashboard;
    } else if (normalized.contains('employee')) {
      return employeeDashboard;
    }
    return login;
  }
}