// import 'dart:async';
// import 'package:dio/dio.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:tms/core/constants/api_endpoints.dart';
// import 'package:tms/core/network/api_client.dart';
// import 'package:tms/modules/super_admin/models/access_control_pending_user.dart';

// class AccessControlController extends GetxController {
//   final isLoading = false.obs;
//   final isRefreshing = false.obs;
//   final isActionLoading = false.obs;
//   final errorMessage = ''.obs;
//   final pendingUsers = <AccessControlPendingUser>[].obs;
//   final departments = <Map<String, dynamic>>[].obs;
//   final roles = <Map<String, dynamic>>[].obs;
//   final selectedTab = 0.obs;
//   final searchQuery = ''.obs;
//   final roleFilter = ''.obs;
//   final sortBy = 'createdAt'.obs;
//   final sortAscending = false.obs;
//   final currentPage = 1.obs;
//   final pageSize = 10.obs;
//   final totalPending = 0.obs;
//   final summaryAdmins = 0.obs;
//   final summaryEmployees = 0.obs;
//   Timer? _searchDebounce;

//   ApiClient get _api => Get.find<ApiClient>();

//   int get totalPages => (totalPending.value / pageSize.value).ceil().clamp(1, 9999);
//   int get adminPendingCount => summaryAdmins.value;
//   int get employeePendingCount => summaryEmployees.value;
//   int get startItem => totalPending.value == 0 ? 0 : ((currentPage.value - 1) * pageSize.value) + 1;
//   int get endItem {
//     final end = currentPage.value * pageSize.value;
//     return end > totalPending.value ? totalPending.value : end;
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     fetchPendingUsers();
//     fetchDepartments();
//     fetchRoles();
//   }

//   @override
//   void onClose() {
//     _searchDebounce?.cancel();
//     super.onClose();
//   }

//   Future<void> fetchPendingUsers({bool refresh = false}) async {
//     if (refresh) {
//       isRefreshing.value = true;
//     } else {
//       isLoading.value = true;
//     }
//     errorMessage.value = '';

//     try {
//       final response = await _api.dio.get(
//         ApiEndpoints.users,
//         queryParameters: {
//           'status': 'pending',
//           'page': currentPage.value,
//           'limit': pageSize.value,
//           'sortBy': sortBy.value,
//           'sortOrder': sortAscending.value ? 'asc' : 'desc',
//           if (searchQuery.value.trim().isNotEmpty) 'search': searchQuery.value.trim(),
//         },
//       );

//       if (response.data?['success'] == true) {
//         final list = (response.data['data'] as List? ?? [])
//             .cast<Map<String, dynamic>>()
//             .map(AccessControlPendingUser.fromJson)
//             .where((u) => roleFilter.value.isEmpty || u.role.toLowerCase() == roleFilter.value.toLowerCase())
//             .toList();
//         pendingUsers.assignAll(list);
//         totalPending.value = response.data['meta']?['total'] ?? list.length;
//         await fetchQueueSummary();
//       } else {
//         errorMessage.value = 'Unable to load pending approvals.';
//       }
//     } catch (e) {
//       errorMessage.value = _friendlyError(e);
//     } finally {
//       isLoading.value = false;
//       isRefreshing.value = false;
//     }
//   }

//   Future<void> fetchQueueSummary() async {
//     try {
//       final response = await _api.dio.get(
//         ApiEndpoints.users,
//         queryParameters: {'status': 'pending', 'page': 1, 'limit': 100, 'sortBy': 'createdAt', 'sortOrder': 'desc'},
//       );
//       if (response.data?['success'] == true) {
//         final list = (response.data['data'] as List? ?? [])
//             .cast<Map<String, dynamic>>()
//             .map(AccessControlPendingUser.fromJson)
//             .toList();
//         summaryAdmins.value = list.where((u) => u.isAdmin).length;
//         summaryEmployees.value = list.where((u) => u.isEmployee).length;
//         totalPending.value = response.data['meta']?['total'] ?? list.length;
//       }
//     } catch (_) {}
//   }

//   Future<void> fetchDepartments() async {
//     try {
//       final response = await _api.dio.get(ApiEndpoints.departments);
//       if (response.data?['success'] == true) {
//         departments.assignAll((response.data['data'] as List? ?? []).cast<Map<String, dynamic>>());
//       }
//     } catch (_) {}
//   }

