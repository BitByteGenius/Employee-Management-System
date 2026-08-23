import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/modules/department/controllers/department_controller.dart';
import 'package:tms/modules/department/models/department_models.dart';
import 'package:tms/modules/department/repositories/department_repository.dart';
import 'package:tms/modules/department/services/department_service.dart';
import 'package:tms/modules/super_admin/projects/controller/project_controller.dart';

class CreateProjectDialog extends StatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  DepartmentModel? _selectedDepartment;
  DateTime? _dueDate;
  PlatformFile? _attachedFile;
  bool _isCreating = false;

  DepartmentController _getDeptController() {
    if (Get.isRegistered<DepartmentController>()) {
      return Get.find<DepartmentController>();
    }
    if (!Get.isRegistered<DepartmentService>()) {
      Get.lazyPut<DepartmentService>(
        () => DepartmentService(Get.find<ApiClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<DepartmentRepository>()) {
      Get.lazyPut<DepartmentRepository>(
        () => DepartmentRepository(Get.find<DepartmentService>()),
        fenix: true,
      );
    }
    final deptCtrl = DepartmentController(Get.find<DepartmentRepository>());
    Get.lazyPut<DepartmentController>(() => deptCtrl, fenix: true);
    return deptCtrl;
  }

  @override
  void initState() {
    super.initState();
    final deptCtrl = _getDeptController();
    if (deptCtrl.departments.isEmpty && !deptCtrl.isLoading.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        deptCtrl.fetchDepartments();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'zip', 'png', 'jpg', 'docx', 'xlsx'],
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

  Future<void> _pickDueDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? today,
      firstDate: today,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: AppColors.onSecondary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final controller = Get.find<ProjectController>();
      final success = await controller.createProject(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        departmentId: _selectedDepartment?.id,
        dueDate: _dueDate,
        attachedFile: _attachedFile,
      );

      if (success) {
        Get.back();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deptController = _getDeptController();

    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
      ),
      backgroundColor: AppColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create New Project',
                      style: AppTypography.headlineSm(color: AppColors.onSurface),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: AppSizes.iconSm),
                      color: AppColors.onSurfaceVariant,
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Project Name
                Text(
                  'PROJECT NAME *',
                  style: AppTypography.labelMd(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _nameController,
                  style: AppTypography.bodyMd(color: AppColors.onBackground),
                  decoration: _inputDecoration('e.g. Mobile App Redesign'),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Please enter project name' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                // Description
                Text(
                  'DESCRIPTION (Optional)',
                  style: AppTypography.labelMd(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: AppTypography.bodyMd(color: AppColors.onBackground),
                  decoration: _inputDecoration('Briefly describe this project initiative...'),
                ),
                const SizedBox(height: AppSpacing.md),

                // Assign Department
                Text(
                  'DEPARTMENT (Optional)',
                  style: AppTypography.labelMd(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xs),
                _buildDepartmentSelector(deptController),
                const SizedBox(height: AppSpacing.md),

                // Due Date
                Text(
                  'TARGET DUE DATE (Optional)',
                  style: AppTypography.labelMd(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xs),
                GestureDetector(
                  onTap: () => _pickDueDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.outlineVariant),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      color: AppColors.surfaceContainerLow,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, color: AppColors.outline, size: 20),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            _dueDate == null
                                ? 'Select Due Date'
                                : DateFormat('MMM dd, yyyy').format(_dueDate!),
                            style: AppTypography.bodyMd(
                              color: _dueDate == null ? AppColors.outline : AppColors.onBackground,
                            ),
                          ),
                        ),
                        if (_dueDate != null)
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: AppColors.onSurfaceVariant),
                            onPressed: () {
                              setState(() {
                                _dueDate = null;
                              });
                            },
                            splashRadius: 16,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        else
                          const Icon(Icons.calendar_today, color: AppColors.outline, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // File Upload
                Text(
                  'ATTACH FILE (Optional)',
                  style: AppTypography.labelMd(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xs),
                _buildFileUploadArea(),

                const SizedBox(height: AppSpacing.xl),
                const Divider(color: AppColors.surfaceContainerHigh, height: 1, thickness: 1),
                const SizedBox(height: AppSpacing.lg),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'CANCEL',
                        style: AppTypography.labelMd(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.onSecondary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.borderSm,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isCreating ? null : _submit,
                      child: _isCreating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onSecondary,
                              ),
                            )
                          : Text(
                              'CREATE PROJECT',
                              style: AppTypography.labelMd(color: AppColors.onSecondary),
                            ),
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

  Widget _buildDepartmentSelector(DepartmentController deptController) {
    if (_selectedDepartment != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondary, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          color: AppColors.surfaceContainerLowest,
        ),
        child: Row(
          children: [
            const Icon(Icons.apartment_outlined, color: AppColors.secondary, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                _selectedDepartment!.name,
                style: AppTypography.bodyMd(
                  color: AppColors.onBackground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: AppColors.onSurfaceVariant),
              tooltip: 'Clear Department',
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  _selectedDepartment = null;
                });
              },
            ),
          ],
        ),
      );
    }

    return Obx(() {
      final deptList = deptController.departments.toList();
      final isLoading = deptController.isLoading.value;

      if (isLoading && deptList.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            color: AppColors.surfaceContainerLow,
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: AppSpacing.md),
              Text('Loading departments...'),
            ],
          ),
        );
      }

      return RawAutocomplete<DepartmentModel>(
        displayStringForOption: (option) => option.name,
        optionsBuilder: (TextEditingValue textEditingValue) {
          final query = textEditingValue.text.toLowerCase().trim();
          if (query.isEmpty) {
            return deptList;
          }
          return deptList.where((dept) {
            final nameMatch = dept.name.toLowerCase().contains(query);
            final codeMatch = dept.code.toLowerCase().contains(query);
            return nameMatch || codeMatch;
          });
        },
        onSelected: (DepartmentModel selection) {
          setState(() {
            _selectedDepartment = selection;
          });
        },
        fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
          return TextField(
            controller: textController,
            focusNode: focusNode,
            style: AppTypography.bodyMd(color: AppColors.onBackground),
            decoration: _inputDecoration('Search or select department...').copyWith(
              prefixIcon: const Icon(Icons.search, size: AppSizes.iconSm, color: AppColors.outline),
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              color: AppColors.surfaceContainerLowest,
              child: Container(
                width: 476,
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.outlineVariant),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: options.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'No matching departments found.',
                          style: AppTypography.bodyMd(color: AppColors.outline),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.outlineVariant),
                        itemBuilder: (context, index) {
                          final dept = options.elementAt(index);
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.apartment_outlined, size: 20, color: AppColors.secondary),
                            title: Text(
                              dept.name,
                              style: AppTypography.bodyMd(
                                color: AppColors.onBackground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Code: ${dept.code}${dept.description.isNotEmpty ? ' • ${dept.description}' : ''}',
                              style: AppTypography.labelSm(color: AppColors.outline),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => onSelected(dept),
                          );
                        },
                      ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildFileUploadArea() {
    if (_attachedFile != null) {
      final double sizeInMb = _attachedFile!.size / (1024 * 1024);
      final sizeStr = sizeInMb >= 1.0
          ? '${sizeInMb.toStringAsFixed(1)} MB'
          : '${(_attachedFile!.size / 1024).toStringAsFixed(0)} KB';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondary, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          color: AppColors.surfaceContainerLowest,
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
                      color: AppColors.onBackground,
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
              icon: const Icon(Icons.close, size: 18, color: AppColors.onSurfaceVariant),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          color: AppColors.surfaceContainerLow,
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
                    'Upload project file or deliverable',
                    style: AppTypography.bodyMd(color: AppColors.onBackground),
                  ),
                  Text(
                    'Supports PDF, ZIP, PNG, JPG, DOCX (Max 50MB)',
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMd(color: AppColors.outline),
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      border: const OutlineInputBorder(
        borderRadius: AppRadius.borderSm,
        borderSide: BorderSide(color: AppColors.outlineVariant),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppRadius.borderSm,
        borderSide: BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppRadius.borderSm,
        borderSide: BorderSide(color: AppColors.secondary, width: 2),
      ),
    );
  }
}