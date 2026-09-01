import 'package:get/get.dart';
import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/modules/employee/task/models/employee_task_model.dart';

class EmployeeTaskService {
  ApiClient get _api => Get.find<ApiClient>();

  /// Fetch tasks assigned to the employee from real MongoDB API
  Future<List<EmployeeTaskModel>> fetchTasks({
    String? status,
    String? priority,
    String? search,
    String? assigneeId,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': 100,
    };
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status.toLowerCase();
    }
    if (priority != null && priority.isNotEmpty && priority.toLowerCase() != 'all') {
      queryParams['priority'] = priority.toLowerCase();
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (assigneeId != null && assigneeId.isNotEmpty) {
      queryParams['assignee'] = assigneeId;
    }

    final response = await _api.dio.get(
      ApiEndpoints.tasks,
      queryParameters: queryParams,
    );

    if (response.data != null && response.data['success'] == true) {
      final List rawList = response.data['data'] ?? [];
      return rawList
          .map((item) => EmployeeTaskModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }

  /// Update task status in MongoDB
  Future<EmployeeTaskModel> updateTaskStatus(String taskId, String newStatus) async {
    final response = await _api.dio.patch(
      '${ApiEndpoints.tasks}/$taskId/status',
      data: {'status': newStatus.toLowerCase()},
    );

    if (response.data != null && response.data['data'] != null) {
      return EmployeeTaskModel.fromJson(Map<String, dynamic>.from(response.data['data']));
    }

    throw Exception(response.data?['message'] ?? 'Failed to update task status');
  }
}
