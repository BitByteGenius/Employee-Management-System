import 'package:get/get.dart';
import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/core/services/storage_service.dart';

class EmployeeDashboardController extends GetxController {
  final currentRoute = AppRoutes.employeeDashboard.obs;

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Selected Tab index for TopBar
  final selectedTab = 0.obs;

  // Dynamic user session properties
  final userName = 'Employee'.obs;
  final userRoleDisplay = 'Employee'.obs;
  final departmentDisplayName = 'My Department'.obs;
  final userAvatarUrl = ''.obs;
  final unreadNotificationsCount = 0.obs;

  // Employee personal metrics
  final myProjectsCount = 0.obs;
  final assignedTasksCount = 0.obs;
  final inProgressTasksCount = 0.obs;
  final completedTasksCount = 0.obs;
  final overdueTasksCount = 0.obs;
  final productivityPercentage = 100.obs;

  // Personal work lists from MongoDB
  final myTasksList = <Map<String, dynamic>>[].obs;
  final upcomingDeadlines = <Map<String, dynamic>>[].obs;
  final myProjectsList = <Map<String, dynamic>>[].obs;

  // Active Project for quick widget overview
  final activeProjectName = ''.obs;
  final activeProjectProgress = 0.0.obs;
  final activeProjectTasksInfo = ''.obs;
  final activeProjectDeadline = ''.obs;

  ApiClient get _api => Get.find<ApiClient>();
  StorageService get _storage => Get.find<StorageService>();

  String userId = '';

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    fetchDashboardData();
    _fetchProfileBackground();
  }

  void setRoute(String route) {
    currentRoute.value = route;
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  List<String> get tabsForCurrentRoute {
    if (currentRoute.value == AppRoutes.employeeDashboard) {
      return const ['Overview', 'My Tasks', 'Timeline'];
    }
    return const [];
  }

  String get screenSubtitle {
    switch (currentRoute.value) {
      case AppRoutes.employeeTasks:
      case AppRoutes.tasks:
        return 'Deliverables & Tasks';
      case AppRoutes.employeeProjects:
        return 'Assigned Projects';
      case AppRoutes.employeeTimeTracking:
        return 'Attendance & Work Logs';
      case AppRoutes.notifications:
        return 'Alerts & Messages';
      case AppRoutes.employeeDashboard:
      default:
        return 'Personal Work Overview';
    }
  }

  void _loadUserInfo() {
    final user = _storage.getUser();
    if (user != null) {
      userId = (user['id'] ?? user['_id'] ?? '').toString();
      final name = user['fullName'] ?? user['name'] ?? 'Employee';
      userName.value = name.toString();
      userAvatarUrl.value = (user['profilePicture'] ?? '').toString();

      // Dynamic real role / designation
      final designation = user['designation'] ?? user['assignedRoleLabel'] ?? user['roleName'] ?? 'Employee';
      userRoleDisplay.value = designation.toString();

      // Dynamic department name
      if (user['department'] is Map) {
        final d = user['department'] as Map;
        departmentDisplayName.value = formatDepartmentName((d['name'] ?? d['code'] ?? 'Department').toString());
      } else if (user['departmentName'] != null) {
        departmentDisplayName.value = formatDepartmentName(user['departmentName'].toString());
      }
    }
  }

  String formatDepartmentName(String raw) {
    final clean = raw.trim();
    if (clean.isEmpty) return 'Department';
    if (clean.toLowerCase().endsWith('department')) return clean;
    if (clean.toLowerCase() == 'hr') return 'HR Department';
    if (clean.toLowerCase() == 'dev' || clean.toLowerCase() == 'development') return 'Development Department';
    if (clean.toLowerCase() == 'sales') return 'Sales Department';
    if (clean.toLowerCase() == 'marketing') return 'Marketing Department';
    return '$clean Department';
  }

  Future<void> _fetchProfileBackground() async {
    try {
      final res = await _api.dio.get(ApiEndpoints.me);
      if (res.data != null && res.data['success'] == true) {
        final user = res.data['data'] ?? res.data['user'];
        if (user != null) {
          _storage.saveUser(user);
          _loadUserInfo();
        }
      }
    } catch (_) {}
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // 1. Fetch assigned tasks from MongoDB API
      try {
        final taskRes = await _api.dio.get(
          ApiEndpoints.tasks,
          queryParameters: userId.isNotEmpty ? {'assignee': userId} : null,
        );
        if (taskRes.data != null && taskRes.data['success'] == true) {
          final List list = taskRes.data['data'] ?? [];
          final parsed = list.cast<Map<String, dynamic>>();
          myTasksList.assignAll(parsed);

          final total = parsed.length;
          final inProgress = parsed.where((t) => t['status'] == 'in_progress' || t['status'] == 'started').length;
          final completed = parsed.where((t) => t['status'] == 'completed' || t['status'] == 'done').length;

          final now = DateTime.now();
          final overdue = parsed.where((t) {
            if (t['status'] == 'completed' || t['status'] == 'done') return false;
            if (t['dueDate'] == null) return false;
            final d = DateTime.tryParse(t['dueDate'].toString());
            return d != null && d.isBefore(now);
          }).length;

          assignedTasksCount.value = total;
          inProgressTasksCount.value = inProgress;
          completedTasksCount.value = completed;
          overdueTasksCount.value = overdue;

          if (total > 0) {
            productivityPercentage.value = ((completed / total) * 100).round();
          } else {
            productivityPercentage.value = 100;
          }

          // Upcoming deadlines
          final withDates = parsed.where((t) => t['dueDate'] != null && t['status'] != 'completed').toList();
          withDates.sort((a, b) {
            final da = DateTime.tryParse(a['dueDate'].toString()) ?? DateTime(2099);
            final db = DateTime.tryParse(b['dueDate'].toString()) ?? DateTime(2099);
            return da.compareTo(db);
          });

          upcomingDeadlines.assignAll(withDates.take(5).map((t) {
            final d = DateTime.tryParse(t['dueDate'].toString());
            final dateStr = d != null ? '${d.month}/${d.day}/${d.year}' : 'Soon';
            final isWarn = d != null && d.isBefore(now.add(const Duration(days: 2)));
            return {
              'title': (t['title'] ?? t['task'] ?? 'Task').toString(),
              'due': 'Due $dateStr',
              'isWarning': isWarn,
            };
          }).toList());
        }
      } catch (_) {}

      // 2. Fetch projects from MongoDB API
      try {
        final projRes = await _api.dio.get(ApiEndpoints.projects);
        if (projRes.data != null && projRes.data['success'] == true) {
          final List list = projRes.data['data'] ?? [];
          final parsed = list.cast<Map<String, dynamic>>();
          myProjectsList.assignAll(parsed);
          myProjectsCount.value = parsed.length;

          if (parsed.isNotEmpty) {
            final p = parsed.first;
            activeProjectName.value = (p['name'] ?? 'Active Project').toString();
            final prg = (p['progress'] is num) ? (p['progress'] as num).toDouble() : 0.0;
            activeProjectProgress.value = (prg / 100.0).clamp(0.0, 1.0);
            activeProjectTasksInfo.value = 'Total Tasks: ${p['tasksCount'] ?? 0}  |  Completed: ${p['completedTasksCount'] ?? 0}';
            activeProjectDeadline.value = p['dueDate'] != null ? 'Target: ${p['dueDate'].toString().split('T')[0]}' : 'Active';
          }
        }
      } catch (_) {}
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load work overview: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
