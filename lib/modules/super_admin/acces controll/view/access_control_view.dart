import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/super_admin/acces%20controll/controller/access_control_controller.dart';
import 'package:tms/modules/super_admin/acces%20controll/view/widget/access_control_cards.dart';
import 'package:tms/modules/super_admin/acces%20controll/view/widget/pending_approval_table.dart';
import 'package:tms/shared/widgets/app_top_bar.dart';

class AccessControlView
    extends GetView<AccessControlController> {
  const AccessControlView({
    super.key,
    this.onMenuPressed,
  });

  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Column(
      children: [
        // ==========================================================
        // TOP BAR
        // ==========================================================
        AppTopBar(
          title: 'Access Control',
          subtitle:
              'User Approvals & Assignments',
          userName: 'Super Admin',
          userRole: 'Super Admin',
          onMenuPressed:
              onMenuPressed,
        ),

        // ==========================================================
        // BODY
        // ==========================================================
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                controller.fetchPendingUsers(
              refresh: true,
            ),

            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),

              padding:
                  const EdgeInsets.all(
                AppSpacing.xl,
              ),

              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth:
                        AppSizes
                            .maxContentWidth,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      // ==================================================
                      // BREADCRUMB
                      // ==================================================
                      Text(
                        '> Access Control',
                        style:
                            AppTypography
                                .labelSm(
                          color:
                              _muted(
                            isDark,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height:
                            AppSpacing.sm,
                      ),

                      // ==================================================
                      // TITLE
                      // ==================================================
                      Text(
                        'User Approvals & Assignments',
                        style:
                            AppTypography
                                .headlineMd(
                          color:
                              _text(
                            isDark,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height:
                            AppSpacing.xs,
                      ),

                      ConstrainedBox(
                        constraints:
                            const BoxConstraints(
                          maxWidth: 760,
                        ),
                        child: Text(
                          'Review and authorize pending registrations, assign departments to administrators, and define roles for employees.',
                          style:
                              AppTypography
                                  .bodyMd(
                            color:
                                AppColors
                                    .secondary,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height:
                            AppSpacing.xl,
                      ),

                      // ==================================================
                      // TABS
                      // ==================================================
                      _Tabs(
                        controller:
                            controller,
                      ),

                      const SizedBox(
                        height:
                            AppSpacing.xl,
                      ),

                      // ==================================================
                      // CONTENT
                      // ==================================================
                      _ContentLayout(
                        controller:
                            controller,
                        isDark:
                            isDark,
                      ),
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
}

// ============================================================================
// CONTENT LAYOUT
// ============================================================================

class _ContentLayout
    extends StatelessWidget {
  const _ContentLayout({
    required this.controller,
    required this.isDark,
  });

  final AccessControlController controller;
  final bool isDark;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Obx(
      () => _buildContent(
        context,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
  ) {
    // ==============================================================
    // DELETE TAB
    // ==============================================================

    if (controller.selectedTab.value ==
        1) {
      return Container(
        width: double.infinity,

        padding:
            const EdgeInsets.all(
          AppSpacing.xl,
        ),

        decoration:
            BoxDecoration(
          color: isDark
              ? AppColors.darkSurface
              : AppColors
                  .surfaceContainerLowest,

          borderRadius:
              AppRadius.borderMd,

          border: Border.all(
            color:
                AppColors
                    .outlineVariant,
          ),
        ),

        child: Column(
          children: [
            const Icon(
              Icons.delete_outline,
              color:
                  AppColors.outline,
              size:
                  AppSizes.iconXl,
            ),

            const SizedBox(
              height:
                  AppSpacing.md,
            ),

            Text(
              'No deleted registrations',
              style:
                  AppTypography
                      .titleLg(),
            ),

            const SizedBox(
              height:
                  AppSpacing.xs,
            ),

            Text(
              'Rejected or removed user requests will be managed through existing user administration tools.',
              style:
                  AppTypography
                      .bodyMd(
                color:
                    AppColors
                        .onSurfaceVariant,
              ),
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      );
    }

    // ==============================================================
    // PENDING APPROVALS
    // ==============================================================

    final isDesktop =
        AppBreakpoints.isDesktop(
      MediaQuery.sizeOf(context)
          .width,
    );

    final table =
        PendingApprovalTable(
      controller: controller,
    );

    final side =
        Column(
      children: [
        QueueSummaryCard(
          total:
              controller
                  .totalPending
                  .value,
          admins:
              controller
                  .adminPendingCount,
          employees:
              controller
                  .employeePendingCount,
          onExport:
              controller
                  .exportCurrentList,
        ),

        const SizedBox(
          height:
              AppSpacing.md,
        ),

        const AssignmentRulesCard(),
      ],
    );

    // ==============================================================
    // MOBILE
    // ==============================================================

    if (!isDesktop) {
      return Column(
        children: [
          table,

          const SizedBox(
            height:
                AppSpacing.md,
          ),

          side,
        ],
      );
    }

    // ==============================================================
    // DESKTOP
    // ==============================================================

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment
              .start,

      children: [
        Expanded(
          child: table,
        ),

        const SizedBox(
          width:
              AppSpacing.lg,
        ),

        SizedBox(
          width: 280,
          child: side,
        ),
      ],
    );
  }
}

// ============================================================================
// TABS
// ============================================================================

class _Tabs
    extends StatelessWidget {
  const _Tabs({
    required this.controller,
  });

  final AccessControlController controller;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Obx(
      () {
        final selected =
            controller
                .selectedTab
                .value;

        final total =
            controller
                .totalPending
                .value;

        return Container(
          decoration:
              const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    AppColors
                        .outlineVariant,
              ),
            ),
          ),

          child: Row(
            children: [
              _TabButton(
                label:
                    'Pending Approvals',
                count:
                    total,
                selected:
                    selected == 0,
                onTap: () {
                  controller
                      .selectedTab
                      .value = 0;
                },
              ),

              const SizedBox(
                width:
                    AppSpacing.lg,
              ),

              _TabButton(
                label:
                    'Delete',
                selected:
                    selected == 1,
                onTap: () {
                  controller
                      .selectedTab
                      .value = 1;
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// TAB BUTTON
// ============================================================================

class _TabButton
    extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    const activeColor =
        AppColors.secondary;

    final inactiveColor =
        isDark
            ? AppColors
                .darkOnSurfaceVariant
            : AppColors
                .onSurfaceVariant;

    return InkWell(
      onTap: onTap,

      borderRadius:
          AppRadius.borderSm,

      child: Container(
        padding:
            const EdgeInsets.only(
          bottom:
              AppSpacing.sm,
        ),

        decoration:
            BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected
                  ? activeColor
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),

        child: Row(
          children: [
            Text(
              label,
              style:
                  AppTypography
                      .labelMd(
                color: selected
                    ? activeColor
                    : inactiveColor,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            if (count != null &&
                count! > 0) ...[
              const SizedBox(
                width:
                    AppSpacing.xs,
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 6,
                  vertical: 1,
                ),

                decoration:
                    const BoxDecoration(
                  color:
                      AppColors.secondary,
                  borderRadius:
                      AppRadius
                          .borderFull,
                ),

                child: Text(
                  '$count',
                  style:
                      AppTypography
                          .labelSm(
                    color:
                        Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// COLORS
// ============================================================================

Color _text(bool isDark) =>
    isDark
        ? AppColors.darkOnSurface
        : AppColors.onSurface;

Color _muted(bool isDark) =>
    isDark
        ? AppColors.darkOnSurfaceVariant
        : AppColors.onSurfaceVariant;
