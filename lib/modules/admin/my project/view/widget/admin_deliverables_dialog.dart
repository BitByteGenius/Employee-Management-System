import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/admin/my%20project/models/admin_project_model.dart';

class AdminDeliverablesDialog extends StatelessWidget {
  final AdminProjectModel project;

  const AdminDeliverablesDialog({
    super.key,
    required this.project,
  });

  void _copyFileUrl(String url) {
    Clipboard.setData(ClipboardData(text: url));
    Get.snackbar(
      'Link Copied',
      'File link copied to clipboard:\n$url',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deliverables = project.deliverables;
    final hasFiles = project.hasAttachedFiles;
    final hasNotes = project.hasNotes;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.md, AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.outlineVariant.withValues(alpha: 0.3),
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
                            const Icon(
                              Icons.folder_shared_outlined,
                              size: 22,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Files & Notes from Super Admin',
                              style: AppTypography.headlineSm(
                                color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Project: ${project.name}',
                          style: AppTypography.labelMd(
                            color: AppColors.secondary,
                          ).copyWith(fontWeight: FontWeight.w600),
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

            // Content Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Attached Files & Deliverables
                    Row(
                      children: [
                        const Icon(Icons.attach_file_rounded, size: 18, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Text(
                          'ATTACHED FILES & DELIVERABLES',
                          style: AppTypography.labelMd(
                            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    if (!hasFiles)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                          borderRadius: AppRadius.borderMd,
                        ),
                        child: Text(
                          'No files were uploaded for this project yet.',
                          style: AppTypography.bodyMd(color: AppColors.outline),
                        ),
                      )
                    else
                      ...deliverables.where((d) => d.hasFile || (d.externalLink != null && d.externalLink!.isNotEmpty)).map((d) {
                        final fileUrl = d.effectiveFileUrl.isNotEmpty ? d.effectiveFileUrl : (d.externalLink ?? '');
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : AppColors.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.12),
                                  borderRadius: AppRadius.borderMd,
                                ),
                                child: const Icon(
                                  Icons.insert_drive_file_outlined,
                                  color: AppColors.secondary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.displayFileName,
                                      style: AppTypography.bodyMd(
                                        color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                                      ).copyWith(fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    if (d.submittedAt != null)
                                      Text(
                                        'Uploaded ${DateFormat('MMM dd, yyyy').format(d.submittedAt!)}${d.submittedByName != null ? ' by ${d.submittedByName}' : ''}',
                                        style: AppTypography.labelSm(color: AppColors.outline),
                                      )
                                    else if (d.externalLink != null && d.externalLink!.isNotEmpty)
                                      Text(
                                        'Link: ${d.externalLink}',
                                        style: AppTypography.labelSm(color: AppColors.secondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              if (fileUrl.isNotEmpty)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
                                  ),
                                  onPressed: () => _copyFileUrl(fileUrl),
                                  icon: const Icon(Icons.copy_rounded, size: 14),
                                  label: const Text('Copy Link'),
                                ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: AppSpacing.lg),

                    // Section 2: Notes & Instructions
                    Row(
                      children: [
                        const Icon(Icons.description_outlined, size: 18, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Text(
                          'SUPER ADMIN NOTES & INSTRUCTIONS',
                          style: AppTypography.labelMd(
                            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    if (!hasNotes)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                          borderRadius: AppRadius.borderMd,
                        ),
                        child: Text(
                          'No specific notes or instructions provided.',
                          style: AppTypography.bodyMd(color: AppColors.outline),
                        ),
                      )
                    else ...[
                      if (project.description.trim().isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : AppColors.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Project Description:',
                                style: AppTypography.labelMd(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                project.description,
                                style: AppTypography.bodyMd(
                                  color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      ...deliverables.where((d) => d.hasNotes).map((d) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : AppColors.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    d.submittedByName != null ? 'Note by ${d.submittedByName}:' : 'Submission Note:',
                                    style: AppTypography.labelMd(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (d.submittedAt != null)
                                    Text(
                                      DateFormat('MMM dd, yyyy').format(d.submittedAt!),
                                      style: AppTypography.labelSm(color: AppColors.outline),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                d.notes!,
                                style: AppTypography.bodyMd(
                                  color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text('Close'),
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
