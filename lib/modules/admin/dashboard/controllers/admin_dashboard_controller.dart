import 'package:get/get.dart';
import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/core/services/storage_service.dart';

class AdminDashboardController extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Selected Top Navigation Tab (Overview = 0, Team = 1, Timeline = 2)
  final selectedTab = 0.obs;

  // Department KPI metrics
  final teamMembersCount = 0.obs;
  final activeProjectsCount = 0.obs;
  final pendingTasksCount = 0.obs;
  final completedTasksCount = 0.obs;
  final overdueTasksCount = 0.obs;

  final userName = 'Admin'.obs;
  final departmentName = 'Department Management'.obs;

  // Project progress lists
  final projectProgressList = <Map<String, dynamic>>[].obs;
  final upcomingDeadlines = <Map<String, dynamic>>[].obs;
  final teamWorkloadList = <Map<String, dynamic>>[].obs;

  ApiClient get _api => Get.find<ApiClient>();
  StorageService get _storage => Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    fetchDashboardData();
  }

  void _loadUserInfo() {
    final user = _storage.getUser();
    if (user != null) {
      final name = user['fullName'] ?? user['name'] ?? 'Admin';
      userName.value = name.toString();
      if (user['department'] != null) {
        departmentName.value = user['department'].toString();
      }
    }
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // 1. Fetch Department Projects
      try {
        final projRes = await _api.dio.get(ApiEndpoints.projects);
        if (projRes.data != null && projRes.data['success'] == true) {
          final List list = projRes.data['data'] ?? [];
          final projects = list.cast<Map<String, dynamic>>();
          activeProjectsCount.value = projects.length;
          projectProgressList.assignAll(projects);
        }
      } catch (_) {}

      // 2. Fetch Tasks
      try {
        final taskRes = await _api.dio.get(ApiEndpoints.tasks);
        if (taskRes.data != null && taskRes.data['success'] == true) {
          final List list = taskRes.data['data'] ?? [];
          final tasks = list.cast<Map<String, dynamic>>();
          pendingTasksCount.value = tasks.where((t) => t['status'] != 'completed').length;
          completedTasksCount.value = tasks.where((t) => t['status'] == 'completed').length;
          overdueTasksCount.value = tasks.where((t) => t['status'] == 'overdue').length;
          upcomingDeadlines.assignAll(tasks.where((t) => t['dueDate'] != null || t['status'] != 'completed').take(5).toList());
        }
      } catch (_) {}

      // 3. Fetch Users for Team Members count
      try {
        final usersRes = await _api.dio.get(ApiEndpoints.users);
        if (usersRes.data != null && usersRes.data['success'] == true) {
          final List list = usersRes.data['data'] ?? [];
          teamMembersCount.value = list.length;
        }
      } catch (_) {}

    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load department dashboard: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
