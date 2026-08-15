import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/project/controllers/project_controller.dart';
import 'package:tms/modules/super_admin/projects/view/widget/dashed_border_painter.dart';

class ProjectDeliverablesDialog extends GetView<ProjectController> {
  const ProjectDeliverablesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: AppColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 650,
        padding: AppSpacing.paddingXl,
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

            // --- Notes Area ---
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
                ElevatedButton(
                  onPressed: controller.submitDeliverables,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    elevation: 0,
                  ),
                  child: Text('Submit Deliverables', style: AppTypography.labelMd(color: AppColors.onSecondary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}