import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/admin/my%20project/controller/admin_project_controller.dart';
import 'package:tms/modules/admin/my%20project/models/admin_project_model.dart';

class AssignTaskDialog extends StatefulWidget {
  final AdminProjectModel project;

  const AssignTaskDialog({
    super.key,
    required this.project,
  });

  @override
  State<AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends State<AssignTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedAssigneeId;
  String _selectedPriority = 'Medium';
  DateTime? _selectedDueDate;

  final List<String> _priorityOptions = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now.add(const Duration(days: 7)),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<AdminProjectController>();

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.md, AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.assignment_ind_outlined,
                              size: 20,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Assign Task to Employee',
                              style: AppTypography.headlineSm(
                                color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Project: ${widget.project.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMd(
                            color: AppColors.secondary,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task Title
                      Text(
                        'Task Title *',
                        style: AppTypography.labelMd(
                          color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: _titleController,
                        style: AppTypography.bodyMd(
                          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'e.g. Implement User Authentication flow',
                          border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter task title' : null,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Assignee Dropdown (Scoped to Department Employees)
                      Text(
                        'Assign To Employee *',
                        style: AppTypography.labelMd(
                          color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Obx(() {
                        final employees = controller.departmentEmployees;
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedAssigneeId,
                          hint: Text(
                            employees.isEmpty
                                ? 'No employees available in department'
                                : 'Select department employee...',
                            style: AppTypography.bodyMd(color: AppColors.outline),
                          ),
                          style: AppTypography.bodyMd(
                            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                          ),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: employees.map((emp) {
                            final name = emp['name'] ?? emp['fullName'] ?? emp['email'] ?? 'Employee';
                            final designation = emp['designation'] ?? emp['assignedRoleLabel'] ?? '';
                            return DropdownMenuItem<String>(
                              value: emp['id'] ?? emp['_id'] ?? '',
                              child: Text(
                                designation.isNotEmpty ? '$name ($designation)' : name.toString(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          validator: (v) => (v == null || v.isEmpty) ? 'Please select an employee' : null,
                          onChanged: (val) {
                            setState(() => _selectedAssigneeId = val);
                          },
                        );
                      }),

                      const SizedBox(height: AppSpacing.md),

                      // Priority & Due Date Row
                      Row(
                        children: [
                          // Priority
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Priority',
                                  style: AppTypography.labelMd(
                                    color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedPriority,
                                  style: AppTypography.bodyMd(
                                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                                  ),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                  items: _priorityOptions.map((p) {
                                    return DropdownMenuItem(
                                      value: p,
                                      child: Text(p),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedPriority = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),

                          // Due Date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Due Date',
                                  style: AppTypography.labelMd(
                                    color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                InkWell(
                                  onTap: () => _pickDueDate(context),
                                  borderRadius: AppRadius.borderMd,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.outlineVariant.withValues(alpha: 0.6),
                                      ),
                                      borderRadius: AppRadius.borderMd,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 16,
                                          color: _selectedDueDate != null
                                              ? AppColors.secondary
                                              : AppColors.outline,
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Expanded(
                                          child: Text(
                                            _selectedDueDate != null
                                                ? DateFormat('MMM dd, yyyy').format(_selectedDueDate!)
                                                : 'Pick Date',
                                            style: AppTypography.bodyMd(
                                              color: _selectedDueDate != null
                                                  ? (isDark
                                                      ? AppColors.darkOnSurface
                                                      : AppColors.onSurface)
                                                  : AppColors.outline,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Description / Instructions
                      Text(
                        'Task Description / Instructions',
                        style: AppTypography.labelMd(
                          color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        style: AppTypography.bodyMd(
                          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Detail requirements, expectations, and acceptance criteria...',
                          border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Obx(
                    () => ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                      ),
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final success = await controller.assignTaskToEmployee(
                                  projectId: widget.project.id,
                                  title: _titleController.text,
                                  description: _descriptionController.text,
                                  assigneeId: _selectedAssigneeId!,
                                  priority: _selectedPriority,
                                  dueDate: _selectedDueDate,
                                );
                                if (success) {
                                  Get.back();
                                }
                              }
                            },
                      icon: controller.isSubmitting.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Assign Task'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
