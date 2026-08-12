import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class SuperAdminDashboardController extends GetxController {
  final isLoading = false.obs;
  final totalUsers = 0.obs;
  final totalAdmins = 0.obs;
  final totalEmployees = 0.obs;
  final pendingApprovalsCount = 0.obs;
  final totalDepartments = 0.obs;
  final totalProjects = 0.obs;
  final totalTasks = 0.obs;

  final pendingUsers = <Map<String, dynamic>>[].obs;
  final allUsers = <Map<String, dynamic>>[].obs;
  final auditLogs = <Map<String, dynamic>>[].obs;

  final selectedTab = 0.obs;

  ApiClient get _api => Get.find<ApiClient>();

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    try {
      final summaryRes = await _api.dio.get(ApiEndpoints.analyticsSummary).catchError((_) => null);
      if (summaryRes.data['success'] == true) {
        final data = summaryRes.data['data'];
        totalUsers.value = data['users'] ?? 0;
        totalDepartments.value = data['departments'] ?? 0;
        totalProjects.value = data['projects'] ?? 0;
        totalTasks.value = data['tasks'] ?? 0;
        pendingApprovalsCount.value = data['pendingApprovals'] ?? 0;
      }

      final usersRes = await _api.dio.get(ApiEndpoints.users).catchError((_) => null);
      if (usersRes.data['success'] == true) {
        final List list = usersRes.data['data'] ?? [];
        final parsed = list.cast<Map<String, dynamic>>();
        allUsers.assignAll(parsed);
        pendingUsers.assignAll(parsed.where((u) => u['accountStatus'] == 'pending').toList());
        totalAdmins.value = parsed.where((u) => u['role'] == 'admin').length;
        totalEmployees.value = parsed.where((u) => u['role'] == 'employee').length;
      }

      final auditRes = await _api.dio.get(ApiEndpoints.auditLogs).catchError((_) => null);
      if (auditRes.data['success'] == true) {
        final List list = auditRes.data['data'] ?? [];
        auditLogs.assignAll(list.cast<Map<String, dynamic>>().take(10).toList());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveUser(String userId) async {
    try {
      await _api.dio.patch(ApiEndpoints.approveUser(userId));
      Get.snackbar('Approved', 'User account approved successfully', backgroundColor: Colors.green, colorText: Colors.white);
      await fetchDashboardData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve user: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> rejectUser(String userId) async {
    try {
      await _api.dio.patch(ApiEndpoints.rejectUser(userId));
      Get.snackbar('Rejected', 'User account rejected', backgroundColor: Colors.orange, colorText: Colors.white);
      await fetchDashboardData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject user: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> toggleUserStatus(String userId, bool activate) async {
    try {
      final endpoint = activate ? ApiEndpoints.activateUser(userId) : ApiEndpoints.deactivateUser(userId);
      await _api.dio.patch(endpoint);
      Get.snackbar('Success', 'User status updated', backgroundColor: Colors.green, colorText: Colors.white);
      await fetchDashboardData();
    } catch (e) {
      Get.snackbar('Error', 'Status update failed: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}

