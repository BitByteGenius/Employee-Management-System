import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/shared/widgets/app_data_table.dart';
import 'package:tms/shared/widgets/app_stat_card.dart';
import 'package:tms/shared/widgets/app_state_widgets.dart';
import 'package:tms/shared/widgets/app_status_badge.dart';
import 'package:tms/shared/widgets/app_user_avatar.dart';

class AdminTimeTrackingView extends StatefulWidget {
  const AdminTimeTrackingView({super.key});

  @override
  State<AdminTimeTrackingView> createState() => _AdminTimeTrackingViewState();
}

class _AdminTimeTrackingViewState extends State<AdminTimeTrackingView> {
  final isLoading = false.obs;
  final timeLogs = <Map<String, dynamic>>[].obs;
  final loggedToday = '0.0 hrs'.obs;
  final weeklyTotal = '0.0 hrs'.obs;
  final activeTimers = '0'.obs;
  final averagePerMember = '0.0 hrs'.obs;
  final errorMessage = ''.obs;

  @override
  void initState() {
    super.initState();
    fetchTimeLogs();
  }

  Future<void> fetchTimeLogs() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (Get.isRegistered<ApiClient>()) {
        final api = Get.find<ApiClient>();
        final res = await api.dio.get(ApiEndpoints.timeTracking);
        if (res.data != null && res.data['success'] == true) {
          final List list = res.data['data'] ?? [];
          timeLogs.assignAll(list.cast<Map<String, dynamic>>());

          final metrics = res.data['metrics'] ?? {};
          loggedToday.value = (metrics['loggedToday'] ?? '0.0 hrs').toString();
          weeklyTotal.value = (metrics['weeklyTotal'] ?? '0.0 hrs').toString();
          activeTimers.value = (metrics['activeTimers'] ?? '0').toString();
          averagePerMember.value = (metrics['averagePerMember'] ?? '0.0 hrs').toString();
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load time tracking data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (isLoading.value && timeLogs.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              AppLoadingSkeleton(height: 80),
              SizedBox(height: AppSpacing.lg),
              AppLoadingSkeleton(height: 300),
            ],
          ),
        );
      }

      if (errorMessage.isNotEmpty && timeLogs.isEmpty) {
        return AppErrorStateWidget(
          errorMessage: errorMessage.value,
          onRetry: fetchTimeLogs,
        );
      }

      return RefreshIndicator(
        onRefresh: fetchTimeLogs,
        child: SingleChildScrollView(
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
                'Monitor team hours, attendance logs, and billable activity stored in MongoDB.',
                style: AppTypography.bodyLg(
                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // KPI Cards from MongoDB Aggregation
              LayoutBuilder(builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 650;
                return GridView.count(
                  crossAxisCount: isNarrow ? 2 : 4,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: isNarrow ? 1.8 : 1.5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    AppStatCard(
                      title: 'Logged Today',
                      value: loggedToday.value,
                      icon: Icons.timer_outlined,
                      isTrendPositive: true,
                    ),
                    AppStatCard(
                      title: 'Weekly Total',
                      value: weeklyTotal.value,
                      icon: Icons.date_range_outlined,
                      isTrendPositive: true,
                    ),
                    AppStatCard(
                      title: 'Active Members',
                      value: activeTimers.value,
                      icon: Icons.people_outline,
                      isTrendPositive: true,
                    ),
                    AppStatCard(
                      title: 'Average / Member',
                      value: averagePerMember.value,
                      icon: Icons.speed_outlined,
                      isTrendPositive: true,
                    ),
                  ],
                );
              }),

              const SizedBox(height: AppSpacing.xl),

              // Real Time Logs Table from MongoDB
              AppDataTable(
                title: 'Department Time Entries (${timeLogs.length})',
                columns: const [
                  AppColumnDef(label: 'Member'),
                  AppColumnDef(label: 'Task / Project'),
                  AppColumnDef(label: 'Date'),
                  AppColumnDef(label: 'Duration'),
                  AppColumnDef(label: 'Status', alignment: Alignment.center),
                ],
                rows: timeLogs.map((log) {
                  final name = (log['name'] ?? 'Member').toString();
                  final task = (log['task'] ?? 'General Activity').toString();
                  final date = (log['date'] ?? 'Today').toString();
                  final hours = (log['hours'] ?? '0.0 hrs').toString();
                  final status = (log['status'] ?? 'Approved').toString();

                  return [
                    Row(
                      children: [
                        AppUserAvatar(
                          imageUrl: (log['avatar'] ?? log['profilePicture'])?.toString(),
                          name: name,
                          radius: 13,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            name,
                            style: AppTypography.bodyMd(
                              color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(task, style: AppTypography.bodyMd(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                    Text(date, style: AppTypography.labelMd(color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant)),
                    Text(hours, style: AppTypography.bodyMd(fontWeight: FontWeight.w700, color: AppColors.secondary)),
                    AppStatusBadge.fromStatus(status),
                  ];
                }).toList(),
              ),
            ],
          ),
        ),
      );
    });
  }
}
