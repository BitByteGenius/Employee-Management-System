import 'dart:async';
import 'package:get/get.dart';
import 'package:tms/modules/department/models/create_department_request.dart';
import 'package:tms/modules/department/models/department_employee_model.dart';
import 'package:tms/modules/department/models/department_models.dart';
import 'package:tms/modules/department/repositories/department_repository.dart';

class DepartmentController extends GetxController {
  final DepartmentRepository repository;

  DepartmentController(this.repository);

  // ==========================================================================
  // STATE
  // ==========================================================================

  final departments = <DepartmentModel>[].obs;
  final selectedDepartment = Rxn<DepartmentModel>();
  final employees = <DepartmentEmployeeModel>[].obs;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isSaving = false.obs;
  final isDeleting = false.obs;
  final isLoadingEmployees = false.obs;

  final errorMessage = ''.obs;

  // Selected tab for right-hand details pane (0: Directory, 1: Settings, 2: Reports)
  final selectedDetailTab = 0.obs;

  // Candidate admins search state
  final adminCandidates = <DepartmentEmployeeModel>[].obs;
  final isSearchingCandidates = false.obs;

  // ==========================================================================
  // FILTERS
  // ==========================================================================

  final searchQuery = ''.obs;
  final selectedStatus = 'all'.obs;
  final sortBy = 'name'.obs;
  final sortOrder = 'asc'.obs;

  // ==========================================================================
  // PAGINATION
  // ==========================================================================

  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalDepartments = 0.obs;
  final pageSize = 20;

  Timer? _searchDebounce;
  Timer? _employeeSearchDebounce;

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  void onInit() {
    super.onInit();
    fetchDepartments();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _employeeSearchDebounce?.cancel();
    super.onClose();
  }

  // ==========================================================================
  // FETCH
  // ==========================================================================

