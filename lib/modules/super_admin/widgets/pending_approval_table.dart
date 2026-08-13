import 'package:flutter/material.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/core/utils/app_date_formatter.dart';
import 'package:tms/modules/super_admin/controllers/access_control_controller.dart';
import 'package:tms/modules/super_admin/models/access_control_pending_user.dart';
import 'package:tms/modules/super_admin/widgets/access_control_dialogs.dart';
import 'package:tms/shared/widgets/app_state_widgets.dart';

// ============================================================================
// Main Table Widget
// ============================================================================

class PendingApprovalTable extends StatelessWidget {
  const PendingApprovalTable({super.key, required this.controller});

  final AccessControlController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          AccessControlToolbar(controller: controller),
          const Divider(height: 1),
          if (controller.isLoading.value)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: AppLoadingSkeleton(height: 260),
            )
          else if (controller.errorMessage.value.isNotEmpty)
            AppErrorStateWidget(
              errorMessage: controller.errorMessage.value,
              onRetry: controller.fetchPendingUsers,
            )
          else if (controller.pendingUsers.isEmpty)
            AppEmptyStateWidget(
              title: controller.searchQuery.value.isEmpty
                  ? 'No pending approvals'
                  : 'No matching users',
              description: controller.searchQuery.value.isEmpty
                  ? 'New registration requests will appear here.'
                  : 'Try adjusting your search or filters.',
              icon: Icons.verified_user_outlined,
            )
          else
            _ResponsiveRows(controller: controller),
          const Divider(height: 1),
          _Pagination(controller: controller),
        ],
      ),
    );
  }
}

// ============================================================================
// Toolbar (Search, Filter, Sort)
// ============================================================================

class AccessControlToolbar extends StatelessWidget {
  const AccessControlToolbar({super.key, required this.controller});

  final AccessControlController controller;

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search field
          SizedBox(
            width: isMobile ? double.infinity : 280,
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search pending users...',
                prefixIcon: Icon(Icons.search, size: AppSizes.iconSm),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.borderSm,
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.borderSm,
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
              ),
            ),
          ),

          // Filter + Sort buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filter
              PopupMenuButton<String>(
                tooltip: 'Filter by role',
                onSelected: controller.applyRoleFilter,
                offset: const Offset(0, 36),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: '', child: Text('All Roles')),
                  ...controller.roles.map((role) {
                    final name =
                        (role['name'] ?? role['label'] ?? '').toString();
                    return PopupMenuItem(
                      value: name,
                      child: Text(name.isEmpty ? 'Role' : name),
                    );
                  }),
                ],
                child: const _ToolbarButton(
                  icon: Icons.filter_list,
                  label: 'Filter',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Sort
              PopupMenuButton<String>(
                tooltip: 'Sort',
                onSelected: controller.setSort,
                offset: const Offset(0, 36),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'fullName', child: Text('Name')),
                  PopupMenuItem(value: 'createdAt', child: Text('Date')),
                ],
                child: const _ToolbarButton(
                  icon: Icons.sort,
                  label: 'Sort',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Responsive Rows
// ============================================================================

class _ResponsiveRows extends StatelessWidget {
  const _ResponsiveRows({required this.controller});

  final AccessControlController controller;

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);
    if (isMobile) {
      return Column(
        children: controller.pendingUsers
            .map((u) => _MobileUserCard(user: u, controller: controller))
            .toList(),
      );
    }

    return Column(
      children: [
        const _TableHeader(),
        ...controller.pendingUsers
            .map((u) => PendingUserRow(user: u, controller: controller)),
      ],
    );
  }

}

// ============================================================================
// Table Header
// ============================================================================

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark
          ? AppColors.darkSurfaceContainer
          : AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: const Row(
        children: [
          _HeadCell('USER', flex: 4),
          _HeadCell('REQUESTED\nROLE', flex: 2),
          _HeadCell('DATE', flex: 2),
          _HeadCell('ASSIGNMENT', flex: 2),
          _HeadCell('ACTIONS', flex: 3),
        ],
      ),
    );
  }
}

// ============================================================================
// Desktop Row
// ============================================================================

class PendingUserRow extends StatelessWidget {
  const PendingUserRow({
    super.key,
    required this.user,
    required this.controller,
  });

