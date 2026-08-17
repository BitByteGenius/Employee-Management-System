import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/network/api_client.dart';

class ProjectService {
  final ApiClient apiClient;

  ProjectService(this.apiClient);

  Future<dynamic> getProjects({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? manager,
    String? department,
    String? sortBy,
    String? sortOrder,
  }) {
    return apiClient.get(
      ApiEndpoints.projects,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.isNotEmpty && status != 'all') 'status': status,
        if (manager != null && manager.isNotEmpty && manager != 'all') 'manager': manager,
        if (department != null && department.isNotEmpty && department != 'all') 'department': department,
        if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
        if (sortOrder != null && sortOrder.isNotEmpty) 'sortOrder': sortOrder,
      },
    );
  }

  Future<dynamic> getProject(String id) {
    return apiClient.get('${ApiEndpoints.projects}/$id');
  }

  Future<dynamic> createProject(Map<String, dynamic> data) {
    return apiClient.post(
      ApiEndpoints.projects,
      data: data,
    );
  }

  Future<dynamic> updateProject(String id, Map<String, dynamic> data) {
    return apiClient.patch(
      '${ApiEndpoints.projects}/$id',
      data: data,
    );
  }

  Future<dynamic> updateStatus(String id, String status) {
    return apiClient.patch(
      '${ApiEndpoints.projects}/$id/status',
      data: {'status': status},
    );
  }

  Future<dynamic> deleteProject(String id) {
    return apiClient.delete('${ApiEndpoints.projects}/$id');
  }
}
