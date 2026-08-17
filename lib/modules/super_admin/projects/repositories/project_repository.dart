import 'package:tms/modules/super_admin/projects/models/project_model.dart';
import 'package:tms/modules/super_admin/projects/services/project_service.dart';

class ProjectRepository {
  final ProjectService service;

  ProjectRepository(this.service);

  Future<ProjectListResult> getProjects({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? manager,
    String? department,
    String? sortBy,
    String? sortOrder,
  }) async {
    final response = await service.getProjects(
      page: page,
      limit: limit,
      search: search,
      status: status,
      manager: manager,
      department: department,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    final json = _map(response);
    final rawItems = json['data'] ?? json['projects'] ?? json['items'] ?? [];
    final items = <ProjectModel>[];

    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          items.add(ProjectModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final pagination = json['pagination'] is Map
        ? Map<String, dynamic>.from(json['pagination'])
        : <String, dynamic>{};

    return ProjectListResult(
      projects: items,
      page: _int(pagination['page'], fallback: page),
      totalPages: _int(pagination['totalPages'], fallback: 1),
      total: _int(pagination['total'], fallback: items.length),
    );
  }

  Future<ProjectModel> getProject(String id) async {
    final response = await service.getProject(id);
    final json = _map(response);
    final data = json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json;
    return ProjectModel.fromJson(data);
  }

  Future<ProjectModel> createProject(Map<String, dynamic> data) async {
    final response = await service.createProject(data);
    final json = _map(response);
    final respData = json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json;
    return ProjectModel.fromJson(respData);
  }

  Future<ProjectModel> updateProject(String id, Map<String, dynamic> data) async {
    final response = await service.updateProject(id, data);
    final json = _map(response);
    final respData = json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json;
    return ProjectModel.fromJson(respData);
  }

  Future<ProjectModel> updateStatus(String id, String status) async {
    final response = await service.updateStatus(id, status);
    final json = _map(response);
    final respData = json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json;
    return ProjectModel.fromJson(respData);
  }

  Future<void> deleteProject(String id) async {
    await service.deleteProject(id);
  }

  Map<String, dynamic> _map(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    try {
      final data = response?.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
    } catch (_) {}
    return {};
  }

  int _int(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
