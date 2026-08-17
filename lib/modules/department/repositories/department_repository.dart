import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tms/modules/department/models/create_department_request.dart';
import 'package:tms/modules/department/models/department_employee_model.dart';
import 'package:tms/modules/department/models/department_models.dart';
import 'package:tms/modules/department/services/department_service.dart';

class DepartmentRepository {
  final DepartmentService service;

  DepartmentRepository(this.service);

  // ==========================================================================
  // LIST
  // ==========================================================================

  Future<DepartmentListResult> getDepartments({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    final response = await service.getDepartments(
      page: page,
      limit: limit,
      search: search,
      status: status,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    final json = _map(response);

    final rawItems =
        json['departments'] ??
        json['items'] ??
        json['data'] ??
        [];

    final items = <DepartmentModel>[];

    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          items.add(
            DepartmentModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    final pagination =
        json['pagination'] as Map<String, dynamic>?;

    return DepartmentListResult(
      departments: items,
      page: _int(pagination?['page'], fallback: page),
      totalPages:
          _int(pagination?['totalPages'], fallback: 1),
      total: _int(
        pagination?['total'],
        fallback: items.length,
      ),
    );
  }

  // ==========================================================================
  // GET SINGLE
  // ==========================================================================

  Future<DepartmentModel> getDepartment(String id) async {
    final response = await service.getDepartment(id);
    final json = _map(response);
    final data = _extractData(json);

    return DepartmentModel.fromJson(data);
  }

  // ==========================================================================
  // CREATE
  // ==========================================================================

  Future<DepartmentModel> createDepartment(
    CreateDepartmentRequest request,
  ) async {
    final response =
        await service.createDepartment(request);
    final json = _map(response);
    final data = _extractData(json);

    return DepartmentModel.fromJson(data);
  }

  // ==========================================================================
  // UPDATE
  // ==========================================================================

  Future<DepartmentModel> updateDepartment(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response =
        await service.updateDepartment(id, data);
    final json = _map(response);
    final extracted = _extractData(json);

    return DepartmentModel.fromJson(extracted);
  }

  // ==========================================================================
  // STATUS
  // ==========================================================================

  Future<DepartmentModel> updateStatus(
    String id,
    String status,
  ) async {
    final response =
        await service.updateDepartment(id, {'status': status});
    final json = _map(response);
    final data = _extractData(json);

    return DepartmentModel.fromJson(data);
  }

  // ==========================================================================
  // ADMIN
  // ==========================================================================

  Future<DepartmentModel> assignAdmin(
    String id,
    String adminId,
  ) async {
    final response =
        await service.assignAdmin(id, adminId);
    final json = _map(response);
    final data = _extractData(json);

    return DepartmentModel.fromJson(data);
  }

  Future<DepartmentModel> removeAdmin(String id) async {
    final response = await service.removeAdmin(id);
    final json = _map(response);
    final data = _extractData(json);

    return DepartmentModel.fromJson(data);
  }

  // ==========================================================================
  // EMPLOYEES
  // ==========================================================================

  Future<List<DepartmentEmployeeModel>> getEmployees(
    String id, {
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final response = await service.getEmployees(
      id,
      page: page,
      limit: limit,
      search: search,
    );

    final json = _map(response);

    final raw =
        json['employees'] ??
        json['users'] ??
        json['data'] ??
        [];

    final items = <DepartmentEmployeeModel>[];

    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          items.add(
            DepartmentEmployeeModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return items;
  }

  // ==========================================================================
  // DELETE
  // ==========================================================================

  Future<bool> deleteDepartment(String id) async {
    final response = await service.deleteDepartment(id);
    final json = _map(response);

    return json['success'] == true ||
        response is! Map ||
        response['success'] == true;
  }

  // ==========================================================================
  // SEARCH USERS (for Admin selection)
  // ==========================================================================

  Future<List<DepartmentEmployeeModel>> searchUsers(String query) async {
    try {
      final response = await service.searchUsers(query);
      final json = _map(response);
      final raw = json['data'] ?? json['users'] ?? json['items'] ?? [];

      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((item) => DepartmentEmployeeModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }

      if (response is List) {
        return response
            .whereType<Map>()
            .map((item) => DepartmentEmployeeModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      debugPrint('[DepartmentRepository] searchUsers error: $e');
    }
    return [];
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  Map<String, dynamic> _map(dynamic response) {
    if (response is Response) {
      return _map(response.data);
    }
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    return {};
  }

  Map<String, dynamic> _extractData(Map<String, dynamic> json) {
    final data = json['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return json;
  }

  int _int(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        fallback;
  }
}

class DepartmentListResult {
  final List<DepartmentModel> departments;
  final int page;
  final int totalPages;
  final int total;

  const DepartmentListResult({
    required this.departments,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}