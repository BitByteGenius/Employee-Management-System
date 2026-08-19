import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/super_admin/dashboard/controllers/super_admin_dashboard_controller.dart';
import 'package:tms/shared/widgets/app_data_table.dart';
import 'package:tms/shared/widgets/app_stat_card.dart';
import 'package:tms/shared/widgets/app_state_widgets.dart';
import 'package:tms/shared/widgets/app_status_badge.dart';
import 'package:tms/shared/widgets/app_top_bar.dart';

class SuperAdminDashboardView
    extends GetView<SuperAdminDashboardController> {
  const SuperAdminDashboardView({
    super.key,
    this.onMenuPressed,
  });

  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ==========================================================
        // TOP BAR
        // ==========================================================
        Obx(
          () => AppTopBar(
            title: 'Command Center',
            subtitle: 'Super Admin Overview',
            userName: controller.userName.value,
            userRole: 'Super Admin',

            // Only provided on mobile.
            onMenuPressed: onMenuPressed,
          ),
        ),

        // ==========================================================
        // BODY
        // ==========================================================
        Expanded(
          child: Obx(
            () {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      AppLoadingSkeleton(
                        height: 120,
                      ),
                      SizedBox(
                        height: AppSpacing.md,
                      ),
                      AppLoadingSkeleton(
                        height: 240,
                      ),
                    ],
                  ),
                );
              }

              if (controller.hasError.value &&
                  controller.pendingUsers.isEmpty) {
                return AppErrorStateWidget(
                  errorMessage:
                      controller.errorMessage.value,
                  onRetry: () =>
                      controller.fetchDashboardData(),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    controller.fetchDashboardData(),

                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),

                  padding:
                      const EdgeInsets.all(AppSpacing.xl),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      _buildWelcomeHeader(
                        controller.userName.value,
                        isDark,
                      ),

                      const SizedBox(
                        height: AppSpacing.xl,
                      ),

                      _buildKPIGrid(context),

                      const SizedBox(
                        height: AppSpacing.xl,
                      ),

                      _buildAnalyticsSection(
                        context,
                        isDark,
                      ),

                      const SizedBox(
                        height: AppSpacing.xl,
                      ),

                      _buildApprovalsAndAuditRow(
                        context,
                        isDark,
                      ),

                      const SizedBox(
                        height: AppSpacing.xl,
                      ),

                      _buildPortfolioTable(
                        isDark,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================================================================
  // WELCOME HEADER
  // ================================================================

  Widget _buildWelcomeHeader(
    String name,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Good Morning, $name',
          style: AppTypography.headlineLg(
            color: isDark
                ? AppColors.darkOnSurface
                : AppColors.primary,
          ),
        ),
        const SizedBox(
          height: AppSpacing.xs,
        ),
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

  // ================================================================
  // KPI GRID
  // ================================================================

  Widget _buildKPIGrid(
    BuildContext context,
  ) {
    final width =
        MediaQuery.sizeOf(context).width;

    int crossAxisCount = 6;

    if (width < 700) {
      crossAxisCount = 1;
    } else if (width < 1100) {
      crossAxisCount = 3;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,

      childAspectRatio:
          crossAxisCount == 1
              ? 2.8
              : crossAxisCount == 3
                  ? 1.55
                  : 1.15,

      shrinkWrap: true,

      physics:
          const NeverScrollableScrollPhysics(),

      children: [
        AppStatCard(
          title: 'Total Depts',
          value:
              controller.totalDepartments.value
                  .toString(),
          icon: Icons.domain,
          trendText: '1',
          isTrendPositive: true,
        ),

        AppStatCard(
          title: 'Total Admins',
          value:
              controller.totalAdmins.value
                  .toString(),
          icon:
              Icons.admin_panel_settings_outlined,
          trendText: '3',
          isTrendPositive: true,
        ),

        AppStatCard(
          title: 'Employees',
          value:
              controller.totalEmployees.value
                  .toString(),
          icon: Icons.badge_outlined,
          trendText: '12%',
          isTrendPositive: true,
        ),

        AppStatCard(
          title: 'Portfolio Health',
          value:
              '${controller.portfolioHealth.value}% Active',
          icon:
              Icons.monitor_heart_outlined,
          progressValue:
              controller.portfolioHealth.value /
                  100.0,
          progressColor:
              AppColors.success,
        ),

        AppStatCard(
          title: 'Utilization',
          value:
              '${controller.utilization.value}%',
          icon:
              Icons.pie_chart_outline,
          trendText: 'Optimal',
          isTrendPositive: true,
        ),

        AppStatCard(
          title: 'Pending Apprv.',
          value:
              controller
                  .pendingApprovalsCount
                  .value
                  .toString(),
          icon:
              Icons.pending_actions_outlined,
          iconColor:
              AppColors.error,
          leftBorderColor:
              AppColors.error,
          trendText:
              'Action Req.',
          isTrendPositive:
              false,
        ),
      ],
    );
  }

  // ================================================================
  // ANALYTICS
  // ================================================================

  Widget _buildAnalyticsSection(
    BuildContext context,
    bool isDark,
  ) {
    final isDesktop =
        AppBreakpoints.isDesktop(
      MediaQuery.sizeOf(context).width,
    );

    final distributionWidget =
        Container(
      padding:
          const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration:
          BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors
                .surfaceContainerLowest,
        borderRadius:
            AppRadius.borderLg,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(
                  alpha: 0.1,
                )
              : AppColors
                  .outlineVariant
                  .withValues(
                    alpha: 0.5,
                  ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Project Portfolio Distribution',
            style: AppTypography.titleLg(
              color: isDark
                  ? AppColors.darkOnSurface
                  : AppColors.primary,
            ),
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          Center(
            child: Stack(
              alignment:
                  Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child:
                      CircularProgressIndicator(
                    value: 0.85,
                    strokeWidth: 16,
                    backgroundColor:
                        AppColors.warning
                            .withValues(
                      alpha: 0.3,
                    ),
                    valueColor:
                        const AlwaysStoppedAnimation<
                            Color>(
                      AppColors.secondary,
                    ),
                  ),
                ),

                Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Text(
                      '142',
                      style:
                          AppTypography
                              .headlineLg(
                        color: isDark
                            ? AppColors
                                .darkOnSurface
                            : AppColors.primary,
                      ),
                    ),
                    Text(
                      'Active',
                      style:
                          AppTypography
                              .labelSm(
                        color: isDark
                            ? AppColors
                                .darkOnSurfaceVariant
                            : AppColors
                                .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          Wrap(
            alignment:
                WrapAlignment.center,
            spacing:
                AppSpacing.md,
            children: [
              _buildChartLegend(
                AppColors.secondary,
                'In Progress (50%)',
              ),
              _buildChartLegend(
                AppColors.success,
                'Completed (35%)',
              ),
              _buildChartLegend(
                AppColors.warning,
                'On Hold (15%)',
              ),
            ],
          ),
        ],
      ),
    );

    final efficiencyWidget =
        Container(
      padding:
          const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration:
          BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors
                .surfaceContainerLowest,
        borderRadius:
            AppRadius.borderLg,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(
                  alpha: 0.1,
                )
              : AppColors
                  .outlineVariant
                  .withValues(
                    alpha: 0.5,
                  ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Departmental Efficiency Index',
            style: AppTypography.titleLg(
              color: isDark
                  ? AppColors.darkOnSurface
                  : AppColors.primary,
            ),
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          ...controller
              .departmentPerformance
              .map(
            (dept) {
              final double val =
                  (dept['efficiency'] ??
                          0.8)
                      as double;

              final int pct =
                  (val * 100).toInt();

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom:
                      AppSpacing.md,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                          dept[
                                  'department'] ??
                              '',
                          style:
                              AppTypography
                                  .bodyMd(
                            color: isDark
                                ? AppColors
                                    .darkOnSurface
                                : AppColors
                                    .onSurface,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        Text(
                          '$pct%',
                          style:
                              AppTypography
                                  .labelMd(
                            color:
                                AppColors
                                    .secondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    ClipRRect(
                      borderRadius:
                          AppRadius
                              .borderFull,
                      child:
                          LinearProgressIndicator(
                        value: val,
                        minHeight: 8,
                        backgroundColor:
                            isDark
                                ? AppColors
                                    .darkSurfaceContainer
                                : AppColors
                                    .surfaceContainer,
                        valueColor:
                            const AlwaysStoppedAnimation<
                                Color>(
                          AppColors.secondary,
                        ),
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                distributionWidget,
          ),
          const SizedBox(
            width: AppSpacing.md,
          ),
          Expanded(
            child:
                efficiencyWidget,
          ),
        ],
      );
    }

    return Column(
      children: [
        distributionWidget,
        const SizedBox(
          height: AppSpacing.md,
        ),
        efficiencyWidget,
      ],
    );
  }

  Widget _buildChartLegend(
    Color color,
    String text,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(
            color: color,
            shape:
                BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style:
              AppTypography.labelSm(),
        ),
      ],
    );
  }

  // ================================================================
  // APPROVALS + AUDIT
  // ================================================================

  Widget _buildApprovalsAndAuditRow(
    BuildContext context,
    bool isDark,
  ) {
    final isDesktop =
        AppBreakpoints.isDesktop(
      MediaQuery.sizeOf(context).width,
    );

    final approvalsWidget =
        Container(
      decoration:
          BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors
                .surfaceContainerLowest,
        borderRadius:
            AppRadius.borderLg,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(
                  alpha: 0.1,
                )
              : AppColors
                  .outlineVariant
                  .withValues(
                    alpha: 0.5,
                  ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.all(
              AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Text(
                  'Unified Approvals Queue',
                  style:
                      AppTypography
                          .titleLg(
                    color: isDark
                        ? AppColors
                            .darkOnSurface
                        : AppColors
                            .primary,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration:
                      BoxDecoration(
                    color: AppColors
                        .error
                        .withValues(
                      alpha: 0.1,
                    ),
                    borderRadius:
                        AppRadius
                            .borderSm,
                  ),
                  child: Text(
                    '${controller.pendingUsers.length} PENDING',
                    style:
                        AppTypography
                            .labelSm(
                      color:
                          AppColors
                              .error,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          if (controller
              .pendingUsers
              .isEmpty)
            Padding(
              padding:
                  const EdgeInsets.all(
                AppSpacing.xl,
              ),
              child: Center(
                child: Text(
                  'No pending approval requests',
                  style:
                      AppTypography
                          .bodyMd(),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount:
                  controller
                      .pendingUsers
                      .length,
              separatorBuilder:
                  (_, __) =>
                      const Divider(),
              itemBuilder:
                  (context, index) {
                final user =
                    controller
                        .pendingUsers[
                            index];

                return Padding(
                  padding:
                      const EdgeInsets
                          .all(
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            AppColors
                                .primaryContainer,
                        child: Text(
                          user[
                                  'initials'] ??
                              'U',
                          style:
                              AppTypography
                                  .labelMd(
                            color: AppColors
                                .onPrimaryContainer,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width:
                            AppSpacing.md,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              user[
                                      'name'] ??
                                  user[
                                      'fullName'] ??
                                  'User',
                              style:
                                  AppTypography
                                      .bodyMd(
                                color: isDark
                                    ? AppColors
                                        .darkOnSurface
                                    : AppColors
                                        .primary,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                            Text(
                              'Requesting: ${user['role'] ?? 'Access'}',
                              style:
                                  AppTypography
                                      .labelSm(
                                color: isDark
                                    ? AppColors
                                        .darkOnSurfaceVariant
                                    : AppColors
                                        .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          OutlinedButton(
                            onPressed:
                                () => controller
                                    .rejectUser(
                                  user['id'] ??
                                      '',
                                ),
                            child:
                                const Text(
                              'Deny',
                            ),
                          ),
                          const SizedBox(
                            width:
                                AppSpacing.xs,
                          ),
                          ElevatedButton(
                            onPressed:
                                () => controller
                                    .approveUser(
                                  user['id'] ??
                                      '',
                                ),
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  AppColors
                                      .primary,
                              foregroundColor:
                                  Colors.white,
                            ),
                            child:
                                const Text(
                              'Approve',
                            ),
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

    final auditWidget =
        Container(
      padding:
          const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration:
          BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors
                .surfaceContainerLowest,
        borderRadius:
            AppRadius.borderLg,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(
                  alpha: 0.1,
                )
              : AppColors
                  .outlineVariant
                  .withValues(
                    alpha: 0.5,
                  ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              Text(
                'Critical Audit Stream',
                style:
                    AppTypography
                        .titleLg(
                  color: isDark
                      ? AppColors
                          .darkOnSurface
                      : AppColors
                          .primary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style:
                      AppTypography
                          .labelMd(
                    color: AppColors
                        .secondary,
                  ),
                ),
              ),
            ],
          ),

          const Divider(),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          if (controller.auditLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Text(
                  'No recent audit events',
                  style: AppTypography.bodyMd(
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.auditLogs.take(6).length,
              separatorBuilder: (_, __) => const SizedBox(
                height: AppSpacing.md,
              ),
              itemBuilder: (context, index) {
                final item = controller.auditLogs[index];
                final rawAction = (item['title'] ?? item['action'] ?? 'System Event').toString();
                final time = (item['time'] ?? 'Recently').toString();

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(
                      width: AppSpacing.sm + 2,
                    ),
                    Expanded(
                      child: Text(
                        rawAction,
                        style: AppTypography.bodyMd(
                          color: isDark
                              ? AppColors.darkOnSurface
                              : AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      time,
                      style: AppTypography.labelSm(
                        color: isDark
                            ? AppColors.darkOnSurfaceVariant
                            : AppColors.onSurfaceVariant,
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                approvalsWidget,
          ),
          const SizedBox(
            width: AppSpacing.md,
          ),
          Expanded(
            child:
                auditWidget,
          ),
        ],
      );
    }

    return Column(
      children: [
        approvalsWidget,
        const SizedBox(
          height: AppSpacing.md,
        ),
        auditWidget,
      ],
    );
  }

  // ================================================================
  // PORTFOLIO TABLE
  // ================================================================

  Widget _buildPortfolioTable(
    bool isDark,
  ) {
    return AppDataTable(
      title:
          'Portfolio Health Overview (Top Tier)',

      columns: const [
        AppColumnDef(
          label: 'Project Name',
        ),
        AppColumnDef(
          label: 'Lead',
        ),
        AppColumnDef(
          label: 'Progress',
        ),
        AppColumnDef(
          label: 'Status',
        ),
      ],

      rows: controller
          .portfolioProjects
          .map(
        (p) {
          final double prog =
              (p['progress'] ?? 0.5)
                  as double;

          final int pct =
              (prog * 100).toInt();

          return [
            Text(
              p['name'] ?? '',
              style:
                  AppTypography.bodyMd(
                color: isDark
                    ? AppColors
                        .darkOnSurface
                    : AppColors
                        .primary,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            Text(
              p['lead'] ?? '',
              style:
                  AppTypography.bodyMd(
                color: isDark
                    ? AppColors
                        .darkOnSurfaceVariant
                    : AppColors
                        .onSurfaceVariant,
              ),
            ),

            Row(
              children: [
                SizedBox(
                  width: 100,
                  child:
                      LinearProgressIndicator(
                    value: prog,
                    minHeight: 6,
                    backgroundColor:
                        AppColors
                            .surfaceContainer,
                    valueColor:
                        AlwaysStoppedAnimation<
                            Color>(
                      prog > 0.7
                          ? AppColors
                              .success
                          : prog > 0.4
                              ? AppColors
                                  .warning
                              : AppColors
                                  .error,
                    ),
                  ),
                ),

                const SizedBox(
                  width:
                      AppSpacing.sm,
                ),

                Text(
                  '$pct%',
                  style:
                      AppTypography
                          .labelSm(),
                ),
              ],
            ),

            AppStatusBadge.fromStatus(
              p['status'] ??
                  'On Track',
            ),
          ];
        },
      ).toList(),
    );
  }
}