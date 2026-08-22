import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/modules/admin/my%20project/models/admin_project_model.dart';

class AdminProjectService {
  ApiClient get _api => Get.find<ApiClient>();

  /// Fetch projects dynamically scoped by the department
  Future<List<AdminProjectModel>> fetchProjects({
    String? status,
    String? search,
    String? departmentId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status.toLowerCase();
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (departmentId != null && departmentId.isNotEmpty) {
      queryParams['department'] = departmentId;
    }

    final response = await _api.dio.get(
      ApiEndpoints.projects,
      queryParameters: queryParams,
    );

    if (response.data != null && response.data['success'] == true) {
      final List rawList = response.data['data'] ?? [];
      return rawList
          .map((item) => AdminProjectModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }

  /// Fetch department employees dynamically from backend
  Future<List<Map<String, dynamic>>> fetchDepartmentEmployees({
    String? departmentId,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': 100,
    };
    if (departmentId != null && departmentId.isNotEmpty) {
      queryParams['department'] = departmentId;
    }

    final response = await _api.dio.get(
      ApiEndpoints.users,
      queryParameters: queryParams,
    );

    if (response.data != null && response.data['success'] == true) {
      final List rawList = response.data['data'] ?? [];
      return rawList.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return [];
  }

  /// Create a new project dynamically in MongoDB
  Future<AdminProjectModel> createProject(Map<String, dynamic> data) async {
    final response = await _api.dio.post(
      ApiEndpoints.projects,
      data: data,
    );

    if (response.data != null && response.data['data'] != null) {
      return AdminProjectModel.fromJson(Map<String, dynamic>.from(response.data['data']));
    }

    throw Exception(response.data?['message'] ?? 'Failed to create project');
  }

  /// Update project status
  Future<AdminProjectModel> updateProjectStatus(String id, String status) async {
    final response = await _api.dio.patch(
      '${ApiEndpoints.projects}/$id/status',
      data: {'status': status.toLowerCase()},
    );

    if (response.data != null && response.data['data'] != null) {
      return AdminProjectModel.fromJson(Map<String, dynamic>.from(response.data['data']));
    }

    throw Exception(response.data?['message'] ?? 'Failed to update project status');
  }

  /// Update project details
  Future<AdminProjectModel> updateProject(String id, Map<String, dynamic> data) async {
    final response = await _api.dio.patch(
      '${ApiEndpoints.projects}/$id',
      data: data,
    );

    if (response.data != null && response.data['data'] != null) {
      return AdminProjectModel.fromJson(Map<String, dynamic>.from(response.data['data']));
    }

    throw Exception(response.data?['message'] ?? 'Failed to update project');
  }

  /// Delete project
  Future<bool> deleteProject(String id) async {
    final response = await _api.dio.delete('${ApiEndpoints.projects}/$id');
    return response.data != null && response.data['success'] == true;
  }

  /// Create / Assign a task to an employee in this project
  Future<Map<String, dynamic>> createTask(Map<String, dynamic> data) async {
    final response = await _api.dio.post(
      ApiEndpoints.tasks,
      data: data,
    );

    if (response.data != null && response.data['data'] != null) {
      return Map<String, dynamic>.from(response.data['data']);
    }

    throw Exception(response.data?['message'] ?? 'Failed to create task');
  }

  /// Assign task with optional file attachment uploaded to Cloudinary & persisted in MongoDB
  Future<Map<String, dynamic>> assignTaskWithAttachment({
    required String projectId,
    required Map<String, dynamic> taskData,
    PlatformFile? attachedFile,
  }) async {
    final payload = <String, dynamic>{
      ...taskData,
      'project': projectId,
    };

    if (attachedFile != null) {
      final formData = FormData.fromMap(payload);

      if (kIsWeb && attachedFile.bytes != null) {
        formData.files.add(MapEntry(
          'file',
          MultipartFile.fromBytes(
            attachedFile.bytes!,
            filename: attachedFile.name,
          ),
        ));
      } else if (attachedFile.path != null) {
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(
            attachedFile.path!,
            filename: attachedFile.name,
          ),
        ));
      }

      final response = await _api.dio.post(
        ApiEndpoints.tasks,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.data != null && response.data['data'] != null) {
        return Map<String, dynamic>.from(response.data['data']);
      }

      throw Exception(response.data?['message'] ?? 'Failed to create task with attachment');
    } else {
      return createTask(payload);
    }
  }
}
