import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/admin/my%20project/controller/admin_project_controller.dart';
import 'package:tms/modules/admin/my%20project/view/widget/admin_project_card.dart';
import 'package:tms/modules/admin/my%20project/view/widget/dashed_border_painter.dart';
import 'package:tms/modules/admin/my%20project/view/widget/filter_project_dialog.dart';
import 'package:tms/modules/admin/my%20project/view/widget/request_project_dialog.dart';
import 'package:tms/shared/widgets/app_state_widgets.dart';

class AdminProjectsView extends StatelessWidget {
  const AdminProjectsView({
    super.key,
    this.onMenuPressed,
  });

  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Ensure AdminProjectController is registered
    final controller = Get.put<AdminProjectController>(
      AdminProjectController(),
      permanent: false,
    );

    return Obx(() {
      if (controller.isLoading.value && controller.projects.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              AppLoadingSkeleton(height: 80),
              SizedBox(height: AppSpacing.lg),
              AppLoadingSkeleton(height: 280),
            ],
          ),
        );
      }

      if (controller.hasError.value && controller.projects.isEmpty) {
        return AppErrorStateWidget(
          errorMessage: controller.errorMessage.value,
          onRetry: () => controller.fetchProjects(),
        );
      }

      final filtered = controller.filteredProjects;

      return RefreshIndicator(
        onRefresh: () async {
          await controller.fetchProjects();
          await controller.fetchDepartmentEmployees();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section: "My Projects" + Subtitle & Top Right Filter Button
              _buildHeader(context, isDark, controller),

              const SizedBox(height: AppSpacing.xl),

              // Projects Grid + "Request New Project" Dashed Card
              _buildProjectsGrid(context, isDark, controller, filtered),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context, bool isDark, AdminProjectController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Title & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Projects',
                style: AppTypography.headlineLg(
                  color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                ).copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Active assignments and contributions.',
                style: AppTypography.bodyLg(
                  color: isDark
                      ? AppColors.darkOnSurfaceVariant
                      : AppColors.onSurfaceVariant,
                ).copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        // Right: Filter Button
        OutlinedButton.icon(
          onPressed: () {
            Get.dialog(const FilterProjectDialog());
          },
          icon: Icon(
            Icons.tune,
            size: 18,
            color: isDark ? AppColors.darkOnSurface : AppColors.primary,
          ),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter',
                style: AppTypography.bodyMd(
                  color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (controller.selectedFilter.value != 'All') ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    controller.selectedFilter.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            side: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.18)
                  : AppColors.outlineVariant.withValues(alpha: 0.7),
              width: 1.2,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.borderMd,
            ),
            backgroundColor: isDark
                ? AppColors.darkSurfaceContainer
                : AppColors.surfaceContainerLowest,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectsGrid(
    BuildContext context,
    bool isDark,
    AdminProjectController controller,
    List<dynamic> filtered,
  ) {
    final width = MediaQuery.sizeOf(context).width;

    // Responsive columns matching stitch breakpoint rules
    int crossAxisCount = 3;
    if (width < 750) {
      crossAxisCount = 1;
    } else if (width < 1150) {
      crossAxisCount = 2;
    }

    final totalItems = filtered.length + 1; // Projects + "Request New Project" card

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - ((crossAxisCount - 1) * AppSpacing.lg)) / crossAxisCount;
        // Target fixed card height for consistent grid look with files/notes section
        const cardHeight = 255.0;
        final childAspectRatio = itemWidth / cardHeight;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: totalItems,
          itemBuilder: (context, index) {
            // If it's the last card, render the "Request New Project" dashed card
            if (index == filtered.length) {
              return _buildRequestProjectCard(context, isDark);
            }

            final project = filtered[index];
            return AdminProjectCard(
              project: project,
            );
          },
        );
      },
    );
  }

  Widget _buildRequestProjectCard(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.dialog(const RequestProjectDialog());
        },
        borderRadius: AppRadius.borderLg,
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: isDark
                ? Colors.white.withValues(alpha: 0.18)
                : AppColors.outlineVariant.withValues(alpha: 0.7),
            strokeWidth: 1.4,
            dashLength: 6,
            gapLength: 5,
            radius: 12,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.3)
                  : AppColors.surfaceContainerLowest.withValues(alpha: 0.4),
              borderRadius: AppRadius.borderLg,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Subtle Plus Icon Container
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceContainer
                          : AppColors.surfaceContainerLow,
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: Icon(
                      Icons.add,
                      size: 22,
                      color: isDark
                          ? AppColors.darkOnSurface
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Request New Project',
                    style: AppTypography.titleLg(
                      color: isDark
                          ? AppColors.darkOnSurface
                          : AppColors.primary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}