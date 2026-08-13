import 'package:flutter/material.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';

// ============================================================================
// Queue Summary Card
// ============================================================================

class QueueSummaryCard extends StatelessWidget {
  const QueueSummaryCard({
    super.key,
    required this.total,
    required this.admins,
    required this.employees,
    required this.onExport,
  });

  final int total;
  final int admins;
  final int employees;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _AccessCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            'QUEUE SUMMARY',
            style: AppTypography.labelSm(color: _muted(isDark)),
          ),
          const SizedBox(height: AppSpacing.md),

          // Total count — large
          Text(
            '$total',
            style: AppTypography.headlineLg(color: _text(isDark)),
          ),
          Text(
            'Total Pending',
            style: AppTypography.bodyMd(color: _muted(isDark)),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Admins row
          _MetricDot(
            label: 'Admins',
            value: admins,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Employees row
          _MetricDot(
            label: 'Employees',
            value: employees,
            color: AppColors.outlineVariant,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Export button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.download_outlined, size: AppSizes.iconSm),
              label: const Text('Export List'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.outlineVariant),
                foregroundColor: _text(isDark),
                textStyle: AppTypography.labelMd(fontWeight: FontWeight.w600),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Assignment Rules Card
// ============================================================================

class AssignmentRulesCard extends StatelessWidget {
  const AssignmentRulesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _AccessCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info icon in blue circle
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppColors.secondary,
              size: AppSizes.iconSm,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assignment Rules',
                  style: AppTypography.bodyMd(
                    color: _text(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Administrators require department assignment prior to approval. '
                  'Employee roles determine their base permissions across assigned projects.',
                  style: AppTypography.bodyMd(color: AppColors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Shared Card Container
// ============================================================================

class _AccessCard extends StatelessWidget {
  const _AccessCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.outlineVariant,
        ),
      ),
      child: child,
    );
  }
}

// ============================================================================
// Metric Dot Row
// ============================================================================

class _MetricDot extends StatelessWidget {
  const _MetricDot({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMd(color: _text(isDark)),
          ),
        ),
        Text(
          '$value',
          style: AppTypography.bodyMd(
            color: _text(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

Color _text(bool isDark) =>
    isDark ? AppColors.darkOnSurface : AppColors.onSurface;
Color _muted(bool isDark) =>
    isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant;
