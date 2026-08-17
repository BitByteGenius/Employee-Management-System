import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/core/routes/app_pages.dart';

class SuperAdminSidebar extends StatelessWidget {
  const SuperAdminSidebar({
    super.key,
    required this.currentRoute,
    required this.onRouteSelected,
  });

  /// Currently selected route.
  final String currentRoute;

  /// Called whenever a sidebar item is selected.
  final ValueChanged<String> onRouteSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors.surfaceContainerLowest,
        border: Border(
          right: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context, isDark),

          const SizedBox(height: AppSpacing.md),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
              ),
              child: Column(
                children: [
                  _buildSectionTitle(
                    'OVERVIEW',
                    isDark,
                  ),

                  _buildMenuItem(
                    context: context,
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard,
                    title: 'Dashboard',
                    route: AppRoutes.superAdminDashboard,
                    isDark: isDark,
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  _buildSectionTitle(
                    'MANAGEMENT',
                    isDark,
                  ),

                  _buildMenuItem(
                    context: context,
                    icon: Icons.admin_panel_settings_outlined,
                    selectedIcon: Icons.admin_panel_settings,
                    title: 'Access Control',
                    route: AppRoutes.accessControl,
                    isDark: isDark,
                  ),

                  // --------------------------------------------------
                  // Add your future Super Admin routes here.
                  // --------------------------------------------------

                  
                  _buildMenuItem(
                    context: context,
                    icon: Icons.business_outlined,
                    selectedIcon: Icons.business,
                    title: 'Departments',
                    route: AppRoutes.departments,
                    isDark: isDark,
                  ),

                  _buildMenuItem(
  context: context,
  icon: Icons.work_outline,
  selectedIcon: Icons.work,
  title: 'Projects',
  route: AppRoutes.superAdminProject, 
  isDark: isDark,
),

                  _buildMenuItem(
                    context: context,
                    icon: Icons.notifications_none,
                    selectedIcon: Icons.notifications,
                    title: 'Notifications',
                    route: AppRoutes.notifications,
                    isDark: isDark,
                  ),

                  _buildMenuItem(
                    context: context,
                    icon: Icons.assessment_outlined,
                    selectedIcon: Icons.assessment,
                    title: 'Reports',
                    route: AppRoutes.reports,
                    isDark: isDark,
                  ),
                  
                ],
              ),
            ),
          ),

          _buildFooter(context, isDark),
        ],
      ),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadius.borderMd,
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
  'TMS',
  style: AppTypography.titleLg(
    color: isDark
        ? AppColors.darkOnSurface
        : AppColors.primary,
  ).copyWith(
    fontWeight: FontWeight.w800,
  ),
),
                Text(
                  'Super Admin',
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
  }

  // ================================================================
  // SECTION TITLE
  // ================================================================

  Widget _buildSectionTitle(
    String title,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Align(
  alignment: Alignment.centerLeft,
  child: Text(
    title,
    style: AppTypography.labelSm(
      color: isDark
          ? AppColors.darkOnSurfaceVariant
          : AppColors.onSurfaceVariant,
    ).copyWith(
      fontWeight: FontWeight.w700,
    ),
  ),
),
    );
  }

  // ================================================================
  // MENU ITEM
  // ================================================================

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    required String route,
    required bool isDark,
  }) {
    final isSelected = currentRoute == route;

    final backgroundColor = isSelected
        ? AppColors.secondary.withValues(alpha: 0.12)
        : Colors.transparent;

    final foregroundColor = isSelected
        ? AppColors.secondary
        : isDark
            ? AppColors.darkOnSurfaceVariant
            : AppColors.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.borderMd,
          onTap: () => onRouteSelected(route),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: AppRadius.borderMd,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 21,
                  color: foregroundColor,
                ),

                const SizedBox(width: AppSpacing.md),

                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.bodyMd(
                      color: foregroundColor,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),

                if (isSelected)
                  Container(
                    width: 4,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: AppRadius.borderFull,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // FOOTER
  // ================================================================

  Widget _buildFooter(
    BuildContext context,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.logout_outlined,
            size: 20,
            color: AppColors.onPrimaryContainer,
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Get.offAllNamed(AppRoutes.login);
                  },
                  child: Text(
                    'Log Out',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMd(
                      color: isDark
                          ? AppColors.darkOnSurface
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                      
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}