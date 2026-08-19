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
              if (project.hasFileAttachment) ...[
                const SizedBox(width: AppSpacing.sm),
                _buildAttachmentPill(context, project, isDark),
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

  Widget _buildAttachmentPill(BuildContext context, ProjectModel project, bool isDark) {
    final deliverable = project.primaryDeliverable;
    final isLink = deliverable?.externalLink != null && deliverable!.externalLink!.isNotEmpty;
    final rawName = deliverable?.fileName ??
        (deliverable?.filePath != null
            ? deliverable!.filePath!.split('/').last.split('\\').last
            : (isLink ? 'Link' : 'File'));

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.full),
      onTap: () => _showAttachmentDialog(context, project, deliverable),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLink ? Icons.link : Icons.attach_file,
              size: 12,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 80),
              child: Text(
                rawName,
                style: AppTypography.labelSm(
                  color: AppColors.secondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentDialog(BuildContext context, ProjectModel project, dynamic deliverable) {
    if (deliverable == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final file = deliverable.fileName ?? deliverable.filePath?.split('/').last.split('\\').last ?? 'Attachment';
    final link = deliverable.externalLink;
    final path = deliverable.filePath ?? deliverable.fileUrl;
    final notes = deliverable.notes;

    final isImage = path != null &&
        (path.toLowerCase().endsWith('.png') ||
            path.toLowerCase().endsWith('.jpg') ||
            path.toLowerCase().endsWith('.jpeg') ||
            path.toLowerCase().endsWith('.webp') ||
            path.toLowerCase().endsWith('.gif') ||
            path.contains('/image/upload/'));

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Project Attachment',
                      style: AppTypography.headlineSm(
                        color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: AppSizes.iconSm,
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Project: ${project.name}',
                  style: AppTypography.bodyMd(
                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Divider(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.outlineVariant,
                  height: 1,
                ),
                const SizedBox(height: AppSpacing.lg),

                // File Preview Area
                if (path != null && path.isNotEmpty) ...[
                  if (isImage) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 280, minHeight: 140),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.outlineVariant,
                          ),
                        ),
                        child: Image.network(
                          path,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppSpacing.lg),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image_outlined, size: 40, color: AppColors.outline),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Unable to load preview',
                                  style: AppTypography.labelSm(color: AppColors.outline),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(Icons.image_outlined, size: 16, color: AppColors.secondary),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            file,
                            style: AppTypography.bodyMd(
                              color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Icon(
                              path.toLowerCase().endsWith('.pdf')
                                  ? Icons.picture_as_pdf_outlined
                                  : Icons.insert_drive_file_outlined,
                              color: AppColors.secondary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  file,
                                  style: AppTypography.bodyMd(
                                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Attached Document',
                                  style: AppTypography.labelSm(
                                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],

                // External Link (if any)
                if (link != null && link.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, color: AppColors.secondary, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'External Link',
                                style: AppTypography.labelSm(
                                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                                ),
                              ),
                              SelectableText(
                                link,
                                style: AppTypography.bodyMd(
                                  color: AppColors.secondary,
                                ).copyWith(decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Notes
                if (notes != null && notes.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Notes:',
                    style: AppTypography.labelSm(
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      notes,
                      style: AppTypography.bodyMd(
                        color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
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