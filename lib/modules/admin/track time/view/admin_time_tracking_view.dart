import 'package:flutter/material.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/shared/widgets/app_data_table.dart';
import 'package:tms/shared/widgets/app_stat_card.dart';
import 'package:tms/shared/widgets/app_status_badge.dart';

class AdminTimeTrackingView extends StatelessWidget {
  const AdminTimeTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final mockLogs = [
      {'name': 'Alex Johnson', 'role': 'Lead Engineer', 'task': 'TMS Auth Module API', 'hours': '7.5 hrs', 'status': 'Approved', 'date': 'Today'},
      {'name': 'Sarah Connor', 'role': 'UI Designer', 'task': 'Admin Dashboard Design System', 'hours': '6.0 hrs', 'status': 'Approved', 'date': 'Today'},
      {'name': 'Michael Chang', 'role': 'Backend Developer', 'task': 'Database Index Optimization', 'hours': '8.0 hrs', 'status': 'Pending', 'date': 'Today'},
      {'name': 'Emily Davis', 'role': 'QA Tester', 'task': 'Super Admin Regression Tests', 'hours': '5.5 hrs', 'status': 'Approved', 'date': 'Yesterday'},
      {'name': 'David Miller', 'role': 'DevOps Specialist', 'task': 'CI/CD Pipeline Setup', 'hours': '7.0 hrs', 'status': 'Approved', 'date': 'Yesterday'},
    ];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Time Tracking & Attendance',
            style: AppTypography.headlineLg(
              color: isDark ? AppColors.darkOnSurface : AppColors.primary,
            ).copyWith(fontWeight: FontWeight.w800, fontSize: 28),
          ),
          const SizedBox(height: 4),
          Text(
            'Monitor team hours, attendance logs, and billable activity.',
            style: AppTypography.bodyLg(
              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // KPI Cards
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 650;
            return GridView.count(
              crossAxisCount: isNarrow ? 2 : 4,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: isNarrow ? 1.8 : 1.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                AppStatCard(
                  title: 'Logged Today',
                  value: '34.0 hrs',
                  icon: Icons.timer_outlined,
                  isTrendPositive: true,
                ),
                AppStatCard(
                  title: 'Weekly Total',
                  value: '168.5 hrs',
                  icon: Icons.date_range_outlined,
                  isTrendPositive: true,
                ),
                AppStatCard(
                  title: 'Active Timers',
                  value: '4',
                  icon: Icons.play_circle_outline,
                  isTrendPositive: true,
                ),
                AppStatCard(
                  title: 'Average / Member',
                  value: '7.2 hrs',
                  icon: Icons.speed_outlined,
                  isTrendPositive: true,
                ),
              ],
            );
          }),

          const SizedBox(height: AppSpacing.xl),

          // Time Logs Table
          AppDataTable(
            title: 'Recent Time Entries',
            columns: const [
              AppColumnDef(label: 'Member'),
              AppColumnDef(label: 'Task / Project'),
              AppColumnDef(label: 'Date'),
              AppColumnDef(label: 'Duration'),
              AppColumnDef(label: 'Status', alignment: Alignment.center),
            ],
            rows: mockLogs.map((log) {
              final name = log['name']!;
              return [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(name[0], style: AppTypography.labelSm(color: AppColors.onPrimaryContainer)),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        name,
                        style: AppTypography.bodyMd(color: isDark ? AppColors.darkOnSurface : AppColors.primary, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(log['task']!, style: AppTypography.bodyMd(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                Text(log['date']!, style: AppTypography.labelMd(color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant)),
                Text(log['hours']!, style: AppTypography.bodyMd(fontWeight: FontWeight.w700, color: AppColors.secondary)),
                AppStatusBadge.fromStatus(log['status']!),
              ];
            }).toList(),
          ),
        ],
      ),
    );
  }
}
