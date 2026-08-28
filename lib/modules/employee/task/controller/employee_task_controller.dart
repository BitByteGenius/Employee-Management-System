import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/services/storage_service.dart';
import 'package:tms/modules/employee/task/models/employee_task_model.dart';
import 'package:tms/modules/employee/task/service/employee_task_service.dart';

class EmployeeTaskController extends GetxController {
  final EmployeeTaskService _service = EmployeeTaskService();
  StorageService get _storage => Get.find<StorageService>();

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final tasks = <EmployeeTaskModel>[].obs;
  final selectedStatus = 'All'.obs;
  final selectedPriority = 'All'.obs;
  final searchQuery = ''.obs;

  String userId = '';

  @override
  void onInit() {
    super.onInit();
    _loadUserSession();
    fetchTasks();
  }

  void _loadUserSession() {
    final user = _storage.getUser();
    if (user != null) {
      userId = (user['id'] ?? user['_id'] ?? '').toString();
    }
  }

  Future<void> fetchTasks() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _service.fetchTasks(
        assigneeId: userId.isNotEmpty ? userId : null,
      );
      tasks.assignAll(result);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load tasks: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      final updated = await _service.updateTaskStatus(taskId, newStatus);
      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        tasks[index] = updated;
      }
      Get.snackbar(
        'Task Updated',
        'Status changed to ${updated.statusLabel}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Update Failed',
        'Failed to update status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFBA1A1A).withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  List<EmployeeTaskModel> get filteredTasks {
    return tasks.where((t) {
      if (selectedStatus.value != 'All') {
        final st = selectedStatus.value.toLowerCase().replaceAll(' ', '_');
        if (t.status != st) return false;
      }

      if (selectedPriority.value != 'All') {
        if (t.priority != selectedPriority.value.toLowerCase()) return false;
      }

      if (searchQuery.value.trim().isNotEmpty) {
        final q = searchQuery.value.trim().toLowerCase();
        final matchTitle = t.title.toLowerCase().contains(q);
        final matchProject = t.projectName.toLowerCase().contains(q);
        final matchDesc = t.description.toLowerCase().contains(q);
        return matchTitle || matchProject || matchDesc;
      }

      return true;
    }).toList();
  }

  List<EmployeeTaskModel> get todoTasks => filteredTasks.where((t) => t.isTodo).toList();
  List<EmployeeTaskModel> get inProgressTasks => filteredTasks.where((t) => t.isInProgress).toList();
  List<EmployeeTaskModel> get completedTasks => filteredTasks.where((t) => t.isCompleted).toList();
}