  final AccessControlPendingUser user;
  final AccessControlController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.surfaceVariant,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 4, child: _UserIdentity(user: user)),
          Expanded(flex: 2, child: _RoleBadge(role: user.role)),
          Expanded(
            flex: 2,
            child: Text(
              AppDateFormatter.tableDate(user.createdAt),
              style: AppTypography.bodyMd(),
            ),
          ),
          Expanded(
            flex: 2,
            child: _AssignmentButton(user: user, controller: controller),
          ),
          Expanded(
            flex: 3,
            child: _ActionButtons(user: user, controller: controller),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Mobile Card
// ============================================================================

class _MobileUserCard extends StatelessWidget {
  const _MobileUserCard({required this.user, required this.controller});

  final AccessControlPendingUser user;
  final AccessControlController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserIdentity(user: user),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _RoleBadge(role: user.role),
              Text(
                AppDateFormatter.tableDate(user.createdAt),
                style: AppTypography.bodyMd(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _AssignmentButton(user: user, controller: controller),
              _ActionButtons(user: user, controller: controller),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// User Identity (avatar + name + email)
// ============================================================================

class _UserIdentity extends StatelessWidget {
  const _UserIdentity({required this.user});

  final AccessControlPendingUser user;

  // Deterministic avatar color from user name
  Color _avatarColor() {
    const colors = [
      Color(0xFF1565C0), // deep blue
      Color(0xFF2E7D32), // deep green
      Color(0xFF6A1B9A), // deep purple
      Color(0xFF00695C), // teal
      Color(0xFFC62828), // deep red
      Color(0xFF4527A0), // indigo
      Color(0xFF00838F), // cyan
      Color(0xFF558B2F), // olive
    ];
    final index = user.fullName.codeUnits.fold(0, (a, b) => a + b) %
        colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _avatarColor();
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: avatarColor,
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
                style:
                    AppTypography.bodyMd(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                user.email,
                style: AppTypography.labelSm(
                    color: AppColors.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Assignment Button (Assign Department / Assign Role)
// ============================================================================

class _AssignmentButton extends StatelessWidget {
  const _AssignmentButton({required this.user, required this.controller});

  final AccessControlPendingUser user;
  final AccessControlController controller;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => user.isAdmin
          ? showDepartmentAssignmentDialog(controller, user)
          : showRoleAssignmentDialog(controller, user),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        textStyle: AppTypography.labelMd(fontWeight: FontWeight.w600),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Text(
        user.isAdmin ? 'Assign Dept' : 'Assign Role',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ============================================================================
// Action Buttons (Deny + Approve)
// ============================================================================

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.user, required this.controller});

  final AccessControlPendingUser user;
  final AccessControlController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        // Deny always shown
        OutlinedButton(
          onPressed: () => showApprovalConfirmation(
            controller: controller,
            user: user,
            approve: false,
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            textStyle: AppTypography.labelMd(fontWeight: FontWeight.w600),
            side: const BorderSide(color: AppColors.outlineVariant),
          ),
          child: const Text('Deny'),
        ),
        // Approve
        ElevatedButton(
          onPressed: () => showApprovalConfirmation(
            controller: controller,
            user: user,
            approve: true,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            textStyle: AppTypography.labelMd(fontWeight: FontWeight.w600),
            elevation: 0,
          ),
          child: const Text('Approve'),
        ),
      ],
    );
  }
}

// ============================================================================
// Role Badge
// ============================================================================

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role.toLowerCase() == 'admin';
    final bgColor = isAdmin
        ? AppColors.primaryContainer   // dark navy for admin
        : const Color(0xFFE8F0FE);    // light blue-grey for employee
    final textColor = isAdmin
        ? const Color(0xFF7C839B)      // muted on dark navy
        : AppColors.secondary;        // blue on light
    final icon = isAdmin
        ? Icons.admin_panel_settings_outlined
        : Icons.person_outline;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 3),
          Text(
            role.toUpperCase(),
            style: AppTypography.labelSm(color: textColor),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Table Header Cell
// ============================================================================

class _HeadCell extends StatelessWidget {
  const _HeadCell(this.label, {required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) => Expanded(
        flex: flex,
        child: Text(
          label,
          style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
        ),
      );
}

// ============================================================================
// Toolbar Button
// ============================================================================

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: AppRadius.borderSm,
        color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSm, color: AppColors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.labelMd()),
        ],
      ),
    );
  }
}

// ============================================================================
// Pagination Row
// ============================================================================

class _Pagination extends StatelessWidget {
  const _Pagination({required this.controller});

  final AccessControlController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Showing ${controller.startItem}-${controller.endItem} of ${controller.totalPending.value} pending',
              style: AppTypography.labelSm(
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
          IconButton(
            onPressed: controller.currentPage.value > 1
                ? controller.previousPage
                : null,
            icon: const Icon(Icons.chevron_left),
            iconSize: AppSizes.iconMd,
            splashRadius: 18,
          ),
          Text(
            '${controller.currentPage.value} / ${controller.totalPages}',
            style: AppTypography.labelSm(),
          ),
          IconButton(
            onPressed: controller.currentPage.value < controller.totalPages
                ? controller.nextPage
                : null,
            icon: const Icon(Icons.chevron_right),
            iconSize: AppSizes.iconMd,
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}
