import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/modules/admin/my%20project/models/admin_project_model.dart';
import 'package:tms/modules/admin/my%20project/view/widget/admin_deliverables_dialog.dart';
import 'package:tms/shared/widgets/app_state_widgets.dart';

class EmployeeProjectsView extends StatefulWidget {
  const EmployeeProjectsView({super.key});

  @override
  State<EmployeeProjectsView> createState() => _EmployeeProjectsViewState();
}

class _EmployeeProjectsViewState extends State<EmployeeProjectsView> {
  final isLoading = false.obs;
  final projects = <AdminProjectModel>[].obs;
  final searchFilter = ''.obs;
  final errorMessage = ''.obs;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (Get.isRegistered<ApiClient>()) {
        final api = Get.find<ApiClient>();
        final res = await api.dio.get(ApiEndpoints.projects);
        if (res.data != null && res.data['success'] == true) {
          final List list = res.data['data'] ?? [];
          projects.assignAll(list.map((item) => AdminProjectModel.fromJson(Map<String, dynamic>.from(item))).toList());
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load projects: $e';
    } finally {
      isLoading.value = false;
    }
  }

  List<AdminProjectModel> get filteredProjects {
    if (searchFilter.value.trim().isEmpty) return projects;
    final q = searchFilter.value.trim().toLowerCase();
    return projects.where((p) => p.name.toLowerCase().contains(q) || p.key.toLowerCase().contains(q) || (p.managerName ?? '').toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (isLoading.value && projects.isEmpty) {
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

      if (errorMessage.isNotEmpty && projects.isEmpty) {
        return AppErrorStateWidget(
          errorMessage: errorMessage.value,
          onRetry: fetchProjects,
        );
      }

      final list = filteredProjects;

      return RefreshIndicator(
        onRefresh: fetchProjects,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'My Assigned Projects',
                style: AppTypography.headlineLg(
                  color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                ).copyWith(fontWeight: FontWeight.w800, fontSize: 28),
              ),
              const SizedBox(height: 4),
              Text(
                'Initiatives, project milestones, and deliverables where you are an active contributor.',
                style: AppTypography.bodyLg(
                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Search Box
              Container(
                height: 42,
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
                    const Icon(Icons.search, size: 18, color: AppColors.outline),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => searchFilter.value = v,
                        decoration: const InputDecoration(
                          hintText: 'Search projects by name or key...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Projects Grid
              if (list.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLowest,
                    borderRadius: AppRadius.borderLg,
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.account_tree_outlined, size: 48, color: AppColors.secondary),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No Projects Found',
                        style: AppTypography.titleLg(
                          color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Projects assigned to your department will appear here.',
                        style: AppTypography.bodyMd(color: AppColors.outline),
                      ),
                    ],
                  ),
                )
              else
                LayoutBuilder(builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 750;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isNarrow ? 1 : 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: isNarrow ? 2.0 : 1.85,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final project = list[index];
                      return Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
                          borderRadius: AppRadius.borderLg,
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.outlineVariant.withValues(alpha: 0.45),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: project.statusBadgeBgColor(isDark),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    project.statusLabel,
                                    style: AppTypography.labelSm(color: project.statusBadgeTextColor).copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                if (project.hasAttachedFiles || project.hasNotes)
                                  InkWell(
                                    onTap: () => Get.dialog(AdminDeliverablesDialog(project: project)),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.attach_file, size: 14, color: AppColors.secondary),
                                        const SizedBox(width: 2),
                                        Text('Files', style: AppTypography.labelSm(color: AppColors.secondary).copyWith(fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              project.name,
                              style: AppTypography.titleLg(
                                color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                              ).copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Lead: ${project.managerName ?? 'Department Admin'} • Deadline: ${project.formattedDeadline}',
                              style: AppTypography.bodyMd(color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Progress', style: AppTypography.labelSm(fontWeight: FontWeight.w600)),
                                    Text(project.formattedProgress, style: AppTypography.labelSm(fontWeight: FontWeight.w700, color: project.progressColor)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: AppRadius.borderFull,
                                  child: LinearProgressIndicator(
                                    value: project.progressFraction,
                                    minHeight: 6,
                                    backgroundColor: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainer,
                                    valueColor: AlwaysStoppedAnimation<Color>(project.progressColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
            ],
          ),
        ),
      );
    });
  }
}
