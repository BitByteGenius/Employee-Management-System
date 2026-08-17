import 'package:flutter/material.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';

class AppStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final String? trendText;
  final bool isTrendPositive;
  final double? progressValue; // 0.0 to 1.0
  final Color? progressColor;
  final Color? leftBorderColor;
  final VoidCallback? onTap;

  const AppStatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.iconColor,
    this.trendText,
    this.isTrendPositive = true,
    this.progressValue,
    this.progressColor,
    this.leftBorderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : AppColors.outlineVariant.withValues(alpha: 0.5);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderLg,
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface
                : AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: baseBorderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppRadius.borderLg,
            child: Stack(
              children: [
                // Left accent border strip if provided
                if (leftBorderColor != null)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 4,
                    child: Container(color: leftBorderColor),
                  ),

                // Card Content
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Card Top: Label & Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title.toUpperCase(),
                              style: AppTypography.labelSm(
                                color: isDark
                                    ? AppColors.darkOnSurfaceVariant
                                    : AppColors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (icon != null)
                            Icon(
                              icon,
                              size: AppSizes.iconMd,
                              color: iconColor ?? AppColors.secondary,
                            ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Card Bottom: Large Value & Trend/Progress
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  value,
                                  style: AppTypography.headlineMd(
                                    color: isDark
                                        ? AppColors.darkOnSurface
                                        : AppColors.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),

                              if (trendText != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isTrendPositive
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      size: 14,
                                      color: isTrendPositive
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      trendText!,
                                      style: AppTypography.labelSm(
                                        color: isTrendPositive
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),

                          // Optional Progress Bar
                          if (progressValue != null) ...[
                            const SizedBox(height: AppSpacing.xs + 2),
                            ClipRRect(
                              borderRadius: AppRadius.borderFull,
                              child: LinearProgressIndicator(
                                value: progressValue!.clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: isDark
                                    ? AppColors.darkSurfaceContainer
                                    : AppColors.surfaceContainer,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progressColor ?? AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
