import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/modules/employee/controllers/employee_dashboard_controller.dart';
import 'package:tms/shared/widgets/app_data_table.dart';
import 'package:tms/shared/widgets/app_sidebar.dart';
import 'package:tms/shared/widgets/app_stat_card.dart';
import 'package:tms/shared/widgets/app_state_widgets.dart';
import 'package:tms/shared/widgets/app_status_badge.dart';
import 'package:tms/shared/widgets/app_top_bar.dart';

class EmployeeDashboardView extends GetView<EmployeeDashboardController> {
  const EmployeeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final isDesktop = AppBreakpoints.isDesktop(MediaQuery.sizeOf(context).width);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navItems = [
      const AppNavItem(
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
        route: AppRoutes.employeeDashboard,
        isSelected: true,
      ),
      const AppNavItem(
        label: 'My Projects',
        icon: Icons.account_tree_outlined,
        route: AppRoutes.projects,
      ),
      const AppNavItem(
        label: 'My Tasks',
        icon: Icons.assignment_outlined,
        route: AppRoutes.tasks,
      ),
      const AppNavItem(
        label: 'Notifications',
        icon: Icons.notifications_outlined,
        route: AppRoutes.notifications,
      ),
      const AppNavItem(
        label: 'Profile',
        icon: Icons.person_outline,
        route: AppRoutes.profile,
      ),
      const AppNavItem(
        label: 'Settings',
        icon: Icons.settings_outlined,
        route: AppRoutes.profile,
      ),
    ];

    final sidebar = AppSidebar(
      roleTitle: 'TeamOrbit',
      roleSubtitle: 'Employee Dashboard',
      navItems: navItems,
      currentRoute: AppRoutes.employeeDashboard,
    );

    return Scaffold(
      key: scaffoldKey,
      drawer: !isDesktop ? Drawer(child: sidebar) : null,
      body: Row(
        children: [
          if (isDesktop) sidebar,
          Expanded(
            child: Column(
              children: [
                // Top Navigation Bar
                Obx(() => AppTopBar(
                      title: 'My Orbit',
                      subtitle: 'Personal Work Overview',
                      userName: controller.userName.value,
                      userRole: 'Employee',
                      tabs: const ['Overview', 'Team', 'Timeline'],
                      selectedTabIndex: controller.selectedTab.value,
                      onTabSelected: controller.changeTab,
                      onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
                    )),

                // Canvas Area
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
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
                        onRetry: () => controller.fetchDashboardData(),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => controller.fetchDashboardData(),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome Banner
                            _buildWelcomeHeader(controller.userName.value, isDark),
                            const SizedBox(height: AppSpacing.xl),

                            // KPI Cards (5 Cards)
                            _buildKPIGrid(context),
                            const SizedBox(height: AppSpacing.xl),

                            // Bento Content Grid (Left Tasks/Projects, Right Productivity/Deadlines)
                            _buildBentoGrid(context, isDark),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(String name, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good Morning, $name',
          style: AppTypography.headlineLg(
            color: isDark ? AppColors.darkOnSurface : AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "Here's your work overview for today.",
          style: AppTypography.bodyLg(
            color: isDark
                ? AppColors.darkOnSurfaceVariant
                : AppColors.onSurfaceVariant,
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
          ),
          AppStatCard(
            title: 'Assigned Tasks',
            value: controller.assignedTasksCount.value.toString(),
            icon: Icons.assignment_outlined,
          ),
          AppStatCard(
            title: 'In Progress',
            value: controller.inProgressTasksCount.value.toString(),
            icon: Icons.autorenew_outlined,
            iconColor: AppColors.secondary,
          ),
          AppStatCard(
            title: 'Completed',
            value: controller.completedTasksCount.value.toString(),
            icon: Icons.task_alt_outlined,
            iconColor: AppColors.success,
          ),
          AppStatCard(
            title: 'Overdue',
            value: controller.overdueTasksCount.value.toString(),
            icon: Icons.error_outline,
            iconColor: AppColors.error,
            leftBorderColor: AppColors.error,
          ),
        ],
      );
    });
  }

  Widget _buildBentoGrid(BuildContext context, bool isDark) {
    final isDesktop = AppBreakpoints.isDesktop(MediaQuery.sizeOf(context).width);

    final leftContent = Column(
      children: [
        // My Tasks Table
        AppDataTable(
          title: 'My Tasks',
          headerAction: TextButton(
            onPressed: () => Get.toNamed(AppRoutes.tasks),
            child: Text('View All', style: AppTypography.labelMd(color: AppColors.secondary)),
          ),
          columns: const [
            AppColumnDef(label: 'Task'),
            AppColumnDef(label: 'Project'),
            AppColumnDef(label: 'Priority'),
            AppColumnDef(label: 'Status'),
          ],
          rows: controller.myTasksList.map((t) {
            return [
              Text(
                t['task'] ?? '',
                style: AppTypography.bodyMd(
                  color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                t['project'] ?? '',
                style: AppTypography.bodyMd(
                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                ),
              ),
              AppStatusBadge.fromStatus(t['priority'] ?? 'Medium'),
              AppStatusBadge.fromStatus(t['status'] ?? 'To Do'),
            ];
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.lg),

        // My Active Project Overview
        if (controller.myProjectsList.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Website Redesign',
                      style: AppTypography.titleLg(
                        color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                      ),
                    ),
                    Text(
                      '72% Progress',
                      style: AppTypography.labelMd(color: AppColors.secondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: AppRadius.borderFull,
                  child: LinearProgressIndicator(
                    value: 0.72,
                    minHeight: 8,
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceContainer
                        : AppColors.surfaceContainer,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Tasks: 8  |  Completed: 5  |  Pending: 3',
                      style: AppTypography.bodyMd(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Deadline: Aug 25',
                      style: AppTypography.labelSm(color: AppColors.error),
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
        // Productivity Circular Progress Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : AppColors.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Productivity',
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
                          value: controller.productivityPercentage.value / 100.0,
                          strokeWidth: 8,
                          backgroundColor: isDark
                              ? AppColors.darkSurfaceContainer
                              : AppColors.surfaceContainer,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                        ),
                      ),
                      Text(
                        '${controller.productivityPercentage.value}%',
                        style: AppTypography.titleLg(
                          color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                        ),
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
                            color: isDark
                                ? AppColors.darkOnSurfaceVariant
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '24 completed / 12 remaining',
                          style: AppTypography.bodyMd(
                            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                            fontWeight: FontWeight.w600,
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

        // Upcoming Deadlines Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : AppColors.outlineVariant.withOpacity(0.5),
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
                      color: isDark
                          ? AppColors.darkSurfaceContainer
                          : AppColors.surfaceContainerLow,
                      borderRadius: AppRadius.borderMd,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : AppColors.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isWarn
                                ? AppColors.error.withOpacity(0.15)
                                : AppColors.secondary.withOpacity(0.15),
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
                              ),
                              Text(
                                item['due'] ?? '',
                                style: AppTypography.labelSm(
                                  color: isWarn
                                      ? AppColors.error
                                      : (isDark
                                          ? AppColors.darkOnSurfaceVariant
                                          : AppColors.onSurfaceVariant),
                                ),
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
