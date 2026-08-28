import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/modules/employee/dashboard/controllers/employee_dashboard_controller.dart';
import 'package:tms/shared/widgets/app_data_table.dart';
import 'package:tms/shared/widgets/app_stat_card.dart';
import 'package:tms/shared/widgets/app_state_widgets.dart';
import 'package:tms/shared/widgets/app_status_badge.dart';

class EmployeeDashboardView extends GetView<EmployeeDashboardController> {
  const EmployeeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoading.value && controller.myTasksList.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              AppLoadingSkeleton(height: 100),
              SizedBox(height: AppSpacing.md),
              AppLoadingSkeleton(height: 240),
            ],
          ),
        );
      }

      if (controller.hasError.value && controller.myTasksList.isEmpty) {
        return AppErrorStateWidget(
          errorMessage: controller.errorMessage.value,
          onRetry: controller.fetchDashboardData,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              _buildWelcomeHeader(controller.userName.value, isDark),
              const SizedBox(height: AppSpacing.xl),

              // KPI Cards Grid
              _buildKPIGrid(context),
              const SizedBox(height: AppSpacing.xl),

              // Bento Content Grid (Left Tasks/Projects, Right Productivity/Deadlines)
              _buildBentoGrid(context, isDark),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildWelcomeHeader(String name, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Welcome, $name',
              style: AppTypography.headlineLg(
                color: isDark ? AppColors.darkOnSurface : AppColors.primary,
              ).copyWith(fontWeight: FontWeight.w800, fontSize: 28),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                controller.userRoleDisplay.value,
                style: AppTypography.labelSm(color: AppColors.secondary).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "Here is your live work overview, tasks, and project deliverables for today.",
          style: AppTypography.bodyLg(
            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildKPIGrid(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    int crossAxisCount = 5;
    if (width < 700) {
      crossAxisCount = 2;
    } else if (width < 1100) {
      crossAxisCount = 3;
    }

    return LayoutBuilder(builder: (context, constraints) {
      return GridView.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: crossAxisCount == 2 ? 1.8 : 1.4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          AppStatCard(
            title: 'My Projects',
            value: controller.myProjectsCount.value.toString(),
            icon: Icons.account_tree_outlined,
            isTrendPositive: true,
          ),
          AppStatCard(
            title: 'Assigned Tasks',
            value: controller.assignedTasksCount.value.toString(),
            icon: Icons.assignment_outlined,
            isTrendPositive: true,
          ),
          AppStatCard(
            title: 'In Progress',
            value: controller.inProgressTasksCount.value.toString(),
            icon: Icons.autorenew_outlined,
            iconColor: AppColors.secondary,
            isTrendPositive: true,
          ),
          AppStatCard(
            title: 'Completed',
            value: controller.completedTasksCount.value.toString(),
            icon: Icons.task_alt_outlined,
            iconColor: AppColors.success,
            isTrendPositive: true,
          ),
          AppStatCard(
            title: 'Overdue',
            value: controller.overdueTasksCount.value.toString(),
            icon: Icons.error_outline,
            iconColor: AppColors.error,
            leftBorderColor: AppColors.error,
            isTrendPositive: false,
          ),
        ],
      );
    });
  }

  Widget _buildBentoGrid(BuildContext context, bool isDark) {
    final isDesktop = AppBreakpoints.isDesktop(MediaQuery.sizeOf(context).width);

    final leftContent = Column(
      children: [
        // My Tasks Table from MongoDB
        AppDataTable(
          title: 'My Recent Tasks (${controller.myTasksList.length})',
          headerAction: TextButton(
            onPressed: () => controller.setRoute(AppRoutes.employeeTasks),
            child: Text('View All', style: AppTypography.labelMd(color: AppColors.secondary)),
          ),
          columns: const [
            AppColumnDef(label: 'Task'),
            AppColumnDef(label: 'Project'),
            AppColumnDef(label: 'Priority'),
            AppColumnDef(label: 'Status'),
          ],
          rows: controller.myTasksList.take(6).map((t) {
            final taskTitle = (t['title'] ?? t['task'] ?? 'Task').toString();
            String projName = 'Project';
            if (t['project'] is Map) {
              projName = (t['project']['name'] ?? t['project']['key'] ?? 'Project').toString();
            } else if (t['projectName'] != null) {
              projName = t['projectName'].toString();
            }

            final priority = (t['priority'] ?? 'Medium').toString();
            final status = (t['status'] ?? 'To Do').toString();

            return [
              Text(
                taskTitle,
                style: AppTypography.bodyMd(
                  color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                projName,
                style: AppTypography.bodyMd(
                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppStatusBadge.fromStatus(priority),
              AppStatusBadge.fromStatus(status),
            ];
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Live Active Project Card from MongoDB
        if (controller.activeProjectName.value.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.activeProjectName.value,
                      style: AppTypography.titleLg(
                        color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                      ),
                    ),
                    Text(
                      '${(controller.activeProjectProgress.value * 100).round()}% Progress',
                      style: AppTypography.labelMd(color: AppColors.secondary).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: AppRadius.borderFull,
                  child: LinearProgressIndicator(
                    value: controller.activeProjectProgress.value,
                    minHeight: 8,
                    backgroundColor: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainer,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.activeProjectTasksInfo.value,
                      style: AppTypography.bodyMd(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      controller.activeProjectDeadline.value,
                      style: AppTypography.labelSm(color: AppColors.secondary).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );

    final rightContent = Column(
      children: [
        // Productivity Circular Progress Card from Live MongoDB counts
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task Productivity',
                style: AppTypography.titleLg(
                  color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: (controller.productivityPercentage.value / 100.0).clamp(0.0, 1.0),
                          strokeWidth: 8,
                          backgroundColor: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainer,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                        ),
                      ),
                      Text(
                        '${controller.productivityPercentage.value}%',
                        style: AppTypography.titleLg(
                          color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                        ).copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Completion Rate',
                          style: AppTypography.bodyMd(
                            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${controller.completedTasksCount.value} completed / ${controller.assignedTasksCount.value} total',
                          style: AppTypography.bodyMd(
                            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Upcoming Deadlines Card from Live MongoDB tasks
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upcoming Deadlines',
                style: AppTypography.titleLg(
                  color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (controller.upcomingDeadlines.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text('No upcoming task deadlines.', style: AppTypography.bodyMd(color: AppColors.outline)),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.upcomingDeadlines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = controller.upcomingDeadlines[index];
                    final isWarn = item['isWarning'] == true;
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isWarn ? AppColors.error.withValues(alpha: 0.15) : AppColors.secondary.withValues(alpha: 0.15),
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: Icon(
                              isWarn ? Icons.warning_amber : Icons.event,
                              size: AppSizes.iconSm + 2,
                              color: isWarn ? AppColors.error : AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] ?? '',
                                  style: AppTypography.bodyMd(
                                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  item['due'] ?? '',
                                  style: AppTypography.labelSm(
                                    color: isWarn ? AppColors.error : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant),
                                  ).copyWith(fontWeight: isWarn ? FontWeight.w700 : FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: leftContent),
          const SizedBox(width: AppSpacing.md),
          Expanded(flex: 1, child: rightContent),
        ],
      );
    }

    return Column(
      children: [
        leftContent,
        const SizedBox(height: AppSpacing.md),
        rightContent,
      ],
    );
  }
}
