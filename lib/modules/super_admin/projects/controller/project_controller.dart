import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/modules/super_admin/projects/services/deliverable_service.dart';

class ProjectController extends GetxController {
  // Inject DeliverableService
  final DeliverableService _deliverableService = Get.find<DeliverableService>();

  // Store the active project ID for the dialog
  final RxString currentProjectId = ''.obs;

  // 1. Text Editing Controllers
  final TextEditingController externalLinkController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // 2. Reactive Variables
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final Rxn<String> selectedFile = Rxn<String>();
  
  // Store the actual File object for uploading
  File? _pickedFileObject; 

  // Loading state
  final RxBool isSubmitting = false.obs;

  // 3. Formatted Date Getter
  String get formattedDate {
    if (selectedDate.value == null) return '';
    return DateFormat('MM/dd/yyyy').format(selectedDate.value!);
  }

  // 4. Date Picker Method
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

  // 5. File Picker Method
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
        _pickedFileObject = File(file.path!); // Save actual file reference
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  // 6. Submit Method allowing optional parameter (defaults to controller's stored ID)
  Future<void> submitDeliverables([String? projectId]) async {
    final targetId = projectId ?? currentProjectId.value;

    if (targetId.isEmpty) {
      Get.snackbar(
        'Error',
        'Project ID is missing.',
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

      // Construct the DeliverableModel
      final deliverableModel = DeliverableModel(
        externalLink: externalLinkController.text.trim().isNotEmpty 
            ? externalLinkController.text.trim() 
            : null,
        submissionDeadline: selectedDate.value,
        notes: notesController.text.trim().isNotEmpty 
            ? notesController.text.trim() 
            : null,
      );

      // Call the service
      final success = await _deliverableService.submitDeliverable(
        projectId: targetId,
        deliverable: deliverableModel,
        file: _pickedFileObject,
      );

      if (success) {
        Get.back(); // Close dialog/screen
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

  // 7. Reset Form Helper
  void _resetForm() {
    externalLinkController.clear();
    notesController.clear();
    selectedDate.value = null;
    selectedFile.value = null;
    _pickedFileObject = null;
  }

  // 8. Lifecycle Cleanup
  @override
  void onClose() {
    externalLinkController.dispose();
    notesController.dispose();
    super.onClose();
  }
}