import 'package:flutter/material.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/core/utils/app_date_formatter.dart';
import 'package:tms/modules/super_admin/acces%20controll/controller/access_control_controller.dart';
import 'package:tms/modules/super_admin/acces%20controll/models/access_control_pending_user.dart';
import 'package:tms/modules/super_admin/acces%20controll/view/widget/access_control_dialogs.dart';
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
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AccessControlToolbar(controller: controller),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.outlineVariant,
          ),
          if (controller.isLoading.value)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
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
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.outlineVariant,
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 4,
      ),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 320,
              ),
              child: SizedBox(
                height: 38,
                child: TextField(
                  onChanged: controller.onSearchChanged,
                  style: AppTypography.bodySm(
                    color: isDark
                        ? AppColors.darkOnSurface
                        : AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search pending users...',
                    hintStyle: AppTypography.bodySm(
                      color: isDark
                          ? AppColors.darkOnSurfaceVariant.withValues(alpha: 0.6)
                          : AppColors.onSurfaceVariant,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.onSurfaceVariant,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 8,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : AppColors.outlineVariant,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : AppColors.outlineVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.secondary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Filter + Sort buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filter
              PopupMenuButton<String>(
                tooltip: 'Filter by role',
                onSelected: controller.applyRoleFilter,
                offset: const Offset(0, 42),
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
                  icon: Icons.filter_list_rounded,
                  label: 'Filter',
                ),
              ),
              const SizedBox(width: AppSpacing.xs + 4),
              // Sort
              PopupMenuButton<String>(
                tooltip: 'Sort',
                onSelected: controller.setSort,
                offset: const Offset(0, 42),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'fullName', child: Text('Name')),
                  PopupMenuItem(value: 'createdAt', child: Text('Date')),
                ],
                child: const _ToolbarButton(
                  icon: Icons.sort_rounded,
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
          ? const Color(0xFF131D31)
          : const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _HeadCell('USER', flex: 4),
          _HeadCell('REQUESTED ROLE', flex: 2),
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
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _UserIdentity(user: user),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _RoleBadge(role: user.role),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Text(
                AppDateFormatter.tableDate(user.createdAt),
                style: AppTypography.bodySm(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _AssignmentButton(user: user, controller: controller),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _ActionButtons(user: user, controller: controller),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFF1F5F9),
          ),
        ),
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
                style: AppTypography.bodySm(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
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

  Color _avatarColor() {
    const colors = [
      Color(0xFF2563EB), // Blue
      Color(0xFF16A34A), // Green
      Color(0xFF9333EA), // Purple
      Color(0xFF0D9488), // Teal
      Color(0xFFEA580C), // Orange
      Color(0xFF4F46E5), // Indigo
      Color(0xFF0284C7), // Sky
      Color(0xFF65A30D), // Lime
    ];
    final index = user.fullName.codeUnits.fold(0, (a, b) => a + b) %
        colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarColor = _avatarColor();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: avatarColor,
          child: Text(
            user.initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.fullName,
                style: AppTypography.bodyMd(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkOnSurface
                      : AppColors.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                user.email,
                style: AppTypography.labelSm(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
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

// ============================================================================
// Assignment Button (Assign Department / Assign Role)
// ============================================================================

class _AssignmentButton extends StatelessWidget {
  const _AssignmentButton({required this.user, required this.controller});

  final AccessControlPendingUser user;
  final AccessControlController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = user.isAdmin ? 'Assign Dept' : 'Assign Role';

    return OutlinedButton(
      onPressed: () => user.isAdmin
          ? showDepartmentAssignmentDialog(controller, user)
          : showRoleAssignmentDialog(controller, user),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        minimumSize: const Size(0, 32),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        foregroundColor: isDark
            ? const Color(0xFF93C5FD)
            : const Color(0xFF2563EB),
        side: BorderSide(
          color: isDark
              ? const Color(0xFF3B82F6).withValues(alpha: 0.4)
              : const Color(0xFF93C5FD),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        label,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Deny Button
        OutlinedButton(
          onPressed: () => showApprovalConfirmation(
            controller: controller,
            user: user,
            approve: false,
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            minimumSize: const Size(0, 32),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            foregroundColor: isDark
                ? const Color(0xFFF87171)
                : const Color(0xFFDC2626),
            side: BorderSide(
              color: isDark
                  ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                  : const Color(0xFFFCA5A5),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Deny'),
        ),
        const SizedBox(width: AppSpacing.xs + 2),
        // Approve Button
        ElevatedButton(
          onPressed: () => showApprovalConfirmation(
            controller: controller,
            user: user,
            approve: true,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            minimumSize: const Size(0, 32),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Approve'),
        ),
      ],
    );
  }
}

// ============================================================================
// Role Badge (Dark & Light theme aware)
// ============================================================================

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = role.toLowerCase() == 'admin';

    final Color bgColor;
    final Color textColor;
    final Color borderColor;

    if (isAdmin) {
      bgColor = isDark
          ? const Color(0xFF6366F1).withValues(alpha: 0.15)
          : const Color(0xFFEEF2FF);
      textColor = isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4F46E5);
      borderColor = isDark
          ? const Color(0xFF818CF8).withValues(alpha: 0.3)
          : const Color(0xFFC7D2FE);
    } else {
      bgColor = isDark
          ? const Color(0xFF2563EB).withValues(alpha: 0.15)
          : const Color(0xFFEFF6FF);
      textColor = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8);
      borderColor = isDark
          ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
          : const Color(0xFFBFDBFE);
    }

    final icon = isAdmin
        ? Icons.admin_panel_settings_outlined
        : Icons.person_outline_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            role.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: Text(
          label,
          style: TextStyle(
            color: isDark
                ? const Color(0xFF94A3B8)
                : const Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
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
      height: 38,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 4,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : AppColors.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark
                ? const Color(0xFF94A3B8)
                : const Color(0xFF64748B),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkOnSurface
                  : AppColors.onSurface,
            ),
          ),
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
        vertical: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Showing ${controller.startItem}-${controller.endItem} of ${controller.totalPending.value} pending',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
          IconButton(
            onPressed: controller.currentPage.value > 1
                ? controller.previousPage
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
            iconSize: 20,
            splashRadius: 18,
            color: isDark
                ? AppColors.darkOnSurface
                : AppColors.onSurface,
          ),
          Text(
            '${controller.currentPage.value} / ${controller.totalPages}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkOnSurface
                  : AppColors.onSurface,
            ),
          ),
          IconButton(
            onPressed: controller.currentPage.value < controller.totalPages
                ? controller.nextPage
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
            iconSize: 20,
            splashRadius: 18,
            color: isDark
                ? AppColors.darkOnSurface
                : AppColors.onSurface,
          ),
        ],
      ),
    );
  }
}

