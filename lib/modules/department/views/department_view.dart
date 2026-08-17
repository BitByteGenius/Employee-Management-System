import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/department/controllers/department_controller.dart';
import 'package:tms/modules/department/views/widget/CreateDepartmentDialog.dart';
import 'package:tms/shared/widgets/app_top_bar.dart';

class DepartmentView extends GetView<DepartmentController> {
  const DepartmentView({
    super.key,
    this.onMenuPressed,
  });

  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ==========================================================
        // TOP BAR
        // ==========================================================
        AppTopBar(
          title: 'Departments',
          subtitle: 'Organizational Units',
          userName: 'Admin User',
          userRole: 'Administrator',
          onMenuPressed: onMenuPressed,
        ),

        // ==========================================================
        // BODY
        // ==========================================================
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              // Trigger your controller's refresh logic here
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // BREADCRUMB
                      // ==================================================
                      Text(
                        '> Department Management',
                        style: AppTypography.labelSm(
                          color: isDark ? AppColors.outline : AppColors.outlineVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // ==================================================
                      // TITLE & ACTIONS
                      // ==================================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Department Management',
                                  style: AppTypography.headlineMd(
                                    color: isDark ? AppColors.onBackground : AppColors.onBackground,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 760),
                                  child: Text(
                                    'Create, manage, and oversee organizational units and their leadership.',
                                    style: AppTypography.bodyMd(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.outlineVariant),
                                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                                ),
                                icon: const Icon(Icons.download, size: AppSizes.iconSm, color: AppColors.onSurface),
                                label: Text('Export', style: AppTypography.bodyMd(color: AppColors.onSurface)),
                                onPressed: () {},
                              ),
                              const SizedBox(width: AppSpacing.md),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                                ),
                                icon: const Icon(Icons.add, size: AppSizes.iconSm, color: AppColors.onSecondary),
                                label: Text('Create Department', style: AppTypography.bodyMd(color: AppColors.onSecondary)),
                                onPressed: () => Get.dialog( CreateDepartmentDialog()),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ==================================================
                      // CONTENT
                      // ==================================================
                      _ContentLayout(
                        controller: controller,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContentLayout extends StatelessWidget {
  final DepartmentController controller;
  final bool isDark;

  const _ContentLayout({
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================================
        // LEFT SIDE: Filters & Departments List
        // ==========================================================
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Essential for SingleChildScrollView wrap
              children: [
                // Filters row
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      _buildDropdownFilter('All Statuses', Icons.filter_list),
                      const SizedBox(width: AppSpacing.md),
                      _buildDropdownFilter('Sort by Name', Icons.sort),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.outlineVariant),

                // Showing count header
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Obx(() => Text(
                        'Showing ${controller.departments.length} Departments',
                        style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
                      )),
                ),

                // Table Column headers
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  color: AppColors.surfaceContainerLow,
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text('DEPARTMENT NAME', style: AppTypography.labelSm(color: AppColors.outline))),
                      Expanded(flex: 2, child: Text('DEPARTMENT ADMIN', style: AppTypography.labelSm(color: AppColors.outline))),
                      Text('EMPLOYEES', style: AppTypography.labelSm(color: AppColors.outline)),
                    ],
                  ),
                ),

                // Departments List
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true, // Replaced Expanded with shrinkWrap
                    physics: const NeverScrollableScrollPhysics(), // Important for SingleChildScrollView
                    itemCount: controller.departments.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.outlineVariant),
                    itemBuilder: (context, index) {
                      final dept = controller.departments[index];
                      return Obx(() {
                        final isSelected = controller.selectedDepartment.value?.id == dept.id;
                        return InkWell(
                          onTap: () => controller.selectDepartment(dept),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            color: isSelected ? AppColors.surfaceContainerLow : Colors.transparent,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(AppSpacing.xs),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryContainer,
                                          borderRadius: AppRadius.borderSm,
                                        ),
                                        child: const Icon(Icons.code, size: AppSizes.iconSm, color: AppColors.onPrimaryContainer),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(dept.name, style: AppTypography.titleLg(color: AppColors.onSurface)),
                                          Text(dept.code, style: AppTypography.labelSm(color: AppColors.outline)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: dept.admin != null
                                      ? Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 12,
                                              backgroundImage: dept.admin?.profilePicture != null
                                                  ? NetworkImage(dept.admin!.profilePicture!)
                                                  : const NetworkImage('https://i.pravatar.cc/150?img=32'),
                                            ),
                                            const SizedBox(width: AppSpacing.xs),
                                            Text(dept.admin!.name, style: AppTypography.bodyMd(color: AppColors.onSurface)),
                                          ],
                                        )
                                      : Text('Assign Admin', style: AppTypography.bodyMd(color: AppColors.secondary)),
                                ),
                                Text(dept.headcount.toString(), style: AppTypography.bodyMd(color: AppColors.onSurface)),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),

        // ==========================================================
        // RIGHT SIDE: Department Details & Directory View
        // ==========================================================
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Obx(() {
              final selected = controller.selectedDepartment.value;
              if (selected == null) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Text('Select a department to view details', style: AppTypography.bodyMd(color: AppColors.outline)),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Essential for SingleChildScrollView wrap
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: AppRadius.borderSm,
                          ),
                          child: const Icon(Icons.code, size: AppSizes.iconLg, color: AppColors.onPrimaryContainer),
                        ),
                        Row(
                          children: [
                            IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(selected.name, style: AppTypography.headlineMd(color: AppColors.onSurface)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      selected.description.isNotEmpty
                          ? selected.description
                          : 'Core product development and technical infrastructure.',
                      style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('HEADCOUNT', style: AppTypography.labelSm(color: AppColors.outline)),
                            Text(selected.headcount.toString(), style: AppTypography.headlineSm(color: AppColors.onSurface)),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.xxl),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ADMIN', style: AppTypography.labelSm(color: AppColors.outline)),
                            Row(
                              children: [
                                const Icon(Icons.shield, size: 14, color: AppColors.success),
                                const SizedBox(width: 4),
                                Text(selected.admin?.name ?? 'Not Assigned', style: AppTypography.titleLg(color: AppColors.onSurface)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(height: 1, color: AppColors.outlineVariant),
                    Row(
                      children: [
                        _buildTabItem('Directory', true),
                        _buildTabItem('Settings', false),
                        _buildTabItem('Reports', false),
                      ],
                    ),
                    const Divider(height: 1, color: AppColors.outlineVariant),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Find in ${selected.name}...',
                        prefixIcon: const Icon(Icons.search, size: AppSizes.iconSm),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: const OutlineInputBorder(borderRadius: AppRadius.borderSm, borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Obx(() {
                      if (controller.isLoadingEmployees.value) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (controller.employees.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Center(
                            child: Text('No employees found', style: AppTypography.bodyMd(color: AppColors.outline)),
                          ),
                        );
                      }
                      return ListView(
                        shrinkWrap: true, // Replaced Expanded with shrinkWrap
                        physics: const NeverScrollableScrollPhysics(), // Important for SingleChildScrollView
                        children: controller.employees.map((emp) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundImage: emp.profilePicture != null
                                  ? NetworkImage(emp.profilePicture!)
                                  : const NetworkImage('https://i.pravatar.cc/150?img=12'),
                            ),
                            title: Text(emp.name, style: AppTypography.titleLg(color: AppColors.onSurface)),
                            subtitle: Text(
                              emp.designation.isNotEmpty ? emp.designation : emp.email,
                              style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSm, color: AppColors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.bodyMd(color: AppColors.onSurface)),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.arrow_drop_down, size: AppSizes.iconSm, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Text(
        label,
        style: AppTypography.bodyMd(
          color: isActive ? AppColors.secondary : AppColors.onSurfaceVariant,
        ).copyWith(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}