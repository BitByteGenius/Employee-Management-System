import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/core/theme/theme_controller.dart';
import 'package:tms/modules/profile/views/profile_dialog.dart';
import 'package:tms/shared/widgets/app_user_avatar.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String userName;
  final String userRole;
  final String? userAvatarUrl;
  final List<String>? tabs;
  final int selectedTabIndex;
  final ValueChanged<int>? onTabSelected;
  final VoidCallback? onMenuPressed;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final int unreadNotificationsCount;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    required this.userName,
    required this.userRole,
    this.userAvatarUrl,
    this.tabs,
    this.selectedTabIndex = 0,
    this.onTabSelected,
    this.onMenuPressed,
    this.onSearchChanged,
    this.onNotificationPressed,
    this.onProfilePressed,
    this.unreadNotificationsCount = 2,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.topBarHeight);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = AppBreakpoints.isMobile(screenWidth);
    final showSearch = screenWidth > 850;

    return Container(
      height: AppSizes.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Mobile Hamburger Button
          if (isMobile && onMenuPressed != null) ...[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuPressed,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],

          // Title / Breadcrumb
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleLg(
                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.labelSm(
                      color: isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Optional Navigation Tabs (e.g., Admin Dashboard Overview, Team, Timeline)
          if (!isMobile && tabs != null && tabs!.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(tabs!.length, (index) {
                    final selected = index == selectedTabIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: InkWell(
                        onTap: () => onTabSelected?.call(index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tabs![index].toUpperCase(),
                              style: AppTypography.labelMd(
                                color: selected
                                    ? AppColors.secondary
                                    : (isDark
                                        ? AppColors.darkOnSurfaceVariant
                                        : AppColors.onSurfaceVariant),
                                fontWeight:
                                    selected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 2,
                              width: 24,
                              color: selected ? AppColors.secondary : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],

          const Spacer(),

          // Search Field (Desktop/Tablet)
          if (showSearch) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220, minWidth: 120),
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceContainer
                      : AppColors.surfaceContainerLow,
                  borderRadius: AppRadius.borderFull,
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: TextField(
                  onChanged: onSearchChanged,
                  style: AppTypography.bodyMd(
                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: AppTypography.bodyMd(
                      color: isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.onSurfaceVariant,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: AppSizes.iconMd,
                      color: AppColors.outline,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],

          // Notification Bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: onNotificationPressed ??
                    () {
                      Get.snackbar(
                        'Notifications',
                        'You have $unreadNotificationsCount unread alerts',
                        snackPosition: SnackPosition.TOP,
                      );
                    },
                icon: Icon(
                  Icons.notifications_outlined,
                  color: isDark
                      ? AppColors.darkOnSurface
                      : AppColors.onSurfaceVariant,
                ),
              ),
              if (unreadNotificationsCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: AppSpacing.xs),

          // Theme Switcher
          Obx(() {
            final isDarkModeActive = themeController.themeMode.value == ThemeMode.dark ||
                (themeController.themeMode.value == ThemeMode.system && Get.isPlatformDarkMode);
            return IconButton(
              tooltip: 'Toggle Light/Dark Theme',
              onPressed: () {
                themeController.changeTheme(
                  isDarkModeActive ? ThemeMode.light : ThemeMode.dark,
                );
              },
              icon: Icon(
                isDarkModeActive ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: isDark
                    ? AppColors.darkOnSurface
                    : AppColors.onSurfaceVariant,
              ),
            );
          }),

          const SizedBox(width: AppSpacing.xs),

          // Profile Avatar & Role Info (Clickable to open Profile Dialog)
          InkWell(
            onTap: onProfilePressed ?? () => ProfileDialog.show(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppUserAvatar(
                    imageUrl: userAvatarUrl,
                    name: userName,
                    radius: 16,
                  ),
                  if (!isMobile && screenWidth > 600) ...[
                    const SizedBox(width: AppSpacing.xs),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: AppTypography.bodyMd(
                              color: isDark
                                  ? AppColors.darkOnSurface
                                  : AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            userRole,
                            style: AppTypography.labelSm(
                              color: AppColors.secondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
