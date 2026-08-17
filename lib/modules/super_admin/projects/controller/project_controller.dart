import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/modules/super_admin/projects/models/dilevariable_models.dart';
import 'package:tms/modules/super_admin/projects/models/project_model.dart';
import 'package:tms/modules/super_admin/projects/repositories/project_repository.dart';
import 'package:tms/modules/super_admin/projects/services/deliverable_service.dart';
import 'package:tms/modules/super_admin/projects/services/project_service.dart';

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
  }) async {
    try {
      final newProj = await repository.createProject({
        'name': name,
        if (description != null && description.isNotEmpty) 'description': description,
        if (departmentId != null && departmentId.isNotEmpty) 'department': departmentId,
        if (managerId != null && managerId.isNotEmpty) 'manager': managerId,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      });

      projects.insert(0, newProj);
      totalProjects.value++;

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
  // DELIVERABLES SUBMISSION
  // ==========================================================================

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
        allowedExtensions: ['pdf', 'zip', 'png', 'jpg'],
      );

      if (result != null && result.files.single.path != null) {
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
        _pickedFileObject = File(file.path!);
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  Future<void> submitDeliverables([String? projectId]) async {
    final targetId = projectId ?? currentProjectId.value;

    if (targetId.isEmpty) {
      if (projects.isNotEmpty) {
        currentProjectId.value = projects.first.id;
      } else {
        Get.snackbar(
          'Error',
          'No active project available to attach deliverables.',
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
          snackPosition: SnackPosition.BOTTOM,
          margin: AppSpacing.paddingLg,
          borderRadius: AppRadius.md,
        );
        return;
      }
    }

    final finalProjectId = targetId.isNotEmpty ? targetId : currentProjectId.value;

    try {
      isSubmitting.value = true;

      final deliverableModel = DeliverableModel(
        externalLink: externalLinkController.text.trim().isNotEmpty
            ? externalLinkController.text.trim()
            : null,
        submissionDeadline: selectedDate.value,
        notes: notesController.text.trim().isNotEmpty
            ? notesController.text.trim()
            : null,
      );

      final success = await deliverableService.submitDeliverable(
        projectId: finalProjectId,
        deliverable: deliverableModel,
        file: _pickedFileObject,
      );

      if (success) {
        Get.back();
        Get.snackbar(
          'Success',
          'Deliverables have been submitted successfully.',
          backgroundColor: AppColors.success,
          colorText: AppColors.onPrimary,
          snackPosition: SnackPosition.BOTTOM,
          margin: AppSpacing.paddingLg,
          borderRadius: AppRadius.md,
        );
        _resetForm();
        fetchProjects(refresh: true);
      } else {
        Get.snackbar(
          'Error',
          'Failed to submit deliverables. Please try again.',
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
          snackPosition: SnackPosition.BOTTOM,
          margin: AppSpacing.paddingLg,
          borderRadius: AppRadius.md,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
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

  void _resetForm() {
    externalLinkController.clear();
    notesController.clear();
    selectedDate.value = null;
    selectedFile.value = null;
    _pickedFileObject = null;
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('401')) return 'Authentication required.';
    if (message.contains('403')) return 'Permission denied.';
    if (message.contains('404')) return 'Project not found.';
    if (message.contains('500')) return 'Server error. Please try again.';
    return message.replaceFirst('Exception: ', '');
  }
}