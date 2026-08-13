import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/modules/admin/controllers/admin_dashboard_controller.dart';
import 'package:tms/shared/widgets/app_data_table.dart';
import 'package:tms/shared/widgets/app_sidebar.dart';
import 'package:tms/shared/widgets/app_stat_card.dart';
import 'package:tms/shared/widgets/app_state_widgets.dart';
import 'package:tms/shared/widgets/app_status_badge.dart';
import 'package:tms/shared/widgets/app_top_bar.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final isDesktop = AppBreakpoints.isDesktop(MediaQuery.sizeOf(context).width);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navItems = [
      const AppNavItem(
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
        route: AppRoutes.adminDashboard,
        isSelected: true,
      ),
      const AppNavItem(
        label: 'Projects',
        icon: Icons.account_tree_outlined,
        route: AppRoutes.projects,
      ),
      const AppNavItem(
        label: 'Workforce',
        icon: Icons.groups_outlined,
        route: AppRoutes.departments,
      ),
      const AppNavItem(
        label: 'Time Tracking',
        icon: Icons.schedule_outlined,
        route: AppRoutes.tasks,
      ),
      const AppNavItem(
        label: 'Reports',
        icon: Icons.analytics_outlined,
        route: AppRoutes.reports,
      ),
      const AppNavItem(
        label: 'Settings',
        icon: Icons.settings_outlined,
        route: AppRoutes.profile,
      ),
    ];

    final sidebar = AppSidebar(
      roleTitle: 'TeamOrbit',
      roleSubtitle: 'Department Management',
      navItems: navItems,
      currentRoute: AppRoutes.adminDashboard,
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
                // Top Navigation Bar with Tabs
                Obx(() => AppTopBar(
                      title: controller.departmentName.value,
                      subtitle: 'Department Admin',
                      userName: controller.userName.value,
                      userRole: 'Department Admin',
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

                    if (controller.hasError.value && controller.projectProgressList.isEmpty) {
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

                            // Bento Row (Project Progress & Upcoming Deadlines)
                            _buildProgressAndDeadlinesRow(context, isDark),
                            const SizedBox(height: AppSpacing.xl),

                            // Team Workload Table
                            _buildTeamWorkloadTable(isDark),
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
          "Here's your team's current progress.",
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
            title: 'Team Members',
            value: controller.teamMembersCount.value.toString(),
            icon: Icons.people_outline,
            trendText: '2',
            isTrendPositive: true,
          ),
          AppStatCard(
            title: 'Active Projects',
            value: controller.activeProjectsCount.value.toString(),
            icon: Icons.account_tree_outlined,
            trendText: '1',
            isTrendPositive: true,
          ),
          AppStatCard(
            title: 'Pending Tasks',
            value: controller.pendingTasksCount.value.toString(),
            icon: Icons.assignment_late_outlined,
            trendText: '5',
            isTrendPositive: false,
          ),
          AppStatCard(
            title: 'Completed Tasks',
            value: controller.completedTasksCount.value.toString(),
            icon: Icons.task_alt_outlined,
            trendText: '12',
            isTrendPositive: true,
          ),
          AppStatCard(
            title: 'Overdue Tasks',
            value: controller.overdueTasksCount.value.toString(),
            icon: Icons.warning_amber_outlined,
            iconColor: AppColors.error,
            leftBorderColor: AppColors.error,
            trendText: '1',
            isTrendPositive: false,
          ),
        ],
      );
    });
  }

  Widget _buildProgressAndDeadlinesRow(BuildContext context, bool isDark) {
    final isDesktop = AppBreakpoints.isDesktop(MediaQuery.sizeOf(context).width);

    final progressWidget = Container(
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
                'Project Progress',
                style: AppTypography.titleLg(
                  color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.projects),
                child: Text('View All', style: AppTypography.labelMd(color: AppColors.secondary)),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          ...controller.projectProgressList.map((p) {
            final double prog = (p['progress'] ?? 0.5) as double;
            final int pct = (prog * 100).toInt();
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p['name'] ?? '',
                        style: AppTypography.bodyMd(
                          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: AppTypography.labelMd(color: AppColors.secondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: AppRadius.borderFull,
                    child: LinearProgressIndicator(
                      value: prog,
                      minHeight: 8,
                      backgroundColor: isDark
                          ? AppColors.darkSurfaceContainer
                          : AppColors.surfaceContainer,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );

    final deadlinesWidget = Container(
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
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.upcomingDeadlines.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = controller.upcomingDeadlines[index];
              final isUrgent = item['isUrgent'] == true;
              return Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceContainer
                      : AppColors.surfaceContainerLow,
                  borderRadius: AppRadius.borderMd,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isUrgent ? AppColors.error : AppColors.outline,
                        shape: BoxShape.circle,
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
                            '${item['project']} • ${item['time']}',
                            style: AppTypography.labelSm(
                              color: isDark
                                  ? AppColors.darkOnSurfaceVariant
                                  : AppColors.onSurfaceVariant,
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
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: progressWidget),
          const SizedBox(width: AppSpacing.md),
          Expanded(flex: 1, child: deadlinesWidget),
        ],
      );
    }

    return Column(
      children: [
        progressWidget,
        const SizedBox(height: AppSpacing.md),
        deadlinesWidget,
      ],
    );
  }

  Widget _buildTeamWorkloadTable(bool isDark) {
    return AppDataTable(
      title: 'Team Workload',
      columns: const [
        AppColumnDef(label: 'Member'),
        AppColumnDef(label: 'Role'),
        AppColumnDef(label: 'Assigned'),
        AppColumnDef(label: 'Completed'),
        AppColumnDef(label: 'Status'),
      ],
      rows: controller.teamWorkloadList.map((m) {
        return [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  m['initials'] ?? 'U',
                  style: AppTypography.labelSm(color: AppColors.onPrimaryContainer),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                m['name'] ?? '',
                style: AppTypography.bodyMd(
                  color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            m['role'] ?? '',
            style: AppTypography.bodyMd(
              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            m['assigned'].toString(),
            style: AppTypography.bodyMd(fontWeight: FontWeight.w600),
          ),
          Text(
            m['completed'].toString(),
            style: AppTypography.bodyMd(fontWeight: FontWeight.w600),
          ),
          AppStatusBadge.fromStatus(m['status'] ?? 'On Track'),
        ];
      }).toList(),
    );
  }
}
