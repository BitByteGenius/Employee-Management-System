import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/employee/task/controller/employee_task_controller.dart';
import 'package:tms/modules/employee/task/view/widget/employee_task_card.dart';
import 'package:tms/shared/widgets/app_state_widgets.dart';

class EmployeeTasksView extends StatefulWidget {
  const EmployeeTasksView({super.key});

  @override
  State<EmployeeTasksView> createState() => _EmployeeTasksViewState();
}

class _EmployeeTasksViewState extends State<EmployeeTasksView> {
  bool isKanbanView = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.put<EmployeeTaskController>(EmployeeTaskController());

    return Obx(() {
      if (controller.isLoading.value && controller.tasks.isEmpty) {
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

      if (controller.hasError.value && controller.tasks.isEmpty) {
        return AppErrorStateWidget(
          errorMessage: controller.errorMessage.value,
          onRetry: controller.fetchTasks,
        );
      }

      final tasks = controller.filteredTasks;

      return RefreshIndicator(
        onRefresh: controller.fetchTasks,
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
                        'My Tasks',
                        style: AppTypography.headlineLg(
                          color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                        ).copyWith(fontWeight: FontWeight.w800, fontSize: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View, manage, and complete your assigned deliverables and tasks.',
                        style: AppTypography.bodyLg(
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  // View Switcher (List vs Kanban)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                      borderRadius: AppRadius.borderMd,
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.list_alt_rounded,
                            color: !isKanbanView ? AppColors.secondary : AppColors.outline,
                          ),
                          tooltip: 'List View',
                          onPressed: () => setState(() => isKanbanView = false),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.view_kanban_outlined,
                            color: isKanbanView ? AppColors.secondary : AppColors.outline,
                          ),
                          tooltip: 'Kanban Board',
                          onPressed: () => setState(() => isKanbanView = true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Filter Controls Bar
              Row(
                children: [
                  // Search Box
                  Expanded(
                    flex: 2,
                    child: Container(
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
                              onChanged: (v) => controller.searchQuery.value = v,
                              decoration: const InputDecoration(
                                hintText: 'Search tasks by title, project, instructions...',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Status Filter Dropdown
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
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedStatus.value,
                        items: ['All', 'Todo', 'In Progress', 'Completed']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: AppTypography.bodyMd())))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) controller.selectedStatus.value = v;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Priority Filter Dropdown
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
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedPriority.value,
                        items: ['All', 'Low', 'Medium', 'High', 'Urgent']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p, style: AppTypography.bodyMd())))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) controller.selectedPriority.value = v;
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Task List or Kanban Board
              if (tasks.isEmpty)
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
                      const Icon(Icons.assignment_turned_in_outlined, size: 48, color: AppColors.secondary),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No Assigned Tasks Found',
                        style: AppTypography.titleLg(
                          color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You are all caught up! New tasks assigned by your admin will appear here.',
                        style: AppTypography.bodyMd(color: AppColors.outline),
                      ),
                    ],
                  ),
                )
              else if (!isKanbanView)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return EmployeeTaskCard(task: tasks[index]);
                  },
                )
              else
                _buildKanbanBoard(context, controller, isDark),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildKanbanBoard(BuildContext context, EmployeeTaskController controller, bool isDark) {
    final todoList = controller.todoTasks;
    final inProgressList = controller.inProgressTasks;
    final completedList = controller.completedTasks;

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 800;

      if (isNarrow) {
        return Column(
          children: [
            _buildKanbanColumn('TO DO (${todoList.length})', todoList, const Color(0xFF64748B), isDark),
            const SizedBox(height: AppSpacing.lg),
            _buildKanbanColumn('IN PROGRESS (${inProgressList.length})', inProgressList, AppColors.secondary, isDark),
            const SizedBox(height: AppSpacing.lg),
            _buildKanbanColumn('COMPLETED (${completedList.length})', completedList, AppColors.success, isDark),
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildKanbanColumn('TO DO (${todoList.length})', todoList, const Color(0xFF64748B), isDark)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _buildKanbanColumn('IN PROGRESS (${inProgressList.length})', inProgressList, AppColors.secondary, isDark)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _buildKanbanColumn('COMPLETED (${completedList.length})', completedList, AppColors.success, isDark)),
        ],
      );
    });
  }

  Widget _buildKanbanColumn(String title, List tasks, Color headerColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: headerColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.labelMd(color: headerColor).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (tasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              alignment: Alignment.center,
              child: Text('No tasks in column', style: AppTypography.labelSm(color: AppColors.outline)),
            )
          else
            ...tasks.map((t) => EmployeeTaskCard(task: t)),
        ],
      ),
    );
  }
}