  Future<void> fetchDepartments({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
    }

    if (isLoading.value || isLoadingMore.value) {
      return;
    }

    final isFirstPage = currentPage.value == 1;

    if (isFirstPage) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    errorMessage.value = '';

    try {
      final result = await repository.getDepartments(
        page: currentPage.value,
        limit: pageSize,
        search: searchQuery.value,
        status: selectedStatus.value == 'all' ? null : selectedStatus.value,
        sortBy: sortBy.value,
        sortOrder: sortOrder.value,
      );

      if (isFirstPage) {
        departments.assignAll(result.departments);
      } else {
        departments.addAll(result.departments);
      }

      totalDepartments.value = result.total;
      totalPages.value = result.totalPages;

      // Auto-select first department if none selected or if selected no longer exists
      if (departments.isNotEmpty) {
        if (selectedDepartment.value == null ||
            !departments.any((d) => d.id == selectedDepartment.value?.id)) {
          selectDepartment(departments.first);
        }
      } else {
        selectedDepartment.value = null;
        employees.clear();
      }
    } catch (error) {
      errorMessage.value = _friendlyError(error);
      if (isFirstPage) {
        departments.clear();
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshDepartments() async {
    currentPage.value = 1;
    await fetchDepartments(refresh: true);
  }

  Future<void> loadMore() async {
    if (currentPage.value >= totalPages.value) {
      return;
    }
    currentPage.value++;
    await fetchDepartments();
  }

  // ==========================================================================
  // SEARCH & FILTERS
  // ==========================================================================

  void updateSearch(String value) {
    searchQuery.value = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      currentPage.value = 1;
      fetchDepartments(refresh: true);
    });
  }

  void searchEmployees(String query) {
    _employeeSearchDebounce?.cancel();
    _employeeSearchDebounce = Timer(const Duration(milliseconds: 350), () {
      final currentDept = selectedDepartment.value;
      if (currentDept != null) {
        fetchEmployees(currentDept.id, search: query);
      }
    });
  }

  Future<void> updateStatus(String status) async {
    selectedStatus.value = status;
    currentPage.value = 1;
    await fetchDepartments(refresh: true);
  }

  Future<void> updateSort(String field) async {
    if (sortBy.value == field) {
      sortOrder.value = sortOrder.value == 'asc' ? 'desc' : 'asc';
    } else {
      sortBy.value = field;
      sortOrder.value = 'asc';
    }
    currentPage.value = 1;
    await fetchDepartments(refresh: true);
  }

  // ==========================================================================
  // SELECTION & TABS
  // ==========================================================================

  Future<void> selectDepartment(DepartmentModel department) async {
    selectedDepartment.value = department;
    await Future.wait([
      fetchDepartmentDetails(department.id),
      fetchEmployees(department.id),
    ]);
  }

  void selectTab(int index) {
    selectedDetailTab.value = index;
  }

  // ==========================================================================
  // ADMIN CANDIDATE SEARCH
  // ==========================================================================

  Future<List<DepartmentEmployeeModel>> searchAdminCandidates([String query = '']) async {
    isSearchingCandidates.value = true;
    try {
      final results = await repository.searchUsers(query.trim());
      adminCandidates.assignAll(results);
      return results;
    } catch (e) {
      adminCandidates.clear();
      return [];
    } finally {
      isSearchingCandidates.value = false;
    }
  }

  // ==========================================================================
  // DETAILS
  // ==========================================================================

  Future<void> fetchDepartmentDetails(String id) async {
    try {
      final department = await repository.getDepartment(id);
      selectedDepartment.value = department;

      final index = departments.indexWhere((item) => item.id == id);
      if (index != -1) {
        departments[index] = department;
      }
    } catch (error) {
      errorMessage.value = _friendlyError(error);
    }
  }

  // ==========================================================================
  // CREATE
  // ==========================================================================

  Future<bool> createDepartment({
    required String name,
    required String code,
    String description = '',
    String? initialAdminId,
  }) async {
    if (isSaving.value) return false;

    isSaving.value = true;

    try {
      final request = CreateDepartmentRequest(
        name: name,
        code: code,
        description: description,
        initialAdminId: initialAdminId,
      );

      final department = await repository.createDepartment(request);

      departments.insert(0, department);
      totalDepartments.value++;
      selectedDepartment.value = department;

      Get.snackbar(
        'Success',
        'Department created successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (error) {
      errorMessage.value = _friendlyError(error);
      Get.snackbar(
        'Unable to create department',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ==========================================================================
  // UPDATE
  // ==========================================================================

  Future<bool> updateDepartment(
    String id,
    Map<String, dynamic> data,
  ) async {
    if (isSaving.value) return false;

    isSaving.value = true;

    try {
      final updated = await repository.updateDepartment(id, data);

      final index = departments.indexWhere((item) => item.id == id);
      if (index != -1) {
        departments[index] = updated;
      }

      if (selectedDepartment.value?.id == id) {
        selectedDepartment.value = updated;
      }

      Get.snackbar(
        'Success',
        'Department updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (error) {
      errorMessage.value = _friendlyError(error);
      Get.snackbar(
        'Update failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ==========================================================================
  // DELETE
  // ==========================================================================

  Future<bool> deleteDepartment(String id) async {
    if (isDeleting.value) return false;

    isDeleting.value = true;

    try {
      await repository.deleteDepartment(id);

      departments.removeWhere((item) => item.id == id);
      totalDepartments.value = totalDepartments.value > 0 ? totalDepartments.value - 1 : 0;

      if (selectedDepartment.value?.id == id) {
        selectedDepartment.value = departments.isNotEmpty ? departments.first : null;
        if (selectedDepartment.value != null) {
          fetchEmployees(selectedDepartment.value!.id);
        } else {
          employees.clear();
        }
      }

      Get.snackbar(
        'Success',
        'Department removed successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (error) {
      errorMessage.value = _friendlyError(error);
      Get.snackbar(
        'Delete failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  // ==========================================================================
  // ASSIGN ADMIN
  // ==========================================================================

  Future<bool> assignAdmin(
    String departmentId,
    String adminId,
  ) async {
    try {
      final updated = await repository.assignAdmin(
        departmentId,
        adminId,
      );

      final index = departments.indexWhere((item) => item.id == departmentId);
      if (index != -1) {
        departments[index] = updated;
      }

      if (selectedDepartment.value?.id == departmentId) {
        selectedDepartment.value = updated;
      }

      Get.snackbar(
        'Success',
        'Administrator assigned successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (error) {
      Get.snackbar(
        'Assignment failed',
        _friendlyError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // ==========================================================================
  // REMOVE ADMIN
  // ==========================================================================

  Future<bool> removeAdmin(String departmentId) async {
    try {
      await repository.removeAdmin(departmentId);
      await fetchDepartmentDetails(departmentId);
      Get.snackbar(
        'Success',
        'Administrator removed successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (error) {
      Get.snackbar(
        'Unable to remove admin',
        _friendlyError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // ==========================================================================
  // EMPLOYEES
  // ==========================================================================

  Future<void> fetchEmployees(
    String departmentId, {
    String? search,
  }) async {
    isLoadingEmployees.value = true;

    try {
      final result = await repository.getEmployees(
        departmentId,
        search: search,
      );

      employees.assignAll(result);
    } catch (error) {
      employees.clear();
      errorMessage.value = _friendlyError(error);
    } finally {
      isLoadingEmployees.value = false;
    }
  }

  // ==========================================================================
  // ERROR
  // ==========================================================================

  String _friendlyError(Object error) {
    final message = error.toString();

    if (message.contains('401')) {
      return 'Authentication required. Please login again.';
    }
    if (message.contains('403')) {
      return 'You do not have permission to perform this action.';
    }
    if (message.contains('404')) {
      return 'Department was not found.';
    }
    if (message.contains('409')) {
      return 'A department with these details already exists or has active employees.';
    }
    if (message.contains('500')) {
      return 'Server error. Please try again later.';
    }

    return message.replaceFirst('Exception: ', '');
  }
}