//   Future<void> fetchRoles() async {
//     try {
//       final response = await _api.dio.get(ApiEndpoints.roles);
//       if (response.data?['success'] == true) {
//         roles.assignAll((response.data['data'] as List? ?? []).cast<Map<String, dynamic>>());
//       }
//     } catch (_) {}
//   }

//   void onSearchChanged(String value) {
//     searchQuery.value = value;
//     _searchDebounce?.cancel();
//     _searchDebounce = Timer(const Duration(milliseconds: 350), () {
//       currentPage.value = 1;
//       fetchPendingUsers();
//     });
//   }

//   void applyRoleFilter(String value) {
//     roleFilter.value = value;
//     currentPage.value = 1;
//     fetchPendingUsers();
//   }

//   void clearFilters() {
//     roleFilter.value = '';
//     searchQuery.value = '';
//     currentPage.value = 1;
//     fetchPendingUsers();
//   }

//   void setSort(String field) {
//     if (sortBy.value == field) {
//       sortAscending.value = !sortAscending.value;
//     } else {
//       sortBy.value = field;
//       sortAscending.value = field == 'fullName';
//     }
//     currentPage.value = 1;
//     fetchPendingUsers();
//   }

//   void nextPage() {
//     if (currentPage.value >= totalPages) return;
//     currentPage.value++;
//     fetchPendingUsers();
//   }

//   void previousPage() {
//     if (currentPage.value <= 1) return;
//     currentPage.value--;
//     fetchPendingUsers();
//   }

//   Future<bool> approveUser(AccessControlPendingUser user) async {
//     return _runUserAction(
//       successTitle: 'Approved',
//       successMessage: '${user.fullName} has been approved.',
//       request: () => _api.dio.patch(ApiEndpoints.approveUser(user.id)),
//     );
//   }

//   Future<bool> rejectUser(AccessControlPendingUser user) async {
//     return _runUserAction(
//       successTitle: 'Rejected',
//       successMessage: '${user.fullName} registration was rejected.',
//       request: () => _api.dio.patch(ApiEndpoints.rejectUser(user.id)),
//     );
//   }

//   Future<bool> assignDepartment(AccessControlPendingUser user, String departmentId) async {
//     return _runUserAction(
//       successTitle: 'Department Assigned',
//       successMessage: 'Department assignment was saved.',
//       request: () => _api.dio.patch(
//         ApiEndpoints.assignUserDepartment(user.id),
//         data: {'departmentId': departmentId},
//       ),
//     );
//   }

//   Future<bool> assignRole(AccessControlPendingUser user, String roleId) async {
//     return _runUserAction(
//       successTitle: 'Role Assigned',
//       successMessage: 'Role assignment was saved.',
//       request: () => _api.dio.patch(
//         ApiEndpoints.assignUserRole(user.id),
//         data: {'roleId': roleId},
//       ),
//     );
//   }

//   Future<void> exportCurrentList() async {
//     final rows = [
//       'Name,Email,Requested Role,Requested Date',
//       ...pendingUsers.map((u) => '"${u.fullName}","${u.email}","${u.role}","${u.createdAt ?? ''}"'),
//     ].join('\n');
//     await Clipboard.setData(ClipboardData(text: rows));
//     Get.snackbar('Export List', 'Pending approval CSV copied to clipboard.', snackPosition: SnackPosition.TOP);
//   }

//   Future<bool> _runUserAction({
//     required String successTitle,
//     required String successMessage,
//     required Future<Response<dynamic>> Function() request,
//   }) async {
//     if (isActionLoading.value) return false;
//     isActionLoading.value = true;
//     try {
//       final response = await request();
//       if (response.data?['success'] == true) {
//         Get.snackbar(successTitle, successMessage, snackPosition: SnackPosition.TOP);
//         await fetchPendingUsers(refresh: true);
//         return true;
//       }
//       Get.snackbar('Action Failed', 'The request could not be completed.', snackPosition: SnackPosition.TOP);
//     } catch (e) {
//       Get.snackbar('Action Failed', _friendlyError(e), snackPosition: SnackPosition.TOP);
//     } finally {
//       isActionLoading.value = false;
//     }
//     return false;
//   }

