import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/core/utils/app_date_formatter.dart';
import 'package:tms/modules/super_admin/acces%20controll/controller/access_control_controller.dart';
import 'package:tms/modules/super_admin/acces%20controll/models/access_control_pending_user.dart';
import 'package:tms/modules/super_admin/acces%20controll/view/widget/access_control_cards.dart';
import 'package:tms/modules/super_admin/acces%20controll/view/widget/pending_approval_table.dart';
import 'package:tms/shared/widgets/app_state_widgets.dart';
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
      return _DeleteUsersTable(
        controller: controller,
        isDark: isDark,
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

class _DeleteUsersTable extends StatelessWidget {
  const _DeleteUsersTable({
    required this.controller,
    required this.isDark,
  });

  final AccessControlController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Users & Admins',
                    style: AppTypography.titleLg(),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: () => controller.fetchDeleteUsers(refresh: true),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (controller.isDeleteLoading.value)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: AppLoadingSkeleton(height: 220),
            )
          else if (controller.deleteErrorMessage.value.isNotEmpty)
            AppErrorStateWidget(
              errorMessage: controller.deleteErrorMessage.value,
              onRetry: controller.fetchDeleteUsers,
            )
          else if (controller.deleteUsers.isEmpty)
            const AppEmptyStateWidget(
              title: 'No users or admins found',
              description: 'Employee and admin accounts will appear here.',
              icon: Icons.delete_outline,
            )
          else
            Column(
              children: controller.deleteUsers
                  .map(
                    (user) => _DeleteUserRow(
                      user: user,
                      controller: controller,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _DeleteUserRow extends StatelessWidget {
  const _DeleteUserRow({
    required this.user,
    required this.controller,
  });

  final AccessControlPendingUser user;
  final AccessControlController controller;

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.surfaceVariant,
          ),
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DeleteUserIdentity(user: user),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _DeleteRoleBadge(role: user.role),
                    Text(
                      AppDateFormatter.tableDate(user.createdAt),
                      style: AppTypography.bodyMd(),
                    ),
                    _DeleteButton(user: user, controller: controller),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _DeleteUserIdentity(user: user),
                ),
                Expanded(
                  flex: 2,
                  child: _DeleteRoleBadge(role: user.role),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    AppDateFormatter.tableDate(user.createdAt),
                    style: AppTypography.bodyMd(),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _DeleteButton(user: user, controller: controller),
                ),
              ],
            ),
    );
  }
}

class _DeleteUserIdentity extends StatelessWidget {
  const _DeleteUserIdentity({required this.user});

  final AccessControlPendingUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.error,
          child: Text(
            user.initials,
            style: AppTypography.labelMd(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: AppTypography.bodyMd(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                user.email,
                style: AppTypography.labelSm(
                  color: AppColors.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeleteRoleBadge extends StatelessWidget {
  const _DeleteRoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 3,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.borderSm,
        ),
        child: Text(
          role.toUpperCase(),
          style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({
    required this.user,
    required this.controller,
  });

  final AccessControlPendingUser user;
  final AccessControlController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => OutlinedButton.icon(
        onPressed: controller.isActionLoading.value
            ? null
            : () => controller.deleteUser(user),
        icon: const Icon(Icons.delete_outline, size: AppSizes.iconSm),
        label: const Text('Delete'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
        ),
      ),
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
