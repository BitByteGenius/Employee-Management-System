import 'package:flutter/material.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';

enum AppStatusType {
  onTrack,
  delayed,
  atRisk,
  pending,
  completed,
  inProgress,
  toDo,
  review,
  high,
  medium,
  low,
  approved,
  denied,
  active,
  inactive,
}

class AppStatusBadge extends StatelessWidget {
  final String label;
  final AppStatusType type;
  final bool showDot;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.showDot = true,
  });

  factory AppStatusBadge.fromStatus(String status) {
    final lower = status.toLowerCase().trim();
    if (lower.contains('on track') || lower.contains('completed') || lower == 'approved' || lower == 'active') {
      return AppStatusBadge(label: status, type: AppStatusType.onTrack);
    } else if (lower.contains('delayed') || lower == 'high' || lower == 'denied' || lower == 'rejected') {
      return AppStatusBadge(label: status, type: AppStatusType.delayed);
    } else if (lower.contains('risk') || lower.contains('hold') || lower == 'medium') {
      return AppStatusBadge(label: status, type: AppStatusType.atRisk);
    } else if (lower.contains('progress') || lower == 'review') {
      return AppStatusBadge(label: status, type: AppStatusType.inProgress);
    } else if (lower == 'pending' || lower == 'to do' || lower == 'low') {
      return AppStatusBadge(label: status, type: AppStatusType.pending);
    }
    return AppStatusBadge(label: status, type: AppStatusType.pending);
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case AppStatusType.onTrack:
      case AppStatusType.completed:
      case AppStatusType.approved:
      case AppStatusType.active:
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        break;

      case AppStatusType.delayed:
      case AppStatusType.high:
      case AppStatusType.denied:
      case AppStatusType.inactive:
        bg = AppColors.error.withValues(alpha: 0.12);
        fg = AppColors.error;
        break;

      case AppStatusType.atRisk:
      case AppStatusType.medium:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = const Color(0xFFB45309);
        break;

      case AppStatusType.inProgress:
      case AppStatusType.review:
        bg = AppColors.secondary.withValues(alpha: 0.12);
        fg = AppColors.secondary;
        break;

      case AppStatusType.pending:
      case AppStatusType.toDo:
      case AppStatusType.low:
        bg = AppColors.surfaceContainerHighest;
        fg = AppColors.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs + 2),
          ],
          Text(
            label,
            style: AppTypography.labelSm(
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
