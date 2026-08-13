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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface
                : AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.borderLg,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.outlineVariant.withOpacity(0.5),
              ),
              right: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.outlineVariant.withOpacity(0.5),
              ),
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.outlineVariant.withOpacity(0.5),
              ),
              left: leftBorderColor != null
                  ? BorderSide(color: leftBorderColor!, width: 4)
                  : BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : AppColors.outlineVariant.withOpacity(0.5),
                    ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
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
                      Text(
                        value,
                        style: AppTypography.headlineMd(
                          color: isDark
                              ? AppColors.darkOnSurface
                              : AppColors.primary,
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
      ),
    );
  }
}