//   String _friendlyError(Object error) {
//     if (error is DioException) {
//       final message = error.response?.data?['message'];
//       if (message != null) return message.toString();
//       if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.receiveTimeout) {
//         return 'The server took too long to respond. Please try again.';
//       }
//       if (error.response?.statusCode == 401) return 'Your session has expired. Please sign in again.';
//       if (error.response?.statusCode == 403) return 'You do not have permission to perform this action.';
//       if (error.response?.statusCode != null && error.response!.statusCode! >= 500) {
//         return 'The server could not complete the request.';
//       }
//     }
//     return 'Something went wrong. Please try again.';
//   }
// }


import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/modules/super_admin/acces%20controll/models/access_control_pending_user.dart';

class AccessControlController extends GetxController {
  final isLoading = false.obs;
  final isDeleteLoading = false.obs;
  final isRefreshing = false.obs;
  final isActionLoading = false.obs;
  final errorMessage = ''.obs;
  final deleteErrorMessage = ''.obs;

  final pendingUsers = <AccessControlPendingUser>[].obs;
  final deleteUsers = <AccessControlPendingUser>[].obs;
  final departments = <Map<String, dynamic>>[].obs;
  final roles = <Map<String, dynamic>>[].obs;

  final selectedTab = 0.obs;
  final searchQuery = ''.obs;
  final roleFilter = ''.obs;

  final sortBy = 'createdAt'.obs;
  final sortAscending = false.obs;

  final currentPage = 1.obs;
  final pageSize = 10.obs;

  final totalPending = 0.obs;
  final totalDeleteUsers = 0.obs;
  final summaryAdmins = 0.obs;
  final summaryEmployees = 0.obs;

  Timer? _searchDebounce;

  ApiClient get _api => Get.find<ApiClient>();

  int get totalPages =>
      (totalPending.value / pageSize.value).ceil().clamp(1, 9999);

  int get adminPendingCount => summaryAdmins.value;

  int get employeePendingCount => summaryEmployees.value;

  int get startItem {
    if (totalPending.value == 0) {
      return 0;
    }

    return ((currentPage.value - 1) * pageSize.value) + 1;
  }

  int get endItem {
    final end = currentPage.value * pageSize.value;

    return end > totalPending.value ? totalPending.value : end;
  }

