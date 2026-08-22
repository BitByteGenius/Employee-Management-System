import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/admin/my%20project/controller/admin_project_controller.dart';

class FilterProjectDialog extends StatelessWidget {
  const FilterProjectDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<AdminProjectController>();
    final statuses = ['All', 'Active', 'Planning', 'At Risk', 'Completed'];

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune, size: 20, color: AppColors.secondary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Filter Projects',
                        style: AppTypography.titleLg(
                          color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              Text(
                'Status',
                style: AppTypography.labelMd(
                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Status Filter Chips
              Obx(() {
                final current = controller.selectedFilter.value;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: statuses.map((status) {
                    final isSelected = current == status;
                    return ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      selectedColor: AppColors.secondary.withValues(alpha: 0.15),
                      backgroundColor: isDark
                          ? AppColors.darkSurfaceContainer
                          : AppColors.surfaceContainerLow,
                      labelStyle: AppTypography.bodyMd(
                        color: isSelected
                            ? AppColors.secondary
                            : (isDark ? AppColors.darkOnSurface : AppColors.onSurface),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.secondary
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                      onSelected: (_) {
                        controller.setFilter(status);
                      },
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: AppSpacing.lg),

              // Search inside dialog
              Text(
                'Search by keyword',
                style: AppTypography.labelMd(
                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                initialValue: controller.searchQuery.value,
                onChanged: controller.setSearch,
                style: AppTypography.bodyMd(
                  color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search title, role, manager...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.setFilter('All');
                      controller.setSearch('');
                      Get.back();
                    },
                    child: const Text('Reset All'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
