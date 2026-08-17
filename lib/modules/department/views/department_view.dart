import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/department/controllers/department_controller.dart';
import 'package:tms/modules/department/models/department_employee_model.dart';
import 'package:tms/modules/department/models/department_models.dart';
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
              await controller.refreshDepartments();
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
                                onPressed: () {
                                  Get.snackbar(
                                    'Export',
                                    'Department directory exported successfully.',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
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
                                onPressed: () => Get.dialog(const CreateDepartmentDialog()),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // Filters row
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Obx(() => PopupMenuButton<String>(
                        onSelected: (val) => controller.updateStatus(val),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'all', child: Text('All Statuses')),
                          const PopupMenuItem(value: 'active', child: Text('Active')),
                          const PopupMenuItem(value: 'inactive', child: Text('Inactive')),
                        ],
                        child: _buildDropdownFilter(
                          controller.selectedStatus.value == 'all'
                              ? 'All Statuses'
                              : controller.selectedStatus.value.capitalizeFirst!,
                          Icons.filter_list,
                        ),
                      )),
                      const SizedBox(width: AppSpacing.md),
                      Obx(() => PopupMenuButton<String>(
                        onSelected: (val) => controller.updateSort(val),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
                          const PopupMenuItem(value: 'code', child: Text('Sort by Code')),
                          const PopupMenuItem(value: 'createdAt', child: Text('Sort by Date')),
                        ],
                        child: _buildDropdownFilter(
                          controller.sortBy.value == 'name'
                              ? 'Sort by Name'
                              : (controller.sortBy.value == 'code' ? 'Sort by Code' : 'Sort by Date'),
                          Icons.sort,
                        ),
                      )),
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
                  if (controller.departments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Center(
                        child: Text(
                          controller.errorMessage.value.isNotEmpty
                              ? controller.errorMessage.value
                              : 'No departments found',
                          style: AppTypography.bodyMd(color: AppColors.outline),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dept.name,
                                              style: AppTypography.titleLg(color: AppColors.onSurface),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(dept.code, style: AppTypography.labelSm(color: AppColors.outline)),
                                          ],
                                        ),
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
                                            Expanded(
                                              child: Text(
                                                dept.admin!.name,
                                                style: AppTypography.bodyMd(color: AppColors.onSurface),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        )
                                      : InkWell(
                                          onTap: () => _showAssignAdminDialog(context, dept),
                                          child: Text('Assign Admin', style: AppTypography.bodyMd(color: AppColors.secondary)),
                                        ),
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
                  mainAxisSize: MainAxisSize.min,
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
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () {
                                final currentIndex = controller.departments.indexWhere((d) => d.id == selected.id);
                                if (currentIndex > 0) {
                                  controller.selectDepartment(controller.departments[currentIndex - 1]);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                final currentIndex = controller.departments.indexWhere((d) => d.id == selected.id);
                                if (currentIndex != -1 && currentIndex < controller.departments.length - 1) {
                                  controller.selectDepartment(controller.departments[currentIndex + 1]);
                                }
                              },
                            ),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ADMIN', style: AppTypography.labelSm(color: AppColors.outline)),
                              InkWell(
                                onTap: () => _showAssignAdminDialog(context, selected),
                                child: Row(
                                  children: [
                                    const Icon(Icons.shield, size: 14, color: AppColors.success),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        selected.admin?.name ?? 'Assign Admin',
                                        style: AppTypography.titleLg(
                                          color: selected.admin != null ? AppColors.onSurface : AppColors.secondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(height: 1, color: AppColors.outlineVariant),
                    Obx(() => Row(
                      children: [
                        InkWell(
                          onTap: () => controller.selectTab(0),
                          child: _buildTabItem('Directory', controller.selectedDetailTab.value == 0),
                        ),
                        InkWell(
                          onTap: () => controller.selectTab(1),
                          child: _buildTabItem('Settings', controller.selectedDetailTab.value == 1),
                        ),
                        InkWell(
                          onTap: () => controller.selectTab(2),
                          child: _buildTabItem('Reports', controller.selectedDetailTab.value == 2),
                        ),
                      ],
                    )),
                    const Divider(height: 1, color: AppColors.outlineVariant),
                    const SizedBox(height: AppSpacing.md),

                    // Tab Content
                    Obx(() {
                      final tabIndex = controller.selectedDetailTab.value;
                      if (tabIndex == 1) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Department Status', style: AppTypography.labelMd(color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Current Status: ${selected.status.toUpperCase()}',
                                    style: AppTypography.bodyMd(color: AppColors.onSurface),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final newStatus = selected.status == 'active' ? 'inactive' : 'active';
                                      controller.updateDepartment(selected.id, {'status': newStatus});
                                    },
                                    child: Text(selected.status == 'active' ? 'Deactivate' : 'Activate'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text('Department Code: ${selected.code}', style: AppTypography.bodyMd(color: AppColors.onSurface)),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => _showEditDepartmentDialog(context, selected),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Edit Details'),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                    onPressed: () => controller.deleteDepartment(selected.id),
                                    icon: const Icon(Icons.delete_outline, size: 16),
                                    label: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }

                      if (tabIndex == 2) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Department Overview', style: AppTypography.labelMd(color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: AppSpacing.sm),
                              Text('Total Headcount: ${selected.headcount}', style: AppTypography.bodyMd(color: AppColors.onSurface)),
                              const SizedBox(height: AppSpacing.xs),
                              Text('Administrator: ${selected.admin?.name ?? 'None'}', style: AppTypography.bodyMd(color: AppColors.onSurface)),
                              const SizedBox(height: AppSpacing.xs),
                              Text('System Status: ${selected.status.toUpperCase()}', style: AppTypography.bodyMd(color: AppColors.onSurface)),
                            ],
                          ),
                        );
                      }

                      // Directory tab
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            onChanged: (val) => controller.searchEmployees(val),
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
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
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

  void _showAssignAdminDialog(BuildContext context, DepartmentModel dept) {
    final searchController = TextEditingController();
    DepartmentEmployeeModel? chosenAdmin;
    controller.searchAdminCandidates('');

    Get.dialog(
      StatefulBuilder(
        builder: (ctx, setState) {
          return Dialog(
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
            backgroundColor: AppColors.surfaceContainerLowest,
            child: Container(
              width: 480,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Assign Administrator', style: AppTypography.headlineSm(color: AppColors.onSurface)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Department: ${dept.name}', style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: searchController,
                    onChanged: (val) {
                      controller.searchAdminCandidates(val.trim()).then((_) => setState(() {}));
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search user by name or email...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(borderRadius: AppRadius.borderSm, borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Obx(() {
                    if (controller.isSearchingCandidates.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.adminCandidates.isEmpty && searchController.text.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text('No matching users found.', style: AppTypography.bodyMd(color: AppColors.outline)),
                      );
                    }
                    return Container(
                      constraints: const BoxConstraints(maxHeight: 180),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.adminCandidates.length,
                        itemBuilder: (context, index) {
                          final cand = controller.adminCandidates[index];
                          final isChosen = chosenAdmin?.id == cand.id;
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundImage: cand.profilePicture != null
                                  ? NetworkImage(cand.profilePicture!)
                                  : const NetworkImage('https://i.pravatar.cc/150?img=32'),
                            ),
                            title: Text(cand.name, style: AppTypography.titleLg(color: AppColors.onSurface)),
                            subtitle: Text(cand.email, style: AppTypography.labelSm(color: AppColors.outline)),
                            selected: isChosen,
                            selectedTileColor: AppColors.surfaceContainerLow,
                            onTap: () {
                              setState(() {
                                chosenAdmin = cand;
                                searchController.text = '${cand.name} (${cand.email})';
                              });
                            },
                          );
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (dept.admin != null)
                        TextButton(
                          style: TextButton.styleFrom(foregroundColor: AppColors.error),
                          onPressed: () async {
                            Get.back();
                            await controller.removeAdmin(dept.id);
                          },
                          child: const Text('Remove Admin'),
                        )
                      else
                        const SizedBox.shrink(),
                      Row(
                        children: [
                          TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
                          const SizedBox(width: AppSpacing.sm),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.onSecondary,
                              shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
                            ),
                            onPressed: chosenAdmin == null
                                ? null
                                : () async {
                                    final adminId = chosenAdmin!.id;
                                    Get.back();
                                    await controller.assignAdmin(dept.id, adminId);
                                  },
                            child: const Text('ASSIGN'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditDepartmentDialog(BuildContext context, DepartmentModel dept) {
    final nameCtrl = TextEditingController(text: dept.name);
    final codeCtrl = TextEditingController(text: dept.code);
    final descCtrl = TextEditingController(text: dept.description);
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
        backgroundColor: AppColors.surfaceContainerLowest,
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Edit Department', style: AppTypography.headlineSm(color: AppColors.onSurface)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text('DEPARTMENT NAME', style: AppTypography.labelMd(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: AppRadius.borderSm, borderSide: BorderSide.none),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter department name' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('DEPARTMENT CODE', style: AppTypography.labelMd(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: AppRadius.borderSm, borderSide: BorderSide.none),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter department code' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('DESCRIPTION', style: AppTypography.labelMd(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: AppRadius.borderSm, borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
                    const SizedBox(width: AppSpacing.md),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.onSecondary,
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final success = await controller.updateDepartment(dept.id, {
                            'name': nameCtrl.text.trim(),
                            'code': codeCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                          });
                          if (success) {
                            Get.back();
                          }
                        }
                      },
                      child: const Text('SAVE CHANGES'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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