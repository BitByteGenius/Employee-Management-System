import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/modules/department/controllers/department_controller.dart';
import 'package:tms/modules/super_admin/projects/models/dilevariable_models.dart';
import 'package:tms/modules/super_admin/projects/models/project_model.dart';
import 'package:tms/modules/super_admin/projects/repositories/project_repository.dart';
import 'package:tms/modules/super_admin/projects/services/deliverable_service.dart';
import 'package:tms/modules/super_admin/projects/services/project_service.dart';
import 'package:tms/modules/super_admin/projects/view/widget/project_deliverables_dialog.dart';

class ProjectController extends GetxController {
  final ProjectRepository repository;
  final DeliverableService deliverableService;

  ProjectController({
    ProjectRepository? repository,
    DeliverableService? deliverableService,
  })  : repository = repository ?? _resolveProjectRepository(),
        deliverableService = deliverableService ?? _resolveDeliverableService();

  static ProjectRepository _resolveProjectRepository() {
    if (Get.isRegistered<ProjectRepository>()) {
      return Get.find<ProjectRepository>();
    }
    if (!Get.isRegistered<ProjectService>()) {
      Get.lazyPut<ProjectService>(
        () => ProjectService(Get.find<ApiClient>()),
        fenix: true,
      );
    }
    final repo = ProjectRepository(Get.find<ProjectService>());
    Get.lazyPut<ProjectRepository>(() => repo, fenix: true);
    return repo;
  }

  static DeliverableService _resolveDeliverableService() {
    if (Get.isRegistered<DeliverableService>()) {
      return Get.find<DeliverableService>();
    }
    final service = DeliverableService(Get.find<ApiClient>());
    Get.lazyPut<DeliverableService>(() => service, fenix: true);
    return service;
  }

  // ==========================================================================
  // PROJECTS STATE
  // ==========================================================================

  final projects = <ProjectModel>[].obs;
  final selectedProject = Rxn<ProjectModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final selectedStatus = 'all'.obs;
  final selectedManager = 'all'.obs;
  final searchQuery = ''.obs;

  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalProjects = 0.obs;

  // ==========================================================================
  // DELIVERABLES DIALOG STATE
  // ==========================================================================

  final RxString currentProjectId = ''.obs;
  final TextEditingController externalLinkController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final Rxn<String> selectedFile = Rxn<String>();
  File? _pickedFileObject;
  final RxBool isSubmitting = false.obs;

