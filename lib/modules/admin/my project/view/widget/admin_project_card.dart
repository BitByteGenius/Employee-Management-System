import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/admin/my%20project/controller/admin_project_controller.dart';
import 'package:tms/modules/admin/my%20project/models/admin_project_model.dart';
import 'package:tms/modules/admin/my%20project/view/widget/admin_deliverables_dialog.dart';
import 'package:tms/modules/admin/my%20project/view/widget/assign_task_dialog.dart';

class AdminProjectCard extends StatelessWidget {
  final AdminProjectModel project;
  final VoidCallback? onTap;

  const AdminProjectCard({
    super.key,
    required this.project,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<AdminProjectController>();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.outlineVariant.withValues(alpha: 0.45),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Left indicator vertical stripe
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4.5,
            child: Container(
              color: project.indicatorColor,
            ),
          ),

          // Main Card Content
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg + 4,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Status Badge + Assign Task Button + 3-Dots Menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Status Badge & Assign Task Widget Row
                    Expanded(
                      child: Row(
                        children: [
                          // JetBrains Mono Monospaced Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: project.statusBadgeBgColor(isDark),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              project.statusLabel,
                              style: AppTypography.labelSm(
                                color: project.statusBadgeTextColor,
                              ).copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),

                          // Dynamic Assign Task Action Widget beside ACTIVE/status badge
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Get.dialog(AssignTaskDialog(project: project));
                              },
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.secondary.withValues(alpha: 0.15)
                                      : AppColors.secondary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: AppColors.secondary.withValues(alpha: 0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.add_task_rounded,
                                      size: 13,
                                      color: AppColors.secondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Assign Task',
                                      style: AppTypography.labelSm(
                                        color: AppColors.secondary,
                                      ).copyWith(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Three Dots Context Menu
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: isDark
                            ? AppColors.darkOnSurfaceVariant
                            : AppColors.outline,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 150),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.borderMd,
                      ),
                      onSelected: (value) => _handleMenuAction(context, controller, value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'assign_task',
                          child: Row(
                            children: [
                              Icon(Icons.assignment_ind_outlined, size: 18, color: AppColors.secondary),
                              SizedBox(width: AppSpacing.sm),
                              Text('Assign Task'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'view_deliverables',
                          child: Row(
                            children: [
                              Icon(Icons.folder_shared_outlined, size: 18, color: AppColors.secondary),
                              SizedBox(width: AppSpacing.sm),
                              Text('Files & Notes'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'active',
                          child: Row(
                            children: [
                              Icon(Icons.play_circle_outline, size: 18, color: AppColors.secondary),
                              SizedBox(width: AppSpacing.sm),
                              Text('Set Active'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'planning',
                          child: Row(
                            children: [
                              Icon(Icons.pending_actions_outlined, size: 18, color: Color(0xFF64748B)),
                              SizedBox(width: AppSpacing.sm),
                              Text('Set Planning'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'at_risk',
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_outlined, size: 18, color: AppColors.error),
                              SizedBox(width: AppSpacing.sm),
                              Text('Set At Risk'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'completed',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
                              SizedBox(width: AppSpacing.sm),
                              Text('Set Completed'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                              SizedBox(width: AppSpacing.sm),
                              Text('Delete Project', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Project Title
                Text(
                  project.name,
                  style: AppTypography.titleLg(
                    color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppSpacing.sm),

                // Info Line 1: Role
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 16,
                      color: isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.outline,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: AppTypography.bodyMd(
                            color: isDark
                                ? AppColors.darkOnSurfaceVariant
                                : AppColors.onSurfaceVariant,
                          ),
                          children: [
                            const TextSpan(text: 'Role:  '),
                            TextSpan(
                              text: project.displayRole,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkOnSurface
                                    : AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Info Line 2: Deadline
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: project.isAtRiskOrOverdue
                          ? AppColors.error
                          : (isDark
                              ? AppColors.darkOnSurfaceVariant
                              : AppColors.outline),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: AppTypography.bodyMd(
                            color: project.isAtRiskOrOverdue
                                ? AppColors.error
                                : (isDark
                                    ? AppColors.darkOnSurfaceVariant
                                    : AppColors.onSurfaceVariant),
                          ),
                          children: [
                            const TextSpan(text: 'Deadline:  '),
                            TextSpan(
                              text: project.formattedDeadline,
                              style: TextStyle(
                                color: project.isAtRiskOrOverdue
                                    ? AppColors.error
                                    : (isDark
                                        ? AppColors.darkOnSurface
                                        : AppColors.primary),
                                fontWeight: project.isAtRiskOrOverdue
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Super Admin Uploaded Files & Notes Preview Bar
                if (project.hasAttachedFiles || project.hasNotes) ...[
                  const SizedBox(height: 6),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.dialog(AdminDeliverablesDialog(project: project));
                      },
                      borderRadius: AppRadius.borderSm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceContainer
                              : AppColors.surfaceContainerLow,
                          borderRadius: AppRadius.borderSm,
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : AppColors.outlineVariant.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              project.hasAttachedFiles
                                  ? Icons.attach_file_rounded
                                  : Icons.sticky_note_2_outlined,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                project.hasAttachedFiles
                                    ? 'File: ${project.primaryFileDeliverable?.displayFileName ?? 'Attached'}'
                                    : 'Notes: ${project.displayNotes ?? ''}',
                                style: AppTypography.labelSm(
                                  color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                                ).copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'View',
                              style: AppTypography.labelSm(
                                color: AppColors.secondary,
                              ).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 10.5,
                              ),
                            ),
                            const SizedBox(width: 1),
                            const Icon(
                              Icons.chevron_right,
                              size: 13,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.sm),

                // Divider line
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.outlineVariant.withValues(alpha: 0.35),
                ),

                const SizedBox(height: 6),

                // Progress Section: Header with Label & Percentage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PROGRESS',
                      style: AppTypography.labelSm(
                        color: isDark
                            ? AppColors.darkOnSurfaceVariant
                            : AppColors.onSurfaceVariant,
                      ).copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        fontSize: 10.5,
                      ),
                    ),
                    Text(
                      project.formattedProgress,
                      style: AppTypography.labelSm(
                        color: project.progressColor,
                      ).copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Rounded Linear Progress Bar
                ClipRRect(
                  borderRadius: AppRadius.borderFull,
                  child: LinearProgressIndicator(
                    value: project.progressFraction,
                    minHeight: 5.5,
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceContainer
                        : AppColors.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(project.progressColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, AdminProjectController controller, String action) {
    if (action == 'assign_task') {
      Get.dialog(AssignTaskDialog(project: project));
    } else if (action == 'view_deliverables') {
      Get.dialog(AdminDeliverablesDialog(project: project));
    } else if (action == 'delete') {
      Get.dialog(
        AlertDialog(
          title: const Text('Delete Project'),
          content: Text('Are you sure you want to delete "${project.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                Get.back();
                controller.deleteProject(project.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      controller.updateStatus(project.id, action);
    }
  }
}
