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

class AdminWorkforceView extends StatefulWidget {
  const AdminWorkforceView({super.key});

  @override
  State<AdminWorkforceView> createState() => _AdminWorkforceViewState();
}

class _AdminWorkforceViewState extends State<AdminWorkforceView> {
  final isLoading = false.obs;
  final employees = <Map<String, dynamic>>[].obs;
  final searchFilter = ''.obs;
  final errorMessage = ''.obs;

  @override
  void initState() {
    super.initState();
    fetchWorkforce();
  }

  Future<void> fetchWorkforce() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (Get.isRegistered<ApiClient>()) {
        final api = Get.find<ApiClient>();
        final res = await api.dio.get(ApiEndpoints.users);
        if (res.data != null && res.data['success'] == true) {
          final List list = res.data['data'] ?? [];
          employees.assignAll(list.cast<Map<String, dynamic>>());
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load workforce: $e';
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filteredEmployees {
    if (searchFilter.value.trim().isEmpty) return employees;
    final query = searchFilter.value.trim().toLowerCase();
    return employees.where((e) {
      final name = (e['fullName'] ?? e['name'] ?? '').toString().toLowerCase();
      final email = (e['email'] ?? '').toString().toLowerCase();
      final code = (e['employeeCode'] ?? '').toString().toLowerCase();
      final role = (e['assignedRoleLabel'] ?? e['designation'] ?? e['role'] ?? '').toString().toLowerCase();
      return name.contains(query) || email.contains(query) || code.contains(query) || role.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (isLoading.value && employees.isEmpty) {
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

      if (errorMessage.isNotEmpty && employees.isEmpty) {
        return AppErrorStateWidget(
          errorMessage: errorMessage.value,
          onRetry: fetchWorkforce,
        );
      }

      final list = filteredEmployees;
      final activeCount = employees.where((e) => e['isActive'] == true || e['status'] == 'approved').length;

      return RefreshIndicator(
        onRefresh: fetchWorkforce,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workforce Management',
                        style: AppTypography.headlineLg(
                          color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                        ).copyWith(fontWeight: FontWeight.w800, fontSize: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage department personnel, designations, and activity.',
                        style: AppTypography.bodyLg(
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // KPI Summary
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
                      title: 'Total Personnel',
                      value: employees.length.toString(),
                      icon: Icons.people_alt_outlined,
                      isTrendPositive: true,
                    ),
                    AppStatCard(
                      title: 'Active Members',
                      value: activeCount.toString(),
                      icon: Icons.check_circle_outline,
                      isTrendPositive: true,
                    ),
                    AppStatCard(
                      title: 'Pending Approvals',
                      value: employees.where((e) => e['status'] == 'pending').length.toString(),
                      icon: Icons.hourglass_empty,
                      isTrendPositive: false,
                    ),
                    const AppStatCard(
                      title: 'Department Coverage',
                      value: '100%',
                      icon: Icons.shield_outlined,
                      isTrendPositive: true,
                    ),
                  ],
                );
              }),

              const SizedBox(height: AppSpacing.xl),

              // Search Box
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLowest,
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 20, color: AppColors.outline),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => searchFilter.value = v,
                        decoration: const InputDecoration(
                          hintText: 'Search members by name, code, email, or role...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Employees Table
              AppDataTable(
                title: 'Department Members (${list.length})',
                columns: const [
                  AppColumnDef(label: 'Code', width: 90),
                  AppColumnDef(label: 'Name'),
                  AppColumnDef(label: 'Email'),
                  AppColumnDef(label: 'Role / Designation'),
                  AppColumnDef(label: 'Status', alignment: Alignment.center),
                ],
                rows: list.map((emp) {
                  final name = (emp['fullName'] ?? emp['name'] ?? 'User').toString();
                  final code = (emp['employeeCode'] ?? '—').toString();
                  final email = (emp['email'] ?? '—').toString();
                  final role = (emp['assignedRoleLabel'] ?? emp['designation'] ?? emp['role'] ?? 'Member').toString();
                  final status = (emp['status'] ?? (emp['isActive'] == true ? 'Active' : 'Pending')).toString();

                  return [
                    Text(code, style: AppTypography.labelMd(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        AppUserAvatar(
                          imageUrl: (emp['profilePicture'] ?? emp['avatar'])?.toString(),
                          name: name,
                          radius: 13,
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
                    Text(email, style: AppTypography.bodyMd(color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                    Text(role, style: AppTypography.bodyMd(fontWeight: FontWeight.w500)),
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
