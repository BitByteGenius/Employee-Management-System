import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/services/storage_service.dart';
import 'package:tms/modules/admin/my%20project/models/admin_project_model.dart';
import 'package:tms/modules/admin/my%20project/service/admin_project_service.dart';

class AdminProjectController extends GetxController {
  final AdminProjectService _service = AdminProjectService();
  StorageService get _storage => Get.find<StorageService>();

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final departmentName = 'Department'.obs;
  final departmentId = ''.obs;
  final userName = 'Admin'.obs;
  final userRole = 'Department Admin'.obs;

  // Real projects list from API
  final projects = <AdminProjectModel>[].obs;

  // Real employees list from API for assignment dropdowns
  final departmentEmployees = <Map<String, dynamic>>[].obs;

  // Active filters
  final selectedFilter = 'All'.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAdminSession();
    fetchProjects();
    fetchDepartmentEmployees();
  }

  void _loadAdminSession() {
    final user = _storage.getUser();
    if (user != null) {
      userName.value = (user['fullName'] ?? user['name'] ?? 'Admin').toString();
      userRole.value = (user['assignedRoleLabel'] ?? user['systemRole'] ?? 'Department Admin').toString();

      if (user['department'] is Map) {
        final d = user['department'] as Map;
        departmentName.value = (d['name'] ?? d['code'] ?? 'Department').toString();
        departmentId.value = (d['_id'] ?? d['id'] ?? '').toString();
      } else if (user['departmentName'] != null) {
        departmentName.value = user['departmentName'].toString();
        departmentId.value = (user['departmentId'] ?? user['department'] ?? '').toString();
      } else if (user['department'] != null) {
        departmentId.value = user['department'].toString();
      }
    }
  }

  /// Live filtered project list based on status and search query
  List<AdminProjectModel> get filteredProjects {
    return projects.where((p) {
      // 1. Status Filter
      if (selectedFilter.value != 'All') {
        final f = selectedFilter.value.toLowerCase().replaceAll(' ', '_');
        if (p.normalizedStatus != f) {
          return false;
        }
      }

      // 2. Search Query
      if (searchQuery.value.trim().isNotEmpty) {
        final query = searchQuery.value.trim().toLowerCase();
        final matchName = p.name.toLowerCase().contains(query);
        final matchKey = p.key.toLowerCase().contains(query);
        final matchRole = p.displayRole.toLowerCase().contains(query);
        final matchManager = (p.managerName ?? '').toLowerCase().contains(query);
        return matchName || matchKey || matchRole || matchManager;
      }

      return true;
    }).toList();
  }

  /// Fetch projects dynamically from the API
  Future<void> fetchProjects() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _service.fetchProjects(
        departmentId: departmentId.value.isNotEmpty ? departmentId.value : null,
      );
      projects.assignAll(result);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load projects: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch department employees dynamically from the API
  Future<void> fetchDepartmentEmployees() async {
    try {
      final employees = await _service.fetchDepartmentEmployees(
        departmentId: departmentId.value.isNotEmpty ? departmentId.value : null,
      );
      departmentEmployees.assignAll(employees);
    } catch (_) {}
  }

  /// Set the active filter status
  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  /// Set the search query
  void setSearch(String query) {
    searchQuery.value = query;
  }

  /// Create or request a new project in the real database
  Future<bool> createProject({
    required String name,
    required String role,
    String? description,
    String? status,
    int? progress,
    DateTime? dueDate,
    String? managerId,
    List<String>? memberIds,
  }) async {
    isSubmitting.value = true;
    try {
      final payload = <String, dynamic>{
        'name': name.trim(),
        'role': role.trim(),
        'description': description?.trim() ?? '',
        'status': (status ?? 'active').toLowerCase().replaceAll(' ', '_'),
        'progress': progress ?? 0,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        if (managerId != null && managerId.isNotEmpty) 'manager': managerId,
        if (memberIds != null && memberIds.isNotEmpty) 'members': memberIds,
        if (departmentId.value.isNotEmpty) 'department': departmentId.value,
      };

      final newProj = await _service.createProject(payload);
      projects.insert(0, newProj);
      Get.snackbar(
        'Success',
        'Project "${newProj.name}" created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create project: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFBA1A1A).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Update project status dynamically
  Future<void> updateStatus(String projectId, String newStatus) async {
    try {
      final updated = await _service.updateProjectStatus(projectId, newStatus);
      final index = projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        projects[index] = updated;
      }
      Get.snackbar(
        'Updated',
        'Status updated to ${updated.statusLabel}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Delete project dynamically
  Future<void> deleteProject(String projectId) async {
    try {
      final success = await _service.deleteProject(projectId);
      if (success) {
        projects.removeWhere((p) => p.id == projectId);
        Get.snackbar(
          'Deleted',
          'Project removed successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete project: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Assign a new task to an employee in this project
  Future<bool> assignTaskToEmployee({
    required String projectId,
    required String title,
    String? description,
    required String assigneeId,
    String? priority,
    DateTime? dueDate,
  }) async {
    isSubmitting.value = true;
    try {
      final payload = <String, dynamic>{
        'title': title.trim(),
        'project': projectId,
        'assignee': assigneeId,
        'priority': (priority ?? 'medium').toLowerCase(),
        'status': 'todo',
        if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      };

      await _service.createTask(payload);

      // Increment tasksCount in reactive project list
      final index = projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        final p = projects[index];
        final updatedCount = p.tasksCount + 1;
        final updatedRatio = '${p.completedTasksCount}/$updatedCount';
        projects[index] = AdminProjectModel(
          id: p.id,
          name: p.name,
          key: p.key,
          role: p.role,
          description: p.description,
          status: p.status,
          progress: p.progress,
          dueDate: p.dueDate,
          startDate: p.startDate,
          createdAt: p.createdAt,
          managerName: p.managerName,
          managerId: p.managerId,
          departmentName: p.departmentName,
          departmentId: p.departmentId,
          tasksCount: updatedCount,
          completedTasksCount: p.completedTasksCount,
          tasksRatio: updatedRatio,
          deliverables: p.deliverables,
          members: p.members,
        );
      }

      Get.snackbar(
        'Task Assigned',
        'Task "$title" assigned successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Assignment Failed',
        'Failed to assign task: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFBA1A1A).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