  @override
  void onInit() {
    super.onInit();

    fetchPendingUsers();
    fetchDeleteUsers();
    fetchDepartments();
    fetchRoles();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  // ---------------------------------------------------------------------------
  // Pending Users
  // ---------------------------------------------------------------------------

  Future<void> fetchPendingUsers({bool refresh = false}) async {
    if (refresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    errorMessage.value = '';

    try {
      final response = await _api.dio.get(
        ApiEndpoints.users,
        queryParameters: {
          'status': 'pending',
          'page': currentPage.value,
          'limit': pageSize.value,
          'sortBy': sortBy.value,
          'sortOrder': sortAscending.value ? 'asc' : 'desc',
          if (searchQuery.value.trim().isNotEmpty)
            'search': searchQuery.value.trim(),
        },
      );

      if (response.data?['success'] == true) {
        final list = _parseUsers(response.data['data'])
            .where(
              (user) =>
                  roleFilter.value.isEmpty ||
                  user.role.toLowerCase() ==
                      roleFilter.value.toLowerCase(),
            )
            .toList();

        pendingUsers.assignAll(list);

        final meta = response.data['meta'];

        if (meta is Map) {
          totalPending.value =
              _toInt(meta['total']) ?? list.length;
        } else {
          totalPending.value = list.length;
        }

        await fetchQueueSummary();
      } else {
        errorMessage.value = 'Unable to load pending approvals.';
      }
    } catch (e) {
      errorMessage.value = _friendlyError(e);
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> fetchDeleteUsers({bool refresh = false}) async {
    if (refresh) {
      isRefreshing.value = true;
    } else {
      isDeleteLoading.value = true;
    }

    deleteErrorMessage.value = '';

    try {
      final response = await _api.dio.get(
        ApiEndpoints.users,
        queryParameters: {
          'deleted': 'all',
          'page': 1,
          'limit': 100,
          'sortBy': 'createdAt',
          'sortOrder': 'desc',
        },
      );

      if (response.data?['success'] == true) {
        final list = _parseUsers(response.data['data'])
            .where((user) => user.isAdmin || user.isEmployee)
            .toList();
        deleteUsers.assignAll(list);

        final meta = response.data['meta'];
        totalDeleteUsers.value = meta is Map
            ? (_toInt(meta['total']) ?? list.length)
            : list.length;
      } else {
        deleteErrorMessage.value = 'Unable to load users.';
      }
    } catch (e) {
      deleteErrorMessage.value = _friendlyError(e);
    } finally {
      isDeleteLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Queue Summary
  // ---------------------------------------------------------------------------

  Future<void> fetchQueueSummary() async {
    try {
      final response = await _api.dio.get(
        ApiEndpoints.users,
        queryParameters: {
          'status': 'pending',
          'page': 1,
          'limit': 100,
          'sortBy': 'createdAt',
          'sortOrder': 'desc',
        },
      );

      if (response.data?['success'] == true) {
        final list = _parseUsers(response.data['data']);

        summaryAdmins.value =
            list.where((user) => user.isAdmin).length;

        summaryEmployees.value =
            list.where((user) => user.isEmployee).length;

        final meta = response.data['meta'];

        if (meta is Map) {
          totalPending.value =
              _toInt(meta['total']) ?? list.length;
        } else {
          totalPending.value = list.length;
        }
      }
    } catch (_) {
      // Queue summary failure should not block the main pending-user list.
    }
  }

  // ---------------------------------------------------------------------------
  // Departments
  // ---------------------------------------------------------------------------

  Future<void> fetchDepartments() async {
    try {
      final response = await _api.dio.get(
        ApiEndpoints.departments,
      );

      if (response.data?['success'] == true) {
        final rawData = response.data['data'];

        final list = (rawData as List? ?? [])
            .whereType<Map>()
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();

        departments.assignAll(list);
      }
    } catch (_) {
      // Keep the UI functional even if departments fail to load.
    }
  }

  // ---------------------------------------------------------------------------
  // Roles
  // ---------------------------------------------------------------------------

  Future<void> fetchRoles() async {
    try {
      final response = await _api.dio.get(
        ApiEndpoints.roles,
      );

      if (response.data?['success'] == true) {
        final rawData = response.data['data'];

        final list = (rawData as List? ?? [])
            .whereType<Map>()
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();

        roles.assignAll(list);
      }
    } catch (_) {
      // Keep the UI functional even if roles fail to load.
    }
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  void onSearchChanged(String value) {
    searchQuery.value = value;

    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () {
        currentPage.value = 1;
        fetchPendingUsers();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Filters
  // ---------------------------------------------------------------------------

  void applyRoleFilter(String value) {
    roleFilter.value = value;
    currentPage.value = 1;

    fetchPendingUsers();
  }

  void clearFilters() {
    roleFilter.value = '';
    searchQuery.value = '';
    currentPage.value = 1;

    fetchPendingUsers();
  }

  // ---------------------------------------------------------------------------
  // Sorting
  // ---------------------------------------------------------------------------

  void setSort(String field) {
    if (sortBy.value == field) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortBy.value = field;
      sortAscending.value = field == 'fullName';
    }

    currentPage.value = 1;

    fetchPendingUsers();
  }

  // ---------------------------------------------------------------------------
  // Pagination
  // ---------------------------------------------------------------------------

  void nextPage() {
    if (currentPage.value >= totalPages) {
      return;
    }

    currentPage.value++;

    fetchPendingUsers();
  }

  void previousPage() {
    if (currentPage.value <= 1) {
      return;
    }

    currentPage.value--;

    fetchPendingUsers();
  }

  // ---------------------------------------------------------------------------
  // Approve User
  // ---------------------------------------------------------------------------

  Future<bool> approveUser(
    AccessControlPendingUser user,
  ) async {
    return _runUserAction(
      successTitle: 'Approved',
      successMessage: '${user.fullName} has been approved.',
      request: () => _api.dio.patch(
        ApiEndpoints.approveUser(user.id),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Reject User
  // ---------------------------------------------------------------------------

  Future<bool> rejectUser(
    AccessControlPendingUser user,
  ) async {
    return _runUserAction(
      successTitle: 'Rejected',
      successMessage:
          '${user.fullName} registration was rejected.',
      request: () => _api.dio.patch(
        ApiEndpoints.rejectUser(user.id),
      ),
    );
  }

  Future<bool> deleteUser(
    AccessControlPendingUser user,
  ) async {
    return _runUserAction(
      successTitle: 'Deleted',
      successMessage: '${user.fullName} has been deleted.',
      request: () => _api.dio.delete(
        ApiEndpoints.deleteUser(user.id),
      ),
      afterSuccess: () async {
        await fetchDeleteUsers(refresh: true);
        await fetchPendingUsers(refresh: true);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Assign Department
  // ---------------------------------------------------------------------------

  Future<bool> assignDepartment(
    AccessControlPendingUser user,
    String departmentId,
  ) async {
    return _runUserAction(
      successTitle: 'Department Assigned',
      successMessage: 'Department assignment was saved.',
      request: () => _api.dio.patch(
        ApiEndpoints.assignUserDepartment(user.id),
        data: {
          'departmentId': departmentId,
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Assign Role
  // ---------------------------------------------------------------------------

  Future<bool> assignRole(
    AccessControlPendingUser user,
    String roleId,
  ) async {
    return _runUserAction(
      successTitle: 'Role Assigned',
      successMessage: 'Role assignment was saved.',
      request: () => _api.dio.patch(
        ApiEndpoints.assignUserRole(user.id),
        data: {
          'roleId': roleId,
        },
      ),
    );
  }

  Future<bool> assignEmployeeRoleAndDepartment(
    AccessControlPendingUser user, {
    required String roleId,
    required String departmentId,
  }) async {
    return _runUserAction(
      successTitle: 'Assignment Saved',
      successMessage: 'Role and Department assignment was saved.',
      request: () => _api.dio.patch(
        ApiEndpoints.assignUserRole(user.id),
        data: {
          'roleId': roleId,
          'departmentId': departmentId,
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Export
  // ---------------------------------------------------------------------------

  Future<void> exportCurrentList() async {
    final rows = [
      'Name,Email,Requested Role,Requested Date',
      ...pendingUsers.map(
        (user) =>
            '"${_escapeCsv(user.fullName)}",'
            '"${_escapeCsv(user.email)}",'
            '"${_escapeCsv(user.role)}",'
            '"${_escapeCsv(user.createdAt ?? '')}"',
      ),
    ].join('\n');

    await Clipboard.setData(
      ClipboardData(text: rows),
    );

    Get.snackbar(
      'Export List',
      'Pending approval CSV copied to clipboard.',
      snackPosition: SnackPosition.TOP,
    );
  }

  // ---------------------------------------------------------------------------
  // User Action Handler
  // ---------------------------------------------------------------------------

  Future<bool> _runUserAction({
    required String successTitle,
    required String successMessage,
    required Future<dio.Response<dynamic>> Function() request,
    Future<void> Function()? afterSuccess,
  }) async {
    if (isActionLoading.value) {
      return false;
    }

    isActionLoading.value = true;

    try {
      final response = await request();

      if (response.data?['success'] == true) {
        Get.snackbar(
          successTitle,
          successMessage,
          snackPosition: SnackPosition.TOP,
        );

        if (afterSuccess != null) {
          await afterSuccess();
        } else {
          await fetchPendingUsers(
            refresh: true,
          );
          await fetchDeleteUsers(
            refresh: true,
          );
        }

        return true;
      }

      Get.snackbar(
        'Action Failed',
        'The request could not be completed.',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Action Failed',
        _friendlyError(e),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isActionLoading.value = false;
    }

    return false;
  }

  // ---------------------------------------------------------------------------
  // Error Handling
  // ---------------------------------------------------------------------------

  String _friendlyError(Object error) {
    if (error is dio.DioException) {
      final responseData = error.response?.data;

      if (responseData is Map) {
        final message = responseData['message'];

        if (message != null &&
            message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }

      if (error.type ==
              dio.DioExceptionType.connectionTimeout ||
          error.type ==
              dio.DioExceptionType.receiveTimeout) {
        return 'The server took too long to respond. Please try again.';
      }

      if (error.type ==
          dio.DioExceptionType.connectionError) {
        return 'Unable to connect to the server. Please check your internet connection.';
      }

      if (error.response?.statusCode == 401) {
        return 'Your session has expired. Please sign in again.';
      }

      if (error.response?.statusCode == 403) {
        return 'You do not have permission to perform this action.';
      }

      final statusCode = error.response?.statusCode;

      if (statusCode != null && statusCode >= 500) {
        return 'The server could not complete the request.';
      }
    }

    return 'Something went wrong. Please try again.';
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  String _escapeCsv(String value) {
    return value.replaceAll('"', '""');
  }

  List<AccessControlPendingUser> _parseUsers(dynamic rawData) {
    return (rawData as List? ?? [])
        .whereType<Map>()
        .map(
          (item) => AccessControlPendingUser.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}
