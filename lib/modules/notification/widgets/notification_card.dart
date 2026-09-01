import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onCardTap;
  final VoidCallback? onActionTap;
  final VoidCallback? onDismissTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onCardTap,
    this.onActionTap,
    this.onDismissTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = !notification.isRead;

    // Determine icon and colors based on category/type
    final isSystem = notification.isSystem;
    final isTeam = notification.isTeam;

    final Color iconBg = isSystem
        ? (isDark ? const Color(0xFF3A1C1C) : const Color(0xFFFEF2F2))
        : (isTeam
            ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF))
            : (isDark ? const Color(0xFF262E3D) : const Color(0xFFF3F4F6)));

    final Color iconColor = isSystem
        ? const Color(0xFFEF4444)
        : (isTeam
            ? const Color(0xFF2563EB)
            : (isDark ? AppColors.darkOnSurface : const Color(0xFF374151)));

    final IconData iconData = isSystem
        ? Icons.warning_amber_rounded
        : (isTeam ? Icons.people_outline : Icons.assignment_outlined);

    return InkWell(
      onTap: onCardTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isUnread
                ? (isDark
                    ? AppColors.secondary.withValues(alpha: 0.5)
                    : const Color(0xFF93C5FD).withValues(alpha: 0.8))
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE5E7EB)),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Blue vertical bar on left edge if unread
              if (isUnread)
                Container(
                  width: 4,
                  color: AppColors.secondary,
                ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon container
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          iconData,
                          size: 20,
                          color: iconColor,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Text and action column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header: Title + relative time + unread dot
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: AppTypography.titleMd(
                                      color: isDark
                                          ? AppColors.darkOnSurface
                                          : AppColors.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ).copyWith(
                                      fontSize: 15,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isUnread) ...[
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  notification.relativeTime,
                                  style: AppTypography.bodySm(
                                    color: isDark
                                        ? AppColors.darkOnSurfaceVariant
                                        : const Color(0xFF6B7280),
                                  ).copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // Description message
                            Text(
                              notification.message,
                              style: AppTypography.bodyMd(
                                color: isDark
                                    ? AppColors.darkOnSurfaceVariant
                                    : const Color(0xFF4B5563),
                              ).copyWith(
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),

                            // Action buttons (if any)
                            if (_hasActions()) ...[
                              const SizedBox(height: 12),
                              _buildActionButtons(context, isDark),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasActions() {
    return notification.actionType != 'none' ||
        notification.isProject ||
        notification.isSystem ||
        onDismissTap != null;
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    final actionType = notification.actionType;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        // Primary action button (e.g. View Task)
        if (actionType == 'view_task' || notification.isProject) ...[
          InkWell(
            onTap: onActionTap,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'View Task',
                style: AppTypography.labelMd(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ).copyWith(
                  fontSize: 12,
                ),
              ),
            ),
          ),
          if (onDismissTap != null)
            InkWell(
              onTap: onDismissTap,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : const Color(0xFFD1D5DB),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Dismiss',
                  style: AppTypography.labelMd(
                    color: isDark
                        ? AppColors.darkOnSurface
                        : const Color(0xFF374151),
                    fontWeight: FontWeight.w500,
                  ).copyWith(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ] else if (actionType == 'more_info' || notification.isSystem) ...[
          InkWell(
            onTap: onActionTap,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : const Color(0xFFD1D5DB),
                  width: 1,
                ),
              ),
              child: Text(
                'More Info',
                style: AppTypography.labelMd(
                  color: isDark
                      ? AppColors.darkOnSurface
                      : const Color(0xFF374151),
                  fontWeight: FontWeight.w500,
                ).copyWith(
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ] else if (onDismissTap != null) ...[
          InkWell(
            onTap: onDismissTap,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : const Color(0xFFD1D5DB),
                  width: 1,
                ),
              ),
              child: Text(
                'Dismiss',
                style: AppTypography.labelMd(
                  color: isDark
                      ? AppColors.darkOnSurface
                      : const Color(0xFF374151),
                  fontWeight: FontWeight.w500,
                ).copyWith(
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
