import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/employee/task/controller/employee_task_controller.dart';
import 'package:tms/modules/employee/task/models/employee_task_model.dart';
import 'package:tms/shared/widgets/app_status_badge.dart';

class TaskDetailsDialog extends StatelessWidget {
  final EmployeeTaskModel task;

  const TaskDetailsDialog({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<EmployeeTaskController>();

    final primaryFileUrl = task.fileUrl ?? (task.attachments.isNotEmpty ? task.attachments.first['fileUrl']?.toString() : null);
    final primaryFileName = task.fileName ?? (task.attachments.isNotEmpty ? task.attachments.first['fileName']?.toString() : 'Attachment');

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: task.priorityColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                task.priority.toUpperCase(),
                                style: AppTypography.labelSm(color: task.priorityColor).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                task.projectName,
                                style: AppTypography.labelMd(color: AppColors.secondary).copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.title,
                          style: AppTypography.titleLg(
                            color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status & Deadline Bar
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Status: ', style: AppTypography.bodyMd(fontWeight: FontWeight.w600)),
                              AppStatusBadge.fromStatus(task.statusLabel),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: task.isOverdue ? AppColors.error : AppColors.outline,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.formattedDueDate,
                                style: AppTypography.bodyMd(
                                  color: task.isOverdue ? AppColors.error : (isDark ? AppColors.darkOnSurface : AppColors.onSurface),
                                  fontWeight: task.isOverdue ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Description
                    Text(
                      'Instructions & Requirements',
                      style: AppTypography.titleMd(
                        color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLowest,
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        task.description.isNotEmpty ? task.description : 'No additional instructions provided.',
                        style: AppTypography.bodyMd(
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Cloudinary File Attachment Section
                    if (task.hasAttachment) ...[
                      Text(
                        'Uploaded Attachment (Cloudinary)',
                        style: AppTypography.titleMd(
                          color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_done_rounded, color: AppColors.secondary, size: 24),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    primaryFileName ?? 'Document Attachment',
                                    style: AppTypography.bodyMd(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Secure Cloud Storage File',
                                    style: AppTypography.labelSm(color: AppColors.outline),
                                  ),
                                ],
                              ),
                            ),
                            if (primaryFileUrl != null && primaryFileUrl.isNotEmpty) ...[
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18, color: AppColors.secondary),
                                tooltip: 'Copy Cloudinary URL',
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: primaryFileUrl));
                                  Get.snackbar('Copied', 'Cloudinary file link copied to clipboard.', snackPosition: SnackPosition.BOTTOM);
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Action Footer: Status Transition Buttons
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Close'),
                  ),
                  Row(
                    children: [
                      if (!task.isInProgress && !task.isCompleted)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Get.back();
                            controller.updateTaskStatus(task.id, 'in_progress');
                          },
                          icon: const Icon(Icons.play_arrow_rounded, size: 18),
                          label: const Text('Start Working'),
                        ),
                      if (task.isInProgress)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Get.back();
                            controller.updateTaskStatus(task.id, 'completed');
                          },
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('Mark as Completed'),
                        ),
                      if (task.isCompleted)
                        OutlinedButton.icon(
                          onPressed: () {
                            Get.back();
                            controller.updateTaskStatus(task.id, 'todo');
                          },
                          icon: const Icon(Icons.undo_rounded, size: 18),
                          label: const Text('Reopen Task'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
