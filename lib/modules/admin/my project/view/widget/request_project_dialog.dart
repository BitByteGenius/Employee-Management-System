import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/admin/my%20project/controller/admin_project_controller.dart';

class RequestProjectDialog extends StatefulWidget {
  const RequestProjectDialog({super.key});

  @override
  State<RequestProjectDialog> createState() => _RequestProjectDialogState();
}

class _RequestProjectDialogState extends State<RequestProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController(text: 'Lead Developer');
  final _descriptionController = TextEditingController();

  String _selectedStatus = 'Active';
  DateTime? _selectedDueDate;
  double _progress = 0;
  String? _selectedManagerId;
  final List<String> _selectedMemberIds = [];

  final List<String> _statusOptions = ['Active', 'Planning', 'At Risk', 'Completed'];

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
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
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request New Project',
                        style: AppTypography.headlineSm(
                          color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                            'Department: ${controller.departmentName.value}',
                            style: AppTypography.labelMd(
                              color: AppColors.secondary,
                            ).copyWith(fontWeight: FontWeight.w600),
                          )),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project Name
                      Text(
                        'Project Name *',
                        style: AppTypography.labelMd(
                          color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                        TextFormField(
                        controller: _nameController,
                        style: AppTypography.bodyMd(
                          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'e.g. Project Alpha Phoenix',
                          border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter project name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Role & Status Row
                      Row(
                        children: [
                          // Assigned Role
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Designated Role *',
                                  style: AppTypography.labelMd(
                                    color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                TextFormField(
                                  controller: _roleController,
                                  style: AppTypography.bodyMd(
                                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. Lead Developer, UI Designer',
                                    border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter role' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),

                          // Initial Status
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status',
                                  style: AppTypography.labelMd(
                                    color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedStatus,
                                  style: AppTypography.bodyMd(
                                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                                  ),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                  items: _statusOptions.map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedStatus = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Deadline Date Picker
                      Text(
                        'Deadline / Due Date',
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
                                size: 18,
                                color: _selectedDueDate != null ? AppColors.secondary : AppColors.outline,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                _selectedDueDate != null
                                    ? DateFormat('MMM dd, yyyy').format(_selectedDueDate!)
                                    : 'Select target deadline...',
                                style: AppTypography.bodyMd(
                                  color: _selectedDueDate != null
                                      ? (isDark ? AppColors.darkOnSurface : AppColors.onSurface)
                                      : AppColors.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Manager / Lead Assignment (Scoped to Department)
                      Text(
                        'Department Lead / Manager',
                        style: AppTypography.labelMd(
                          color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Obx(() {
                        final employees = controller.departmentEmployees;
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedManagerId,
                          hint: Text(
                            employees.isEmpty ? 'No department employees found' : 'Select department employee...',
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
                          onChanged: (val) {
                            setState(() => _selectedManagerId = val);
                          },
                        );
                      }),

                      const SizedBox(height: AppSpacing.md),

                      // Initial Progress Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Initial Progress',
                            style: AppTypography.labelMd(
                              color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${_progress.toInt()}%',
                            style: AppTypography.labelMd(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _progress,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        activeColor: AppColors.secondary,
                        onChanged: (v) => setState(() => _progress = v),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Description
                      Text(
                        'Project Description / Goals',
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
                          hintText: 'Add project scope, requirements, or deliverables...',
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
                    () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                      ),
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final success = await controller.createProject(
                                  name: _nameController.text,
                                  role: _roleController.text,
                                  status: _selectedStatus,
                                  progress: _progress.toInt(),
                                  dueDate: _selectedDueDate,
                                  managerId: _selectedManagerId,
                                  memberIds: _selectedMemberIds,
                                  description: _descriptionController.text,
                                );
                                if (success) {
                                  Get.back();
                                }
                              }
                            },
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Request Project'),
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
