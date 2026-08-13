import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/modules/super_admin/controllers/super_admin_dashboard_controller.dart';
import 'package:tms/shared/widgets/app_data_table.dart';
import 'package:tms/shared/widgets/app_sidebar.dart';
import 'package:tms/shared/widgets/app_stat_card.dart';
import 'package:tms/shared/widgets/app_state_widgets.dart';
import 'package:tms/shared/widgets/app_status_badge.dart';
import 'package:tms/shared/widgets/app_top_bar.dart';

class SuperAdminDashboardView extends GetView<SuperAdminDashboardController> {
  const SuperAdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final isDesktop = AppBreakpoints.isDesktop(MediaQuery.sizeOf(context).width);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navItems = [
      const AppNavItem(
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
        route: AppRoutes.superAdminDashboard,
        isSelected: true,
      ),
      const AppNavItem(
        label: 'Organization',
        icon: Icons.corporate_fare_outlined,
        route: AppRoutes.departments,
      ),
      const AppNavItem(
        label: 'Access Control',
        icon: Icons.admin_panel_settings_outlined,
        route: AppRoutes.superAdminDashboard,
      ),
      const AppNavItem(
        label: 'Work Management',
        icon: Icons.work_outline,
        route: AppRoutes.projects,
      ),
      const AppNavItem(
        label: 'Communication',
        icon: Icons.forum_outlined,
        route: AppRoutes.notifications,
      ),
      const AppNavItem(
        label: 'Analytics',
        icon: Icons.analytics_outlined,
        route: AppRoutes.reports,
      ),
      const AppNavItem(
        label: 'System',
        icon: Icons.settings_system_daydream_outlined,
        route: AppRoutes.superAdminDashboard,
      ),
    ];

    final sidebar = AppSidebar(
      roleTitle: 'TeamOrbit',
      roleSubtitle: 'Super Admin',
      navItems: navItems,
      currentRoute: AppRoutes.superAdminDashboard,
      primaryActionText: 'New User',
      primaryActionIcon: Icons.add_circle_outline,
      onPrimaryActionTap: () {
        Get.snackbar(
          'User Management',
          'Create new admin or user modal',
          snackPosition: SnackPosition.TOP,
        );
      },
    );

    return Scaffold(
      key: scaffoldKey,
      drawer: !isDesktop ? Drawer(child: sidebar) : null,
      body: Row(
        children: [
          // Desktop Fixed Sidebar
          if (isDesktop) sidebar,

          // Main Canvas Area
          Expanded(
            child: Column(
              children: [
                // Top Navigation Bar
                Obx(() => AppTopBar(
                      title: 'Command Center',
                      subtitle: 'Super Admin Overview',
                      userName: controller.userName.value,
                      userRole: 'Super Admin',
                      onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
                    )),

                // Dashboard Content Area
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          children: [
                            AppLoadingSkeleton(height: 120),
                            SizedBox(height: AppSpacing.md),
                            AppLoadingSkeleton(height: 240),
                          ],
                        ),
                      );
                    }

                    if (controller.hasError.value && controller.pendingUsers.isEmpty) {
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

                            // Advanced 6-KPI Grid
                            _buildKPIGrid(context),
                            const SizedBox(height: AppSpacing.xl),

                            // Strategic Analytics Section (Donut & Efficiency)
                            _buildAnalyticsSection(context, isDark),
                            const SizedBox(height: AppSpacing.xl),

                            // Approvals & Audit Row
                            _buildApprovalsAndAuditRow(context, isDark),
                            const SizedBox(height: AppSpacing.xl),

                            // Portfolio Health Overview Table
                            _buildPortfolioTable(isDark),
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
          "Here is a high-level overview of your organization's health.",
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
    int crossAxisCount = 6;
    if (width < 700) {
      crossAxisCount = 1;
    } else if (width < 1100) {
      crossAxisCount = 3;
    }

    return LayoutBuilder(builder: (context, constraints) {
      return GridView.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: crossAxisCount == 1 ? 2.5 : (crossAxisCount == 3 ? 1.6 : 1.35),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          AppStatCard(
            title: 'Total Depts',
            value: controller.totalDepartments.value.toString(),
            icon: Icons.domain,
            trendText: '1',
            isTrendPositive: true,
          ),
          AppStatCard(
            title: 'Total Admins',
            value: controller.totalAdmins.value.toString(),
            icon: Icons.admin_panel_settings_outlined,
            trendText: '3',
            isTrendPositive: true,
          ),
          AppStatCard(
            title: 'Employees',
            value: controller.totalEmployees.value.toString(),
            icon: Icons.badge_outlined,
            trendText: '12%',
            isTrendPositive: true,
          ),
          AppStatCard(
            title: 'Portfolio Health',
            value: '${controller.portfolioHealth.value}% Active',
            icon: Icons.monitor_heart_outlined,
            progressValue: controller.portfolioHealth.value / 100.0,
            progressColor: AppColors.success,
          ),
          AppStatCard(
            title: 'Utilization',
            value: '${controller.utilization.value}%',
            icon: Icons.pie_chart_outline,
            trendText: 'Optimal',
            isTrendPositive: true,
          ),
          AppStatCard(
            title: 'Pending Apprv.',
            value: controller.pendingApprovalsCount.value.toString(),
            icon: Icons.pending_actions_outlined,
            iconColor: AppColors.error,
            leftBorderColor: AppColors.error,
            trendText: 'Action Req.',
            isTrendPositive: false,
          ),
        ],
      );
    });
  }

  Widget _buildAnalyticsSection(BuildContext context, bool isDark) {
    final isDesktop = AppBreakpoints.isDesktop(MediaQuery.sizeOf(context).width);

    final distributionWidget = Container(
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
            'Project Portfolio Distribution',
            style: AppTypography.titleLg(
              color: isDark ? AppColors.darkOnSurface : AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: 0.85,
                    strokeWidth: 16,
                    backgroundColor: AppColors.warning.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '142',
                      style: AppTypography.headlineLg(
                        color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                      ),
                    ),
                    Text(
                      'Active',
                      style: AppTypography.labelSm(
                        color: isDark
                            ? AppColors.darkOnSurfaceVariant
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.md,
            children: [
              _buildChartLegend(AppColors.secondary, 'In Progress (50%)'),
              _buildChartLegend(AppColors.success, 'Completed (35%)'),
              _buildChartLegend(AppColors.warning, 'On Hold (15%)'),
            ],
          ),
        ],
      ),
    );

    final efficiencyWidget = Container(
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
            'Departmental Efficiency Index',
            style: AppTypography.titleLg(
              color: isDark ? AppColors.darkOnSurface : AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...controller.departmentPerformance.map((dept) {
            final double val = (dept['efficiency'] ?? 0.8) as double;
            final int pct = (val * 100).toInt();
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dept['department'] ?? '',
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
                      value: val,
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

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: distributionWidget),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: efficiencyWidget),
        ],
      );
    }

