import 'package:file_picker/file_picker.dart';
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
  PlatformFile? _attachedFile;

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

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'zip', 'png', 'jpg', 'jpeg', 'docx', 'xlsx', 'csv', 'txt'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        final double sizeInMb = file.size / (1024 * 1024);
        if (sizeInMb > 50) {
          Get.snackbar(
            'Upload Failed',
            'File size exceeds the 50MB limit.',
            backgroundColor: AppColors.error,
            colorText: AppColors.onError,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        setState(() {
          _attachedFile = file;
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
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
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 740),
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
                        Row(
                          children: [
                            Text(
                              'Project: ${widget.project.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelMd(
                                color: AppColors.secondary,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (controller.departmentName.value.isNotEmpty) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  controller.departmentName.value,
                                  style: AppTypography.labelSm(color: AppColors.secondary).copyWith(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
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

                      // Assignee Dropdown (Strictly Scoped to Department Employees with Roles)
                      Text(
                        'Assign To Department Employee *',
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
                          isExpanded: true,
                          hint: Text(
                            employees.isEmpty
                                ? 'No employees found in ${controller.departmentName.value}'
                                : 'Select ${controller.departmentName.value} team member...',
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
                            final name = (emp['fullName'] ?? emp['name'] ?? emp['email'] ?? 'Employee').toString();
                            final designation = (emp['designation'] ?? emp['assignedRoleLabel'] ?? emp['role'] ?? 'Member').toString();
                            final empId = (emp['id'] ?? emp['_id'] ?? '').toString();

                            return DropdownMenuItem<String>(
                              value: empId,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.primaryContainer,
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : 'E',
                                      style: AppTypography.labelSm(color: AppColors.onPrimaryContainer).copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        style: AppTypography.bodyMd(
                                          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: name,
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          TextSpan(
                                            text: '  •  $designation',
                                            style: const TextStyle(
                                              color: AppColors.secondary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          validator: (v) => (v == null || v.isEmpty) ? 'Please select a department employee' : null,
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

                      const SizedBox(height: AppSpacing.md),

                      // File Upload Attachment Section (Matching Super Admin)
                      Text(
                        'ATTACH FILE (Optional)',
                        style: AppTypography.labelMd(
                          color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _buildFileUploadArea(isDark),
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
                                  attachedFile: _attachedFile,
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

  Widget _buildFileUploadArea(bool isDark) {
    if (_attachedFile != null) {
      final double sizeInMb = _attachedFile!.size / (1024 * 1024);
      final sizeStr = sizeInMb >= 1.0
          ? '${sizeInMb.toStringAsFixed(1)} MB'
          : '${(_attachedFile!.size / 1024).toStringAsFixed(0)} KB';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondary, width: 1.5),
          borderRadius: AppRadius.borderMd,
          color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLowest,
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file_outlined, color: AppColors.secondary, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _attachedFile!.name,
                    style: AppTypography.bodyMd(
                      color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    sizeStr,
                    style: AppTypography.labelSm(color: AppColors.outline),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: AppColors.outline),
              tooltip: 'Remove File',
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  _attachedFile = null;
                });
              },
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
          borderRadius: AppRadius.borderMd,
          color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_upload_outlined, color: AppColors.secondary, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload task attachment or reference document',
                    style: AppTypography.bodyMd(
                      color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Supports PDF, ZIP, PNG, JPG, DOCX, XLSX (Max 50MB)',
                    style: AppTypography.labelSm(color: AppColors.outline),
                  ),
                ],
              ),
            ),
            const Icon(Icons.attach_file, color: AppColors.outline, size: 18),
          ],
        ),
      ),
    );
  }
}
