import 'dart:io';
import 'package:flutter/foundation.dart';

/// Centralized constants for API endpoints matching backend v1 routes.
class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000/api/v1';
    return 'http://localhost:5000/api/v1';
  }

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Users
  static const String users = '/users';
  static const String pendingUsers = '/users?status=pending';
  static String approveUser(String id) => '/users/$id/approve';
  static String rejectUser(String id) => '/users/$id/reject';
  static String assignUserDepartment(String id) => '/users/$id/department';
  static String assignUserRole(String id) => '/users/$id/assign-role';
  static String activateUser(String id) => '/users/$id/activate';
  static String deactivateUser(String id) => '/users/$id/deactivate';
  static String updateUserRole(String id) => '/users/$id/role';

  // Modules
  static const String departments = '/departments';
  static const String projects = '/projects';
  static const String tasks = '/tasks';
  static const String roles = '/roles';
  static const String settings = '/settings';
  static const String auditLogs = '/audit-logs';

  // Analytics & Reports
  static const String analyticsSummary = '/analytics/summary';
  static const String reportWorkload = '/reports/workload';
  static const String reportProjectProgress = '/reports/project-progress';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';
}