  // Department State for Deliverables
  final Rxn<String> selectedDepartmentId = Rxn<String>();
  final Rxn<String> selectedDepartmentName = Rxn<String>();

  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    externalLinkController.dispose();
    notesController.dispose();
    super.onClose();
  }

  PlatformFile? _pickedPlatformFile;

  // ==========================================================================
  // FETCH PROJECTS
  // ==========================================================================

  Future<void> fetchProjects({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await repository.getProjects(
        page: currentPage.value,
        limit: 20,
        search: searchQuery.value,
        status: selectedStatus.value == 'all' ? null : selectedStatus.value,
        manager: selectedManager.value == 'all' ? null : selectedManager.value,
      );

      projects.assignAll(result.projects);
      totalProjects.value = result.total;
      totalPages.value = result.totalPages;
    } catch (error) {
      errorMessage.value = _friendlyError(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProjects() async {
    await fetchProjects(refresh: true);
  }

  void updateStatusFilter(String status) {
    selectedStatus.value = status;
    fetchProjects(refresh: true);
  }

  void updateManagerFilter(String manager) {
    selectedManager.value = manager;
    fetchProjects(refresh: true);
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      fetchProjects(refresh: true);
    });
  }

  // ==========================================================================
  // PROJECT CRUD
  // ==========================================================================

  Future<bool> createProject({
    required String name,
    String? description,
    String? departmentId,
    String? managerId,
    DateTime? dueDate,
    PlatformFile? attachedFile,
    File? file,
  }) async {
    try {
      final newProj = await repository.createProject({
        'name': name,
        if (description != null && description.isNotEmpty) 'description': description,
        if (departmentId != null && departmentId.isNotEmpty) 'department': departmentId,
        if (managerId != null && managerId.isNotEmpty) 'manager': managerId,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      });

      // If a file was attached during project creation, submit it as deliverable/attachment
      if (attachedFile != null || file != null) {
        try {
          await deliverableService.submitDeliverable(
            projectId: newProj.id,
            deliverable: DeliverableModel(
              departmentId: departmentId,
              submissionDeadline: dueDate,
              notes: 'Initial Project Attachment',
            ),
            platformFile: attachedFile,
            file: file,
          );
        } catch (e) {
          debugPrint('Deliverable attachment error on create: $e');
        }
      }

      await fetchProjects(refresh: true);

      Get.snackbar(
        'Success',
        'Project created successfully.',
        backgroundColor: AppColors.success,
        colorText: AppColors.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (error) {
      Get.snackbar(
        'Error',
        _friendlyError(error),
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> updateProjectStatus(String id, String status) async {
    try {
      final updated = await repository.updateStatus(id, status);
      final index = projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        projects[index] = updated;
      }
      Get.snackbar(
        'Success',
        'Project status updated to ${status.toUpperCase()}.',
        backgroundColor: AppColors.success,
        colorText: AppColors.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (error) {
      Get.snackbar(
        'Error',
        _friendlyError(error),
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> deleteProject(String id) async {
    try {
      await repository.deleteProject(id);
      projects.removeWhere((p) => p.id == id);
      totalProjects.value = totalProjects.value > 0 ? totalProjects.value - 1 : 0;
      Get.snackbar(
        'Success',
        'Project removed successfully.',
        backgroundColor: AppColors.success,
        colorText: AppColors.onPrimary,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (error) {
      Get.snackbar(
        'Error',
        _friendlyError(error),
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // ==========================================================================
  // DELIVERABLES SUBMISSION & STATE MANAGEMENT
  // ==========================================================================

  void selectDepartment(String id, String name) {
    selectedDepartmentId.value = id;
    selectedDepartmentName.value = name;
  }

  void clearSelectedDepartment() {
    selectedDepartmentId.value = null;
    selectedDepartmentName.value = null;
  }

  void openDeliverablesDialog(String projectId) {
    currentProjectId.value = projectId;
    resetDeliverablesForm();

    if (Get.isRegistered<DepartmentController>()) {
      final deptCtrl = Get.find<DepartmentController>();
      if (deptCtrl.departments.isEmpty && !deptCtrl.isLoading.value) {
        deptCtrl.fetchDepartments();
      }
    }

    Get.dialog(
      const ProjectDeliverablesDialog(),
      barrierColor: AppColors.primaryContainer.withValues(alpha: 0.5),
    );
  }

  String get formattedDate {
    if (selectedDate.value == null) return '';
    return DateFormat('MM/dd/yyyy').format(selectedDate.value!);
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? today,
      firstDate: today,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: AppColors.onSecondary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      selectedDate.value = date;
    }
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'zip', 'png', 'jpg', 'docx', 'xlsx'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.single;
        final double sizeInMb = file.size / (1024 * 1024);
        if (sizeInMb > 50) {
          Get.snackbar(
            'Upload Failed',
            'File size exceeds the 50MB limit.',
            backgroundColor: AppColors.error,
            colorText: AppColors.onError,
            snackPosition: SnackPosition.BOTTOM,
            margin: AppSpacing.paddingLg,
            borderRadius: AppRadius.md,
          );
          return;
        }

        selectedFile.value = file.name;
        _pickedPlatformFile = file;
        if (file.path != null) {
          _pickedFileObject = File(file.path!);
        } else {
          _pickedFileObject = null;
        }
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  Future<void> submitDeliverables([String? projectId]) async {
    if (isSubmitting.value) return;

    final targetId = (projectId != null && projectId.isNotEmpty)
        ? projectId
        : currentProjectId.value;

    if (targetId.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'No project selected. Please select a valid project to submit deliverables.',
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
        snackPosition: SnackPosition.BOTTOM,
        margin: AppSpacing.paddingLg,
        borderRadius: AppRadius.md,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      final deliverableModel = DeliverableModel(
        departmentId: selectedDepartmentId.value,
        externalLink: externalLinkController.text.trim().isNotEmpty
            ? externalLinkController.text.trim()
            : null,
        submissionDeadline: selectedDate.value,
        notes: notesController.text.trim().isNotEmpty
            ? notesController.text.trim()
            : null,
      );

      final success = await deliverableService.submitDeliverable(
        projectId: targetId,
        deliverable: deliverableModel,
        platformFile: _pickedPlatformFile,
        file: _pickedFileObject,
      );

      if (success) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        Get.snackbar(
          'Success',
          'Deliverables have been submitted successfully.',
          backgroundColor: AppColors.success,
          colorText: AppColors.onPrimary,
          snackPosition: SnackPosition.BOTTOM,
          margin: AppSpacing.paddingLg,
          borderRadius: AppRadius.md,
        );
        resetDeliverablesForm();
        fetchProjects(refresh: true);
      } else {
        Get.snackbar(
          'Error',
          'Failed to submit deliverables. Please verify your submission details.',
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
          snackPosition: SnackPosition.BOTTOM,
          margin: AppSpacing.paddingLg,
          borderRadius: AppRadius.md,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Submission Failed',
        _friendlyError(e),
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
        snackPosition: SnackPosition.BOTTOM,
        margin: AppSpacing.paddingLg,
        borderRadius: AppRadius.md,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void resetDeliverablesForm() {
    externalLinkController.clear();
    notesController.clear();
    selectedDate.value = null;
    selectedFile.value = null;
    _pickedFileObject = null;
    selectedDepartmentId.value = null;
    selectedDepartmentName.value = null;
  }

  void resetForm() {
    resetDeliverablesForm();
  }

  String _friendlyError(Object error) {
    if (error is DioException) {
      if (error.response?.data is Map && error.response?.data['message'] != null) {
        return error.response!.data['message'].toString();
      }
      final status = error.response?.statusCode;
      if (status == 400) return 'Invalid request data. Please check the entered fields.';
      if (status == 401) return 'Authentication required. Please log in again.';
      if (status == 403) return 'You do not have permission to perform this action.';
      if (status == 404) return 'Project or resource not found.';
      if (status == 409) return 'A resource conflict occurred. Please review your details.';
      if (status == 413) return 'Uploaded file exceeds the maximum 50MB limit.';
      if (status != null && status >= 500) return 'Server error. Please try again later.';
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Please check your network connection.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Unable to reach the server. Please check your internet connection.';
      }
    }
    final message = error.toString();
    if (message.contains('400')) return 'Invalid request data. Please check the entered fields.';
    if (message.contains('401')) return 'Authentication required. Please log in again.';
    if (message.contains('403')) return 'You do not have permission to perform this action.';
    if (message.contains('404')) return 'Project or resource not found.';
    if (message.contains('409')) return 'A resource conflict occurred. Please review your details.';
    if (message.contains('413')) return 'Uploaded file exceeds the maximum 50MB limit.';
    if (message.contains('500')) return 'Server error. Please try again later.';
    return message.replaceFirst('Exception: ', '');
  }
}