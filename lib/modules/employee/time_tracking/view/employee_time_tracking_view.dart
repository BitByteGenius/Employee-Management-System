import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/modules/employee/time_tracking/view/widget/log_time_dialog.dart';
import 'package:tms/shared/widgets/app_data_table.dart';
import 'package:tms/shared/widgets/app_stat_card.dart';
import 'package:tms/shared/widgets/app_state_widgets.dart';
import 'package:tms/shared/widgets/app_status_badge.dart';

class EmployeeTimeTrackingView extends StatefulWidget {
  const EmployeeTimeTrackingView({super.key});

  @override
  State<EmployeeTimeTrackingView> createState() => _EmployeeTimeTrackingViewState();
}

class _EmployeeTimeTrackingViewState extends State<EmployeeTimeTrackingView> {
  final isLoading = false.obs;
  final timeLogs = <Map<String, dynamic>>[].obs;
  final loggedToday = '0.0 hrs'.obs;
  final weeklyTotal = '0.0 hrs'.obs;
  final totalEntries = '0'.obs;
  final averageDaily = '0.0 hrs'.obs;
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
          totalEntries.value = list.length.toString();
          averageDaily.value = (metrics['averagePerMember'] ?? '0.0 hrs').toString();
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load time tracking: $e';
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
              // Header & Log Time Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time Tracking & Attendance',
                        style: AppTypography.headlineLg(
                          color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                        ).copyWith(fontWeight: FontWeight.w800, fontSize: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your daily work hours, project tasks, and attendance history.',
                        style: AppTypography.bodyLg(
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                    ),
                    onPressed: () {
                      Get.dialog(LogTimeDialog(onTimeLogged: fetchTimeLogs));
                    },
                    icon: const Icon(Icons.add_alarm_rounded, size: 18),
                    label: const Text('Log Hours'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // KPI Stats
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
                      title: 'Logged Entries',
                      value: totalEntries.value,
                      icon: Icons.receipt_long_outlined,
                      isTrendPositive: true,
                    ),
                    AppStatCard(
                      title: 'Daily Average',
                      value: averageDaily.value,
                      icon: Icons.speed_outlined,
                      isTrendPositive: true,
                    ),
                  ],
                );
              }),

              const SizedBox(height: AppSpacing.xl),

              // Time Logs Table
              AppDataTable(
                title: 'My Time Entries (${timeLogs.length})',
                columns: const [
                  AppColumnDef(label: 'Date'),
                  AppColumnDef(label: 'Task / Activity'),
                  AppColumnDef(label: 'Duration'),
                  AppColumnDef(label: 'Notes'),
                  AppColumnDef(label: 'Status', alignment: Alignment.center),
                ],
                rows: timeLogs.map((log) {
                  final date = (log['date'] ?? 'Today').toString();
                  final task = (log['task'] ?? 'General Activity').toString();
                  final hours = (log['hours'] ?? '0.0 hrs').toString();
                  final notes = (log['notes'] ?? '—').toString();
                  final status = (log['status'] ?? 'Approved').toString();

                  return [
                    Text(date, style: AppTypography.bodyMd(fontWeight: FontWeight.w600)),
                    Text(task, style: AppTypography.bodyMd(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                    Text(hours, style: AppTypography.bodyMd(fontWeight: FontWeight.w700, color: AppColors.secondary)),
                    Text(notes, style: AppTypography.bodyMd(color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis),
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
