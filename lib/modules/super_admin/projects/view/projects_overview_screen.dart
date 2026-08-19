import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_constants.dart' hide AppColors, AppRadius;
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/super_admin/projects/controller/project_controller.dart';
import 'package:tms/modules/super_admin/projects/models/project_model.dart';
import 'package:tms/modules/super_admin/projects/view/widget/create_project_dialog.dart';
import 'package:tms/shared/widgets/app_top_bar.dart';

class ProjectsOverviewScreen extends GetView<ProjectController> {
  const ProjectsOverviewScreen({
    super.key,
    this.onMenuPressed,
  });

  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ==========================================================
        // TOP BAR
        // ==========================================================
        AppTopBar(
          title: 'Projects Overview',
          subtitle: 'Manage and monitor all active enterprise initiatives.',
          userName: 'Super Admin',
          userRole: 'Super Admin',
          onMenuPressed: onMenuPressed,
        ),

        // ==========================================================
        // BODY
        // ==========================================================
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.refreshProjects();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // BREADCRUMB
                      // ==================================================
                      Text(
                        '> Projects Overview',
                        style: AppTypography.labelSm(
                          color: _muted(isDark),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // ==================================================
                      // TITLE & ACTIONS HEADER
                      // ==================================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Projects Overview',
                                  style: AppTypography.headlineMd(
                                    color: _text(isDark),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 760),
                                  child: Text(
                                    'Manage and monitor all active enterprise initiatives.',
                                    style: AppTypography.bodyMd(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Obx(() => PopupMenuButton<String>(
                                onSelected: (val) => controller.updateStatusFilter(val),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'all', child: Text('All Statuses')),
                                  const PopupMenuItem(value: 'active', child: Text('Active')),
                                  const PopupMenuItem(value: 'archived', child: Text('Archived')),
                                  const PopupMenuItem(value: 'completed', child: Text('Completed')),
                                ],
                                child: _buildDropdown(
                                  controller.selectedStatus.value == 'all'
                                      ? 'All Statuses'
                                      : controller.selectedStatus.value.capitalizeFirst!,
                                  isDark,
                                ),
                              )),
                              const SizedBox(width: AppSpacing.md),
                              Obx(() => PopupMenuButton<String>(
                                onSelected: (val) => controller.updateManagerFilter(val),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'all', child: Text('All Managers')),
                                ],
                                child: _buildDropdown(
                                  controller.selectedManager.value == 'all'
                                      ? 'All Managers'
                                      : controller.selectedManager.value,
                                  isDark,
                                ),
                              )),
                              const SizedBox(width: AppSpacing.md),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Get.dialog(
                                    const CreateProjectDialog(),
                                    barrierColor: AppColors.primaryContainer.withValues(alpha: 0.5),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('New Project'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: AppColors.onSecondary,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  textStyle: AppTypography.labelMd(),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ==================================================
                      // PROJECTS GRID
                      // ==================================================
                      Obx(() {
                        if (controller.isLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.all(AppSpacing.xxxl),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (controller.projects.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xxxl),
                              child: Text(
                                controller.errorMessage.value.isNotEmpty
                                    ? controller.errorMessage.value
                                    : 'No projects found.',
                                style: AppTypography.bodyLg(color: _muted(isDark)),
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.projects.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: AppBreakpoints.isDesktop(MediaQuery.sizeOf(context).width) ? 3 : 2,
                            crossAxisSpacing: AppSpacing.lg,
                            mainAxisSpacing: AppSpacing.lg,
                            childAspectRatio: 1.1,
                          ),
                          itemBuilder: (context, index) {
                            final project = controller.projects[index];
                            return _buildProjectCard(context, project, isDark);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: AppTypography.bodyMd(color: _text(isDark))),
          const SizedBox(width: AppSpacing.md),
          const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.outline),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectModel project, bool isDark) {
    final isActive = project.isActive;
    final progressValue = (project.progress / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppShadow.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.surfaceContainerLow : AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  isActive ? 'ACTIVE' : project.status.toUpperCase(),
                  style: AppTypography.labelSm(color: isActive ? AppColors.secondary : AppColors.onSurfaceVariant),
                ),
              ),
              if (project.departmentName != null && project.departmentName!.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.apartment_outlined, size: 12, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            project.departmentName!,
                            style: AppTypography.labelSm(
                              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
                onSelected: (action) {
                  if (action == 'deliverables') {
                    controller.openDeliverablesDialog(project.id);
                  } else if (action == 'toggle_status') {
                    final nextStatus = project.isActive ? 'archived' : 'active';
                    controller.updateProjectStatus(project.id, nextStatus);
                  } else if (action == 'delete') {
                    controller.deleteProject(project.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'deliverables',
                    child: Text('Submit Deliverables'),
                  ),
                  PopupMenuItem(
                    value: 'toggle_status',
                    child: Text(project.isActive ? 'Archive Project' : 'Activate Project'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete Project', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(project.name, style: AppTypography.headlineSm(color: _text(isDark)), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.sm),
          Text(
            project.description.isNotEmpty
                ? project.description
                : (project.departmentName != null ? 'Department: ${project.departmentName}' : 'Enterprise initiative.'),
            style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: AppTypography.labelMd(color: AppColors.outline)),
              Text(project.formattedProgress, style: AppTypography.labelMd(color: _text(isDark))),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(isActive ? AppColors.secondary : AppColors.outline),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.surfaceContainerHigh, height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.checklist, size: 18, color: AppColors.outline),
                  const SizedBox(width: AppSpacing.xs),
                  Text(project.tasksRatio, style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.outline),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    project.dueDate != null
                        ? 'Due ${DateFormat('MMM dd, yyyy').format(project.dueDate!)}'
                        : project.formattedDate,
                    style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// COLORS
// ============================================================================

Color _text(bool isDark) =>
    isDark ? AppColors.darkOnSurface : AppColors.onSurface;

Color _muted(bool isDark) =>
    isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant;