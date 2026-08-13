import 'package:get/get.dart';
import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/core/services/storage_service.dart';

class EmployeeDashboardController extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Selected Section tab
  final selectedTab = 0.obs;

  // Employee personal metrics
  final myProjectsCount = 0.obs;
  final assignedTasksCount = 0.obs;
  final inProgressTasksCount = 0.obs;
  final completedTasksCount = 0.obs;
  final overdueTasksCount = 0.obs;
  final productivityPercentage = 100.obs;

  final userName = 'Employee'.obs;

  // Personal work lists
  final myTasksList = <Map<String, dynamic>>[].obs;
  final upcomingDeadlines = <Map<String, dynamic>>[].obs;
  final myProjectsList = <Map<String, dynamic>>[].obs;

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
      final name = user['fullName'] ?? user['name'] ?? 'Employee';
      userName.value = name.toString();
    }
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // 1. Fetch assigned tasks from API
      try {
        final taskRes = await _api.dio.get(ApiEndpoints.tasks);
        if (taskRes.data != null && taskRes.data['success'] == true) {
          final List list = taskRes.data['data'] ?? [];
          final parsed = list.cast<Map<String, dynamic>>();
          myTasksList.assignAll(parsed);
          assignedTasksCount.value = parsed.length;
          inProgressTasksCount.value = parsed.where((t) => t['status'] == 'in_progress' || t['status'] == 'started').length;
          completedTasksCount.value = parsed.where((t) => t['status'] == 'completed').length;
          overdueTasksCount.value = parsed.where((t) => t['status'] == 'overdue').length;
          upcomingDeadlines.assignAll(parsed.where((t) => t['dueDate'] != null || t['status'] != 'completed').take(5).toList());
        }
      } catch (_) {}

      // 2. Fetch my projects
      try {
        final projRes = await _api.dio.get(ApiEndpoints.projects);
        if (projRes.data != null && projRes.data['success'] == true) {
          final List list = projRes.data['data'] ?? [];
          final parsed = list.cast<Map<String, dynamic>>();
          myProjectsList.assignAll(parsed);
          myProjectsCount.value = parsed.length;
        }
      } catch (_) {}

    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load work overview: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
