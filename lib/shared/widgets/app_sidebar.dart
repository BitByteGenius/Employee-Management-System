import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/core/services/storage_service.dart';

class AppNavItem {
  final String label;
  final IconData icon;
  final String route;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppNavItem({
    required this.label,
    required this.icon,
    required this.route,
    this.isSelected = false,
    this.onTap,
  });
}

class AppSidebar extends StatelessWidget {
  final String roleTitle;
  final String roleSubtitle;
  final List<AppNavItem> navItems;
  final String currentRoute;
  final VoidCallback? onPrimaryActionTap;
  final String? primaryActionText;
  final IconData? primaryActionIcon;

  const AppSidebar({
    super.key,
    required this.roleTitle,
    required this.roleSubtitle,
    required this.navItems,
    required this.currentRoute,
    this.onPrimaryActionTap,
    this.primaryActionText,
    this.primaryActionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.sidebarWidth,
      height: double.infinity,
      color: AppColors.tertiaryContainer,
      child: Column(
        children: [
          // Header Logo & Role Banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'T',
                      style: AppTypography.headlineMd(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'TeamOrbit',
                        style: AppTypography.titleLg(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        roleSubtitle,
                        style: AppTypography.labelSm(
                          color: AppColors.onTertiaryContainer,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.sm,
              ),
              child: Column(
                children: navItems.map((item) {
                  final selected = item.isSelected || item.route == currentRoute;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: AppRadius.borderMd,
                        onTap: item.onTap ??
                            () {
                              if (item.route.isNotEmpty && item.route != currentRoute) {
                                Get.offNamed(item.route);
                              }
                            },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm + 2,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.secondaryContainer
                                : Colors.transparent,
                            borderRadius: selected
                                ? const BorderRadius.only(
                                    topRight: Radius.circular(AppRadius.lg),
                                    bottomRight: Radius.circular(AppRadius.lg),
                                  )
                                : AppRadius.borderMd,
                            border: selected
                                ? const Border(
                                    left: BorderSide(
                                      color: AppColors.secondary,
                                      width: 4,
                                    ),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: AppSizes.iconMd,
                                color: selected
                                    ? AppColors.onSecondaryContainer
                                    : AppColors.onTertiaryContainer,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: AppTypography.labelMd(
                                    color: selected
                                        ? AppColors.onSecondaryContainer
                                        : AppColors.onTertiaryContainer,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Optional Quick Primary Action Button (e.g. New User for SuperAdmin)
          if (primaryActionText != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onPrimaryActionTap,
                  icon: Icon(
                    primaryActionIcon ?? Icons.add,
                    size: AppSizes.iconSm,
                  ),
                  label: Text(
                    primaryActionText!,
                    style: AppTypography.labelMd(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 4,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderMd,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),

          // Footer Settings & Logout Section
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                _buildFooterItem(
                  icon: Icons.help_outline,
                  label: 'Help Center',
                  onTap: () {
                    Get.snackbar(
                      'Help Center',
                      'Enterprise documentation and support center',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                _buildFooterItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  onTap: () async {
                    final storage = Get.find<StorageService>();
                    await storage.clearSession();
                    Get.offAllNamed(AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.borderMd,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs + 2,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: AppSizes.iconSm + 2,
                color: AppColors.onTertiaryContainer,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: AppTypography.labelMd(
                  color: AppColors.onTertiaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
