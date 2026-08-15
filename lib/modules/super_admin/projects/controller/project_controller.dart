import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';

class ProjectController extends GetxController {
  // 1. Text Editing Controllers
  final TextEditingController externalLinkController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // 2. Reactive Variables
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final Rxn<String> selectedFile = Rxn<String>();

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

      if (result != null) {
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
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  // 6. Renamed Submit Method to avoid naming collision
  void submitProjectDeliverables() {
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
  }

  // 7. Reset Form Helper
  void _resetForm() {
    externalLinkController.clear();
    notesController.clear();
    selectedDate.value = null;
    selectedFile.value = null;
  }

  // 8. Lifecycle Cleanup
  @override
  void onClose() {
    externalLinkController.dispose();
    notesController.dispose();
    super.onClose();
  }
}