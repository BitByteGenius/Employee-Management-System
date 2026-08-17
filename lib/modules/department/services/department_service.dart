import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/modules/department/models/create_department_request.dart';

class DepartmentService {
  final ApiClient apiClient;

  DepartmentService(this.apiClient);

  // ==========================================================================
  // GET DEPARTMENTS
  // ==========================================================================

  Future<dynamic>getDepartments({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) {
    return apiClient.get(
      ApiEndpoints.departments,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null &&
            search.trim().isNotEmpty)
          'search': search.trim(),
        if (status != null &&
            status.isNotEmpty)
          'status': status,
        if (sortBy != null &&
            sortBy.isNotEmpty)
          'sortBy': sortBy,
        if (sortOrder != null &&
            sortOrder.isNotEmpty)
          'sortOrder': sortOrder,
      },
    );
  }

  // ==========================================================================
  // GET DEPARTMENT
  // ==========================================================================

  Future<dynamic> getDepartment(
    String id,
  ) {
    return apiClient.get(
      ApiEndpoints.department(id),
    );
  }

  // ==========================================================================
  // CREATE
  // ==========================================================================

  Future<dynamic> createDepartment(
    CreateDepartmentRequest request,
  ) {
    return apiClient.post(
      ApiEndpoints.departments,
      data: request.toJson(),
    );
  }

  // ==========================================================================
  // UPDATE
  // ==========================================================================

  Future<dynamic> updateDepartment(
    String id,
    Map<String, dynamic> data,
  ) {
    return apiClient.patch(
      ApiEndpoints.department(id),
      data: data,
    );
  }

  // ==========================================================================
  // DELETE / DEACTIVATE
  // ==========================================================================

  Future<dynamic> deleteDepartment(
    String id,
  ) {
    return apiClient.delete(
      ApiEndpoints.department(id),
    );
  }

  // ==========================================================================
  // ASSIGN ADMIN
  // ==========================================================================

  Future<dynamic> assignAdmin(
    String departmentId,
    String adminId,
  ) {
    return apiClient.patch(
      ApiEndpoints.departmentAdmin(
        departmentId,
      ),
      data: {
        'adminId': adminId,
      },
    );
  }

  // ==========================================================================
  // REMOVE ADMIN
  // ==========================================================================

  Future<dynamic> removeAdmin(
    String departmentId,
  ) {
    return apiClient.delete(
      ApiEndpoints.departmentAdmin(
        departmentId,
      ),
    );
  }

  // ==========================================================================
  // EMPLOYEES
  // ==========================================================================

  Future<dynamic> getEmployees(
    String departmentId, {
    int page = 1,
    int limit = 50,
    String? search,
  }) {
    return apiClient.get(
      ApiEndpoints.departmentEmployees(
        departmentId,
      ),
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null &&
            search.trim().isNotEmpty)
          'search': search.trim(),
      },
    );
  }

  // ==========================================================================
  // SETTINGS
  // ==========================================================================

  Future<dynamic> getSettings(
    String departmentId,
  ) {
    return apiClient.get(
      ApiEndpoints.departmentSettings(
        departmentId,
      ),
    );
  }

  Future<dynamic> updateSettings(
    String departmentId,
    Map<String, dynamic> data,
  ) {
    return apiClient.patch(
      ApiEndpoints.departmentSettings(
        departmentId,
      ),
      data: data,
    );
  }

  // ==========================================================================
  // REPORTS
  // ==========================================================================

  Future<dynamic> getReports(
    String departmentId,
  ) {
    return apiClient.get(
      ApiEndpoints.departmentReports(
        departmentId,
      ),
    );
  }
}