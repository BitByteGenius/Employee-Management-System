import 'package:get/get.dart';
import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/core/services/storage_service.dart';
import 'package:tms/modules/admin/dashboard/controllers/admin_dashboard_controller.dart';
import 'package:tms/modules/admin/my%20project/controller/admin_project_controller.dart';

class AdminShellController extends GetxController {
  final currentRoute = AppRoutes.adminDashboard.obs;
  final currentIndex = 0.obs;

  // Real User Session Info
  final userName = 'Admin'.obs;
  final userEmail = ''.obs;
  final userAvatarUrl = RxnString();
  final departmentRawName = ''.obs;
  final departmentDisplayName = 'Department'.obs;
  final userRoleDisplay = 'Department Admin'.obs;
  final unreadNotificationsCount = 0.obs;

  // Selected tab for top bar (Overview = 0, Team = 1, Timeline = 2)
  final selectedTabIndex = 0.obs;
  final searchQuery = ''.obs;

  StorageService get _storage => Get.find<StorageService>();

  final routes = <String>[
    AppRoutes.adminDashboard,
    AppRoutes.workforce,
    AppRoutes.timeTracking,
    AppRoutes.adminProject,
    AppRoutes.notifications,
    AppRoutes.reports,
  ];

  @override
  void onInit() {
    super.onInit();
    loadSessionInfo();
    refreshProfileFromApi();
  }

