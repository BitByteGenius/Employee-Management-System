import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/api_client.dart';
import '../controllers/notification_controller.dart';
import '../services/notification_service.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_filter_tabs.dart';
import '../widgets/recent_activity_card.dart';

class NotificationListView extends StatefulWidget {
  const NotificationListView({super.key});

  @override
  State<NotificationListView> createState() => _NotificationListViewState();
}

class _NotificationListViewState extends State<NotificationListView> {
  late final NotificationController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<NotificationController>()) {
      controller = Get.find<NotificationController>();
    } else {
      if (!Get.isRegistered<NotificationService>()) {
        Get.put(NotificationService(Get.find<ApiClient>()), permanent: true);
      }
      controller = Get.put(
        NotificationController(Get.find<NotificationService>()),
        permanent: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              controller.fetchNotifications(refresh: true),
              controller.fetchUnreadCount(),
              controller.fetchRecentActivities(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Area matching reference
                _buildHeader(context, isDark),

                const SizedBox(height: AppSpacing.md),

                // Horizontal Divider Line
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE5E7EB),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Category Filter Tabs
                Obx(
                  () => NotificationFilterTabs(
                    selectedCategory: controller.selectedCategory.value,
                    unreadCount: controller.unreadCount.value,
                    onCategorySelected: controller.setCategory,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Responsive Main Content Layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 900;

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Notification Cards
                          Expanded(
                            flex: 65,
                            child: _buildNotificationSection(context, isDark),
                          ),

                          const SizedBox(width: 24),

                          // Right Column: Recent Activity Card
                          SizedBox(
                            width: 320,
                            child: Obx(
                              () => RecentActivityCard(
                                activities: controller.activities,
                                isLoading: controller.isActivitiesLoading.value,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Mobile / Tablet Stacking Layout
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildNotificationSection(context, isDark),
                          const SizedBox(height: 24),
                          Obx(
                            () => RecentActivityCard(
                              activities: controller.activities,
                              isLoading: controller.isActivitiesLoading.value,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: AppTypography.headlineSm(
                  color: isDark ? AppColors.darkOnSurface : const Color(0xFF191C1E),
                ).copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Stay updated with your team's latest activities.",
                style: AppTypography.bodyMd(
                  color: isDark
                      ? AppColors.darkOnSurfaceVariant
                      : const Color(0xFF6B7280),
                ).copyWith(
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Actions: "Mark all as read" & Filter/Tune icon button
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // "Mark all as read" button
            Obx(
              () => InkWell(
                onTap: controller.isMarkingAllRead.value
                    ? null
                    : controller.markAllAsRead,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.isMarkingAllRead.value)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        const Icon(
                          Icons.done_all_rounded,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                      const SizedBox(width: 6),
                      Text(
                        'Mark all as read',
                        style: AppTypography.bodyMd(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ).copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Tune/Filter Icon Button
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFD1D5DB),
                  width: 1,
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.tune,
                  size: 18,
                  color: isDark ? AppColors.darkOnSurface : const Color(0xFF374151),
                ),
                onPressed: () {
                  controller.fetchNotifications(refresh: true);
                },
                tooltip: 'Refresh / Filter',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================================================================
  // NOTIFICATION SECTION
  // ================================================================

  Widget _buildNotificationSection(BuildContext context, bool isDark) {
    return Obx(() {
      // Loading state
      if (controller.isLoading.value) {
        return _buildLoadingShimmer(isDark);
      }

      // Error state
      if (controller.errorMessage.value.isNotEmpty) {
        return _buildErrorState(isDark);
      }

      // Empty state
      if (controller.notifications.isEmpty) {
        return _buildEmptyState(isDark);
      }

      // Notification Cards List
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.notifications.length + (controller.hasMore.value ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == controller.notifications.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: TextButton(
                  onPressed: controller.loadMore,
                  child: controller.isLoadingMore.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Load More Notifications'),
                ),
              ),
            );
          }

          final notification = controller.notifications[index];

          return NotificationCard(
            notification: notification,
            onCardTap: () => controller.markAsRead(notification),
            onActionTap: () => controller.handleNotificationAction(notification),
            onDismissTap: () => controller.dismissNotification(notification),
          );
        },
      );
    });
  }

  // ================================================================
  // LOADING STATE
  // ================================================================

  Widget _buildLoadingShimmer(bool isDark) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262E3D) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 180,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF262E3D) : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2633) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF262E3D) : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // EMPTY STATE
  // ================================================================

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF262E3D) : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: 24,
              color: isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "You're all caught up!",
            style: AppTypography.titleMd(
              color: isDark ? AppColors.darkOnSurface : const Color(0xFF191C1E),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No notifications found in this category.',
            style: AppTypography.bodySm(
              color: isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ERROR STATE
  // ================================================================

  Widget _buildErrorState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 32,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Unable to load notifications',
            style: AppTypography.titleMd(
              color: isDark ? AppColors.darkOnSurface : const Color(0xFF191C1E),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: AppTypography.bodySm(
              color: isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: () => controller.fetchNotifications(refresh: true),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
            ),
          ),
        ],
      ),
    );
  }
}
