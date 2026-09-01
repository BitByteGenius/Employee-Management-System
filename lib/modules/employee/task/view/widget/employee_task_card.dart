import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/employee/task/controller/employee_task_controller.dart';
import 'package:tms/modules/employee/task/models/employee_task_model.dart';
import 'package:tms/modules/employee/task/view/widget/task_details_dialog.dart';
import 'package:tms/shared/widgets/app_status_badge.dart';

class EmployeeTaskCard extends StatelessWidget {
  final EmployeeTaskModel task;

  const EmployeeTaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<EmployeeTaskController>();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.borderMd,
          onTap: () => Get.dialog(TaskDetailsDialog(task: task)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Project & Priority Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.folder_outlined, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              task.projectName,
                              style: AppTypography.labelSm(color: AppColors.secondary).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: task.priorityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.priority.toUpperCase(),
                        style: AppTypography.labelSm(color: task.priorityColor).copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xs + 2),

                // Task Title
                Text(
                  task.title,
                  style: AppTypography.titleMd(
                    color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: AppTypography.bodyMd(
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: AppSpacing.md),

                // Bottom Row: Status Badge, Attachment, Due Date, Quick Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AppStatusBadge.fromStatus(task.statusLabel),
                        if (task.hasAttachment) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.attach_file, size: 16, color: AppColors.secondary),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: task.isOverdue ? AppColors.error : AppColors.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.formattedDueDate,
                          style: AppTypography.labelSm(
                            color: task.isOverdue ? AppColors.error : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant),
                          ).copyWith(fontWeight: task.isOverdue ? FontWeight.w700 : FontWeight.w500),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        if (!task.isCompleted)
                          IconButton(
                            icon: Icon(
                              task.isInProgress ? Icons.check_circle_outline : Icons.play_circle_outline,
                              size: 20,
                              color: task.isInProgress ? AppColors.success : AppColors.secondary,
                            ),
                            tooltip: task.isInProgress ? 'Mark Complete' : 'Start Task',
                            splashRadius: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              final nextStatus = task.isInProgress ? 'completed' : 'in_progress';
                              controller.updateTaskStatus(task.id, nextStatus);
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