    return Column(
      children: [
        distributionWidget,
        const SizedBox(height: AppSpacing.md),
        efficiencyWidget,
      ],
    );
  }

  Widget _buildChartLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: AppTypography.labelSm()),
      ],
    );
  }

  Widget _buildApprovalsAndAuditRow(BuildContext context, bool isDark) {
    final isDesktop = AppBreakpoints.isDesktop(MediaQuery.sizeOf(context).width);

    final approvalsWidget = Container(
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
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Unified Approvals Queue',
                  style: AppTypography.titleLg(
                    color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Text(
                    '${controller.pendingUsers.length} PENDING',
                    style: AppTypography.labelSm(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          if (controller.pendingUsers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  'No pending approval requests',
                  style: AppTypography.bodyMd(),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.pendingUsers.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final user = controller.pendingUsers[index];
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(
                          user['initials'] ?? 'U',
                          style: AppTypography.labelMd(
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'] ?? user['fullName'] ?? 'User',
                              style: AppTypography.bodyMd(
                                color: isDark
                                    ? AppColors.darkOnSurface
                                    : AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Requesting: ${user['role'] ?? 'Access'}',
                              style: AppTypography.labelSm(
                                color: isDark
                                    ? AppColors.darkOnSurfaceVariant
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () => controller.rejectUser(user['id'] ?? ''),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: const Text('Deny'),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          ElevatedButton(
                            onPressed: () => controller.approveUser(user['id'] ?? ''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: const Text('Approve'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );

    final auditWidget = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
                'Critical Audit Stream',
                style: AppTypography.titleLg(
                  color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text('View All', style: AppTypography.labelMd(color: AppColors.secondary)),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.auditLogs.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final item = controller.auditLogs[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['title'] ?? item['action'] ?? 'System Event',
                              style: AppTypography.bodyMd(
                                color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              item['time'] ?? 'Recently',
                              style: AppTypography.labelSm(
                                color: isDark
                                    ? AppColors.darkOnSurfaceVariant
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['description'] ?? item['details'] ?? '',
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
          Expanded(child: approvalsWidget),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: auditWidget),
        ],
      );
    }

    return Column(
      children: [
        approvalsWidget,
        const SizedBox(height: AppSpacing.md),
        auditWidget,
      ],
    );
  }

  Widget _buildPortfolioTable(bool isDark) {
    return AppDataTable(
      title: 'Portfolio Health Overview (Top Tier)',
      columns: const [
        AppColumnDef(label: 'Project Name'),
        AppColumnDef(label: 'Lead'),
        AppColumnDef(label: 'Progress'),
        AppColumnDef(label: 'Status'),
      ],
      rows: controller.portfolioProjects.map((p) {
        final double prog = (p['progress'] ?? 0.5) as double;
        final int pct = (prog * 100).toInt();
        return [
          Text(
            p['name'] ?? '',
            style: AppTypography.bodyMd(
              color: isDark ? AppColors.darkOnSurface : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            p['lead'] ?? '',
            style: AppTypography.bodyMd(
              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: LinearProgressIndicator(
                  value: prog,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceContainer,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    prog > 0.7 ? AppColors.success : (prog > 0.4 ? AppColors.warning : AppColors.error),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('$pct%', style: AppTypography.labelSm()),
            ],
          ),
          AppStatusBadge.fromStatus(p['status'] ?? 'On Track'),
        ];
      }).toList(),
    );
  }
}