  /// Capitalize words and preserve known acronyms like HR, IT
  static String capitalizeWords(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      final upper = word.toUpperCase();
      if (upper == 'HR' || upper == 'IT') return upper;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Formats department name cleanly into standard format (e.g., HR Department, Sales Department, Development Department)
  static String formatDepartmentName(String? name) {
    if (name == null || name.trim().isEmpty) return '';
    final trimmed = name.trim();
    final lower = trimmed.toLowerCase();

    if (lower == 'hr' || lower == 'human resources' || lower == 'human resource') {
      return 'HR Department';
    }
    if (lower == 'sales' || lower == 'sale') {
      return 'Sales Department';
    }
    if (lower == 'development' || lower == 'dev' || lower == 'engineering' || lower == 'software') {
      return 'Development Department';
    }
    if (lower == 'marketing') {
      return 'Marketing Department';
    }
    if (lower == 'operations' || lower == 'ops') {
      return 'Operations Department';
    }
    if (lower == 'finance' || lower == 'accounts') {
      return 'Finance Department';
    }
    if (lower == 'support' || lower == 'customer support') {
      return 'Support Department';
    }

    if (lower.endsWith('department') || lower.endsWith('dept')) {
      return capitalizeWords(trimmed);
    }

    return '${capitalizeWords(trimmed)} Department';
  }

  /// Resolves the real display role for the user (e.g., HR Department, Sales Department, Development Department)
  static String resolveRoleDisplay(Map<String, dynamic>? user) {
    if (user == null) return 'Department Admin';

    // 1. Extract Department Name
    String deptStr = '';
    if (user['department'] is Map) {
      final d = user['department'] as Map;
      deptStr = (d['name'] ?? d['code'] ?? '').toString();
    } else if (user['departmentName'] != null && user['departmentName'].toString().isNotEmpty) {
      deptStr = user['departmentName'].toString();
    } else if (user['department'] is String && user['department'].toString().isNotEmpty) {
      deptStr = user['department'].toString();
    }

    if (deptStr.isNotEmpty) {
      return formatDepartmentName(deptStr);
    }

    // 2. Extract Assigned Role Label or Designation
    if (user['assignedRoleLabel'] != null && user['assignedRoleLabel'].toString().isNotEmpty) {
      return user['assignedRoleLabel'].toString();
    }
    if (user['designation'] != null && user['designation'].toString().isNotEmpty) {
      return user['designation'].toString();
    }

    // 3. Fallback based on system role
    final sysRole = (user['systemRole'] ?? user['role'] ?? '').toString().toUpperCase();
    if (sysRole.contains('ADMIN')) {
      return 'Department Admin';
    }
    return sysRole.isNotEmpty ? capitalizeWords(sysRole) : 'Department Admin';
  }

  /// Loads stored user information and updates reactive state
  void loadSessionInfo() {
    final user = _storage.getUser();
    if (user != null) {
      final name = user['fullName'] ?? user['name'] ?? 'Admin';
      userName.value = name.toString();
      userEmail.value = (user['email'] ?? '').toString();
      userAvatarUrl.value = (user['avatar'] ?? user['profilePicture'])?.toString();

      // Extract raw department
      String rawDept = '';
      if (user['department'] is Map) {
        final d = user['department'] as Map;
        rawDept = (d['name'] ?? d['code'] ?? '').toString();
      } else if (user['departmentName'] != null) {
        rawDept = user['departmentName'].toString();
      } else if (user['department'] is String) {
        rawDept = user['department'].toString();
      }
      departmentRawName.value = rawDept;

      // Resolved Display Names
      final formattedDept = formatDepartmentName(rawDept);
      departmentDisplayName.value = formattedDept.isNotEmpty ? formattedDept : 'Department';
      userRoleDisplay.value = resolveRoleDisplay(user);
    }
  }

  /// Refreshes profile in the background from backend to keep state synced
  Future<void> refreshProfileFromApi() async {
    try {
      if (!Get.isRegistered<ApiClient>()) return;
      final api = Get.find<ApiClient>();
      final res = await api.dio.get(ApiEndpoints.me);
      if (res.data != null && res.data['success'] == true) {
        final freshData = res.data['data'] as Map<String, dynamic>?;
        if (freshData != null) {
          await _storage.saveUser(freshData);
          loadSessionInfo();
        }
      }
    } catch (_) {}
  }

  int getRouteIndex(String route) {
    if (route == AppRoutes.adminDashboard) return 0;
    if (route == AppRoutes.workforce || route == AppRoutes.accessControl) return 1;
    if (route == AppRoutes.timeTracking || route == AppRoutes.departments) return 2;
    if (route == AppRoutes.adminProject || route == AppRoutes.superAdminProject || route == '/admin/project' || route == '/admin/projects') return 3;
    if (route == AppRoutes.notifications) return 4;
    if (route == AppRoutes.reports) return 5;
    return 0;
  }

  void setRoute(String route) {
    final index = getRouteIndex(route);
    currentRoute.value = route;
    currentIndex.value = index;
  }

  void setIndex(int index) {
    if (index < 0 || index >= routes.length) return;
    currentIndex.value = index;
    currentRoute.value = routes[index];
  }

  /// Contextual tabs for the top bar based on current route
  List<String>? get tabsForCurrentRoute {
    if (currentRoute.value == AppRoutes.adminDashboard) {
      return const ['Overview', 'Team', 'Timeline'];
    }
    return null;
  }

  /// Screen title / subtitle for the top bar based on active route
  String get screenSubtitle {
    switch (currentRoute.value) {
      case AppRoutes.adminDashboard:
        return 'Overview & Operations';
      case AppRoutes.workforce:
      case AppRoutes.accessControl:
        return 'Workforce & Team';
      case AppRoutes.timeTracking:
      case AppRoutes.departments:
        return 'Time Tracking & Logs';
      case AppRoutes.adminProject:
        return 'Active Assignments';
      case AppRoutes.notifications:
        return 'Notifications & Alerts';
      case AppRoutes.reports:
        return 'Reports & Analytics';
      default:
        return 'Department Admin';
    }
  }

  /// Handles tab selection from the top bar
  void changeTab(int index) {
    selectedTabIndex.value = index;
    if (Get.isRegistered<AdminDashboardController>()) {
      Get.find<AdminDashboardController>().changeTab(index);
    }
  }

  /// Handles search query change from top bar
  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (currentRoute.value == AppRoutes.adminProject && Get.isRegistered<AdminProjectController>()) {
      Get.find<AdminProjectController>().setSearch(query);
    }
  }
}