import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class NotificationFilterTabs extends StatelessWidget {
  final String selectedCategory;
  final int unreadCount;
  final ValueChanged<String> onCategorySelected;

  const NotificationFilterTabs({
    super.key,
    required this.selectedCategory,
    required this.unreadCount,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tabs = [
      {'key': 'all', 'label': 'All'},
      {'key': 'unread', 'label': 'Unread', 'badge': unreadCount},
      {'key': 'projects', 'label': 'Projects'},
      {'key': 'system', 'label': 'System'},
      {'key': 'team', 'label': 'Team'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final key = tab['key'] as String;
          final label = tab['label'] as String;
          final badge = tab['badge'] as int?;
          final isSelected = selectedCategory == key;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => onCategorySelected(key),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? AppColors.darkSurface : Colors.transparent),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : const Color(0xFFD1D5DB)),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTypography.bodyMd(
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? AppColors.darkOnSurface : const Color(0xFF374151)),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ).copyWith(
                        fontSize: 13,
                      ),
                    ),
                    if (badge != null && badge > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151))
                              : (isDark ? const Color(0xFF262E3D) : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge.toString(),
                          style: AppTypography.labelSm(
                            color: isSelected
                                ? (isDark ? Colors.black : Colors.white)
                                : (isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF4B5563)),
                            fontWeight: FontWeight.w600,
                          ).copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
