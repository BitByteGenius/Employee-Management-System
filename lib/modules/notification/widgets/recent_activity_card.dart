import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_user_avatar.dart';
import '../models/activity_model.dart';

class RecentActivityCard extends StatelessWidget {
  final List<ActivityModel> activities;
  final bool isLoading;

  const RecentActivityCard({
    super.key,
    required this.activities,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.show_chart_rounded,
                size: 18,
                color: isDark ? AppColors.darkOnSurface : const Color(0xFF191C1E),
              ),
              const SizedBox(width: 8),
              Text(
                'Recent Activity',
                style: AppTypography.titleMd(
                  color: isDark ? AppColors.darkOnSurface : const Color(0xFF191C1E),
                  fontWeight: FontWeight.w600,
                ).copyWith(
                  fontSize: 14,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Content
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  'No recent activity',
                  style: AppTypography.bodySm(
                    color: isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF6B7280),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final activity = activities[index];
                final isLast = index == activities.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Avatar column
                    Column(
                      children: [
                        AppUserAvatar(
                          imageUrl: activity.actorAvatar,
                          name: activity.actorName,
                          radius: 12,
                          backgroundColor: isDark
                              ? const Color(0xFF2D3748)
                              : const Color(0xFFE5E7EB),
                          textColor: isDark ? AppColors.darkOnSurface : const Color(0xFF4B5563),
                          fontSize: 9,
                        ),
                        if (!isLast)
                          Container(
                            width: 1.5,
                            height: 20,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE5E7EB),
                          ),
                      ],
                    ),

                    const SizedBox(width: 10),

                    // Activity details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: AppTypography.bodyMd(
                              color: isDark ? AppColors.darkOnSurface : const Color(0xFF191C1E),
                              fontWeight: FontWeight.w500,
                            ).copyWith(
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activity.time,
                            style: AppTypography.bodySm(
                              color: isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF6B7280),
                            ).copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
