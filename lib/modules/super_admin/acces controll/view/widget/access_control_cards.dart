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
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 4),

          // Total count — large
          Text(
            '$total',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: _text(isDark),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Total Pending',
            style: AppTypography.bodySm(color: _muted(isDark)),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Admins row
          _MetricDot(
            label: 'Admins',
            value: admins,
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Employees row
          _MetricDot(
            label: 'Employees',
            value: employees,
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Export button
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Export List'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : AppColors.outlineVariant,
                ),
                foregroundColor: _text(isDark),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: AppSpacing.md,
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
              Icons.info_outline_rounded,
              color: AppColors.secondary,
              size: 16,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assignment Rules',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _text(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Administrators require department assignment prior to approval. '
                  'Employee roles determine their base permissions across assigned projects.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
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
      padding: const EdgeInsets.all(AppSpacing.md + 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF334155),
            ),
          ),
        ),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _text(isDark),
          ),
        ),
      ],
    );
  }
}

Color _text(bool isDark) =>
    isDark ? AppColors.darkOnSurface : AppColors.onSurface;
Color _muted(bool isDark) =>
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
