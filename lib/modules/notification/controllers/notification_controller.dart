import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/routes/app_pages.dart';
import '../models/activity_model.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _service;

  NotificationController(this._service);

  // Observable state
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxList<ActivityModel> activities = <ActivityModel>[].obs;
  final RxInt unreadCount = 0.obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isActivitiesLoading = false.obs;
  final RxBool isMarkingAllRead = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString selectedCategory = 'all'.obs; // 'all', 'unread', 'projects', 'system', 'team'
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMore = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      fetchNotifications(refresh: true),
      fetchUnreadCount(),
      fetchRecentActivities(),
    ]);
  }

  /// Change filter category tab
  void setCategory(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    fetchNotifications(refresh: true);
  }

  /// Search filter
  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchNotifications(refresh: true);
  }

  /// Fetch notifications with optional pull-to-refresh
  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      isLoading.value = true;
      errorMessage.value = '';
    }

    try {
      final categoryFilter = selectedCategory.value == 'all'
          ? null
          : (selectedCategory.value == 'unread' ? null : selectedCategory.value);

      final isReadFilter = selectedCategory.value == 'unread' ? false : null;

      final result = await _service.fetchNotifications(
        page: currentPage.value,
        limit: 20,
        category: categoryFilter,
        isRead: isReadFilter,
        search: searchQuery.value,
      );

      if (refresh) {
        notifications.assignAll(result.notifications);
      } else {
        notifications.addAll(result.notifications);
      }

      unreadCount.value = result.unreadCount;
      totalPages.value = result.totalPages;
      hasMore.value = currentPage.value < totalPages.value;
      errorMessage.value = '';
    } catch (e) {
      if (refresh) {
        errorMessage.value = e.toString().replaceAll('Exception: ', '');
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load next page for infinite scrolling
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) return;

    isLoadingMore.value = true;
    currentPage.value += 1;
    await fetchNotifications(refresh: false);
  }

  /// Fetch live unread count
  Future<void> fetchUnreadCount() async {
    try {
      final count = await _service.fetchUnreadCount();
      unreadCount.value = count;
    } catch (_) {}
  }

  /// Fetch Recent Activities stream
  Future<void> fetchRecentActivities() async {
    isActivitiesLoading.value = true;
    try {
      final list = await _service.fetchRecentActivities(limit: 10);
      activities.assignAll(list);
    } catch (_) {
    } finally {
      isActivitiesLoading.value = false;
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    // Optimistic UI update
    final index = notifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      notifications[index] = notification.copyWith(isRead: true, readAt: DateTime.now());
      if (unreadCount.value > 0) {
        unreadCount.value -= 1;
      }
    }

    try {
      await _service.markAsRead(notification.id);
    } catch (_) {
      // Revert if failed
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (unreadCount.value == 0 && notifications.every((n) => n.isRead)) return;

    isMarkingAllRead.value = true;

    // Optimistic update
    final updated = notifications.map((n) => n.copyWith(isRead: true, readAt: DateTime.now())).toList();
    notifications.assignAll(updated);
    unreadCount.value = 0;

    try {
      final success = await _service.markAllAsRead();
      if (!success) {
        // Refresh to sync state
        await fetchNotifications(refresh: true);
      }
    } catch (_) {
      await fetchNotifications(refresh: true);
    } finally {
      isMarkingAllRead.value = false;
    }
  }

  /// Dismiss / Delete a notification
  Future<void> dismissNotification(NotificationModel notification) async {
    // Optimistic removal
    final wasUnread = !notification.isRead;
    notifications.removeWhere((n) => n.id == notification.id);
    if (wasUnread && unreadCount.value > 0) {
      unreadCount.value -= 1;
    }

    try {
      await _service.dismissNotification(notification.id);
    } catch (_) {
      // If error, reload
      await fetchNotifications(refresh: true);
    }
  }

  /// Handle Action Button click (e.g. "View Task", "More Info", "View Project")
  void handleNotificationAction(NotificationModel notification) {
    markAsRead(notification);

    if (notification.actionType == 'view_task' || notification.entityType == 'Task') {
      _showTaskOrNavigate(notification);
    } else if (notification.actionType == 'view_project' || notification.entityType == 'Project') {
      _showProjectOrNavigate(notification);
    } else {
      _showMoreInfoDialog(notification);
    }
  }

  void _showTaskOrNavigate(NotificationModel notification) {
    // Open info dialog or navigate
    _showMoreInfoDialog(
      notification,
      customTitle: 'Task Details',
      actionButtonLabel: 'Open Tasks Screen',
      onAction: () {
        Get.back();
        // If user can navigate to tasks
        if (Get.currentRoute != AppRoutes.tasks && Get.currentRoute != AppRoutes.employeeTasks) {
          Get.toNamed(AppRoutes.tasks);
        }
      },
    );
  }

  void _showProjectOrNavigate(NotificationModel notification) {
    _showMoreInfoDialog(
      notification,
      customTitle: 'Project Details',
      actionButtonLabel: 'Open Projects',
      onAction: () {
        Get.back();
        if (Get.currentRoute != AppRoutes.adminProject && Get.currentRoute != AppRoutes.superAdminProject) {
          Get.toNamed(AppRoutes.adminProject);
        }
      },
    );
  }

  void _showMoreInfoDialog(
    NotificationModel notification, {
    String? customTitle,
    String? actionButtonLabel,
    VoidCallback? onAction,
  }) {
    final isDark = Get.isDarkMode;

    Get.dialog(
      Dialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: notification.isSystem
                            ? const Color(0xFFFEF2F2)
                            : (notification.isTeam ? const Color(0xFFEFF6FF) : const Color(0xFFF3F4F6)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        notification.isSystem
                            ? Icons.warning_amber_rounded
                            : (notification.isTeam ? Icons.people_outline : Icons.assignment_outlined),
                        size: 20,
                        color: notification.isSystem
                            ? const Color(0xFFEF4444)
                            : (notification.isTeam ? AppColors.secondary : AppColors.onSurface),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customTitle ?? notification.title,
                            style: AppTypography.titleMd(
                              color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            notification.relativeTime,
                            style: AppTypography.labelSm(
                              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Divider(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  notification.message,
                  style: AppTypography.bodyMd(
                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                  ).copyWith(height: 1.5),
                ),
                if (notification.metadata != null && notification.metadata!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: notification.metadata!.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '${e.key}: ${e.value}',
                            style: AppTypography.labelSm(
                              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Close',
                        style: AppTypography.bodyMd(
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (onAction != null && actionButtonLabel != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      ElevatedButton(
                        onPressed: onAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
                        ),
                        child: Text(actionButtonLabel),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
