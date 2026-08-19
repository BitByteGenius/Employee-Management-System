import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/modules/department/controllers/department_controller.dart';
import 'package:tms/modules/department/models/department_models.dart';
import 'package:tms/modules/department/repositories/department_repository.dart';
import 'package:tms/modules/department/services/department_service.dart';
import 'package:tms/modules/super_admin/projects/controller/project_controller.dart';
import 'package:tms/modules/super_admin/projects/view/widget/dashed_border_painter.dart';

class ProjectDeliverablesDialog extends GetView<ProjectController> {
  const ProjectDeliverablesDialog({super.key});

  DepartmentController _getDeptController() {
    if (Get.isRegistered<DepartmentController>()) {
      return Get.find<DepartmentController>();
    }
    if (!Get.isRegistered<DepartmentService>()) {
      Get.lazyPut<DepartmentService>(
        () => DepartmentService(Get.find<ApiClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<DepartmentRepository>()) {
      Get.lazyPut<DepartmentRepository>(
        () => DepartmentRepository(Get.find<DepartmentService>()),
        fenix: true,
      );
    }
    final deptCtrl = DepartmentController(Get.find<DepartmentRepository>());
    Get.lazyPut<DepartmentController>(() => deptCtrl, fenix: true);
    return deptCtrl;
  }

  @override
  Widget build(BuildContext context) {
    final deptController = _getDeptController();
    if (deptController.departments.isEmpty && !deptController.isLoading.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        deptController.fetchDepartments();
      });
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: AppColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 650,
        padding: AppSpacing.paddingXl,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Submit Project Deliverables',
                    style: AppTypography.headlineMd(color: AppColors.onBackground),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // --- File Upload Area ---
              Text('FILE UPLOAD', style: AppTypography.labelMd(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: controller.pickFile,
                child: CustomPaint(
                  painter: DashedBorderPainter(color: AppColors.outlineVariant),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    color: Colors.transparent,
                    child: Obx(() => Column(
                      children: [
                        Icon(
                          controller.selectedFile.value != null 
                              ? Icons.insert_drive_file_outlined 
                              : Icons.cloud_upload_outlined,
                          color: AppColors.secondary,
                          size: 48,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (controller.selectedFile.value != null)
                          Text(
                            controller.selectedFile.value!,
                            style: AppTypography.bodyMd(
                              color: AppColors.onBackground, 
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          RichText(
                            text: TextSpan(
                              style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
                              children: [
                                const TextSpan(text: 'Drag and drop files here or '),
                                TextSpan(
                                  text: 'browse',
                                  style: AppTypography.bodyMd(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          controller.selectedFile.value != null 
                              ? 'Click to change file' 
                              : 'Supports PDF, ZIP, PNG, JPG (Max 50MB)',
                          style: AppTypography.labelMd(color: AppColors.outline),
                        ),
                      ],
                    )),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // --- Link & Date Row ---
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EXTERNAL LINKS', style: AppTypography.labelMd(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: controller.externalLinkController,
                          style: AppTypography.bodyMd(color: AppColors.onBackground),
                          decoration: InputDecoration(
                            hintText: 'Add external links',
                            hintStyle: AppTypography.bodyMd(color: AppColors.outline),
                            prefixIcon: const Icon(Icons.link, color: AppColors.outline),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: const BorderSide(color: AppColors.outlineVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: const BorderSide(color: AppColors.outlineVariant),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: const BorderSide(color: AppColors.secondary, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SUBMISSION DEADLINE', style: AppTypography.labelMd(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: AppSpacing.sm),
                        GestureDetector(
                          onTap: () => controller.pickDate(context),
                          child: Obx(() => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.outlineVariant),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_outlined, color: AppColors.outline, size: 20),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    controller.selectedDate.value == null
                                        ? 'Select Date'
                                        : controller.formattedDate,
                                    style: AppTypography.bodyMd(
                                      color: controller.selectedDate.value == null
                                          ? AppColors.outline
                                          : AppColors.onBackground,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.calendar_today, color: AppColors.outline, size: 16),
                              ],
                            ),
                          )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // --- Assign Department Row (Full Width) ---
              Text('ASSIGN DEPARTMENT', style: AppTypography.labelMd(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.sm),
              _buildDepartmentSelector(context, deptController),
              const SizedBox(height: AppSpacing.lg),

              // --- Notes Area (Full Width) ---
              Text('SUBMISSION NOTES', style: AppTypography.labelMd(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: controller.notesController,
                maxLines: 4,
                style: AppTypography.bodyMd(color: AppColors.onBackground),
                decoration: InputDecoration(
                  hintText: 'Provide any additional context or notes for your submission...',
                  hintStyle: AppTypography.bodyMd(color: AppColors.outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(color: AppColors.secondary, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              const Divider(color: AppColors.surfaceContainerHigh, height: 1, thickness: 1),
              const SizedBox(height: AppSpacing.lg),

              // --- Action Buttons ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.outlineVariant),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    ),
                    child: Text('Cancel', style: AppTypography.labelMd(color: AppColors.onBackground)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Obx(() {
                    final isSubmitting = controller.isSubmitting.value;
                    return ElevatedButton(
                      onPressed: isSubmitting ? null : () => controller.submitDeliverables(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onSecondary,
                              ),
                            )
                          : Text('Submit Deliverables', style: AppTypography.labelMd(color: AppColors.onSecondary)),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentSelector(BuildContext context, DepartmentController deptController) {
    return Obx(() {
      final selectedId = controller.selectedDepartmentId.value;
      final selectedName = controller.selectedDepartmentName.value;

      if (selectedId != null && selectedId.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.secondary, width: 1.5),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            color: AppColors.surfaceContainerLowest,
          ),
          child: Row(
            children: [
              const Icon(Icons.apartment_outlined, color: AppColors.secondary, size: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  selectedName ?? 'Department Selected',
                  style: AppTypography.bodyMd(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.onSurfaceVariant),
                tooltip: 'Clear Department',
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  controller.clearSelectedDepartment();
                },
              ),
            ],
          ),
        );
      }

      final deptList = deptController.departments.toList();
      return RawAutocomplete<DepartmentModel>(
        displayStringForOption: (option) => option.name,
        optionsBuilder: (TextEditingValue textEditingValue) {
          final query = textEditingValue.text.toLowerCase().trim();
          if (query.isEmpty) {
            return deptList;
          }
          return deptList.where((dept) {
            final nameMatch = dept.name.toLowerCase().contains(query);
            final codeMatch = dept.code.toLowerCase().contains(query);
            return nameMatch || codeMatch;
          });
        },
        onSelected: (DepartmentModel selection) {
          controller.selectDepartment(selection.id, selection.name);
        },
        fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
          return TextField(
            controller: textController,
            focusNode: focusNode,
            style: AppTypography.bodyMd(color: AppColors.onBackground),
            decoration: InputDecoration(
              hintText: 'Search or select department...',
              hintStyle: AppTypography.bodyMd(color: AppColors.outline),
              prefixIcon: const Icon(Icons.search, color: AppColors.outline),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.secondary, width: 2),
              ),
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              color: AppColors.surfaceContainerLowest,
              child: Container(
                width: 586,
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.outlineVariant),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: options.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'No matching departments found.',
                          style: AppTypography.bodyMd(color: AppColors.outline),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.outlineVariant),
                        itemBuilder: (context, index) {
                          final dept = options.elementAt(index);
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.apartment_outlined, size: 20, color: AppColors.secondary),
                            title: Text(
                              dept.name,
                              style: AppTypography.bodyMd(
                                color: AppColors.onBackground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Code: ${dept.code}${dept.description.isNotEmpty ? ' • ${dept.description}' : ''}',
                              style: AppTypography.labelSm(color: AppColors.outline),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => onSelected(dept),
                          );
                        },
                      ),
              ),
            ),
          );
        },
      );
    });
  }
}