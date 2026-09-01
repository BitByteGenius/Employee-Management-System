import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/core/services/storage_service.dart';

class SuperAdminDashboardController extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // KPI Metrics
  final totalDepartments = 0.obs;
  final totalAdmins = 0.obs;
  final totalEmployees = 0.obs;
  final portfolioHealth = 100.obs; // %
  final utilization = 100.obs; // %
  final pendingApprovalsCount = 0.obs;

  // Strategic Data Lists
  final pendingUsers = <Map<String, dynamic>>[].obs;
  final allUsers = <Map<String, dynamic>>[].obs;
  final auditLogs = <Map<String, dynamic>>[].obs;
  final portfolioProjects = <Map<String, dynamic>>[].obs;
  final departmentPerformance = <Map<String, dynamic>>[].obs;

  final userName = 'Super Admin'.obs;
  final userAvatarUrl = ''.obs;

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
      final name = user['fullName'] ?? user['name'] ?? user['email'] ?? 'Super Admin';
      userName.value = name.toString();
      userAvatarUrl.value = (user['profilePicture'] ?? user['avatar'] ?? '').toString();
    }
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // 1. Fetch Analytics Summary
      try {
        final summaryRes = await _api.dio.get(ApiEndpoints.analyticsSummary);
        if (summaryRes.data != null && summaryRes.data['success'] == true) {
          final data = summaryRes.data['data'];
          if (data != null) {
            totalDepartments.value = data['departments'] ?? 0;
            totalEmployees.value = data['users'] ?? 0;
            pendingApprovalsCount.value = data['pendingApprovals'] ?? 0;
          }
        }
      } catch (_) {}

      // 2. Fetch Users Data
      try {
        final usersRes = await _api.dio.get(ApiEndpoints.users);
        if (usersRes.data != null && usersRes.data['success'] == true) {
          final List list = usersRes.data['data'] ?? [];
          final parsed = list.cast<Map<String, dynamic>>();
          allUsers.assignAll(parsed);
          totalAdmins.value = parsed.where((u) => u['role'] == 'admin').length;
          totalEmployees.value = parsed.where((u) => u['role'] == 'employee').length;
        }
      } catch (_) {}

      // 3. Fetch Pending Approvals
      try {
        final pendingRes = await _api.dio.get(ApiEndpoints.pendingUsers);
        if (pendingRes.data != null && pendingRes.data['success'] == true) {
          final List list = pendingRes.data['data'] ?? [];
          final parsed = list.cast<Map<String, dynamic>>();
          pendingUsers.assignAll(parsed);
          pendingApprovalsCount.value = parsed.length;
        }
      } catch (_) {}

      // 4. Fetch Audit Logs
      try {
        final auditRes = await _api.dio.get(ApiEndpoints.auditLogs);
        if (auditRes.data != null && auditRes.data['success'] == true) {
          final List list = auditRes.data['data'] ?? [];
          auditLogs.assignAll(list.cast<Map<String, dynamic>>().take(6).toList());
        }
      } catch (_) {}

      // 5. Fetch Portfolio Projects
      try {
        final projRes = await _api.dio.get(ApiEndpoints.projects);
        if (projRes.data != null && projRes.data['success'] == true) {
          final List list = projRes.data['data'] ?? [];
          portfolioProjects.assignAll(list.cast<Map<String, dynamic>>());
        }
      } catch (_) {}

    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load organization summary: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveUser(String userId) async {
    try {
      await _api.dio.patch(ApiEndpoints.approveUser(userId));
      Get.snackbar(
        'Approved',
        'User account approved successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      pendingUsers.removeWhere((u) => (u['id'] ?? u['_id']) == userId);
      pendingApprovalsCount.value = (pendingApprovalsCount.value - 1).clamp(0, 9999);
      fetchDashboardData();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to approve user: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> rejectUser(String userId) async {
    try {
      await _api.dio.patch(ApiEndpoints.rejectUser(userId));
      Get.snackbar(
        'Rejected',
        'User account request rejected',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      pendingUsers.removeWhere((u) => (u['id'] ?? u['_id']) == userId);
      pendingApprovalsCount.value = (pendingApprovalsCount.value - 1).clamp(0, 9999);
      fetchDashboardData();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reject user: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

