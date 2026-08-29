import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/department/controllers/department_controller.dart';
import 'package:tms/modules/department/models/department_employee_model.dart';
import 'package:tms/shared/widgets/app_user_avatar.dart';

class CreateDepartmentDialog extends StatefulWidget {
  const CreateDepartmentDialog({super.key});

  @override
  State<CreateDepartmentDialog> createState() => _CreateDepartmentDialogState();
}

class _CreateDepartmentDialogState extends State<CreateDepartmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _adminSearchController = TextEditingController();

  DepartmentEmployeeModel? _selectedAdmin;
  Timer? _searchDebounce;
  bool _showCandidateList = true;

  @override
  void initState() {
    super.initState();
    _showCandidateList = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<DepartmentController>().searchAdminCandidates('');
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _adminSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepartmentController>();

    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
      ),
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(AppSpacing.lg),
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
                      'Create New Department',
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

                // Department Name
                Text(
                  'DEPARTMENT NAME',
                  style: AppTypography.labelMd(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('e.g. Product Design'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter department name' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                // Department Code
                Text(
                  'DEPARTMENT CODE',
                  style: AppTypography.labelMd(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _codeController,
                  decoration: _inputDecoration('E.G. DES'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter department code' : null,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Used as a prefix for internal IDs.',
                  style: AppTypography.labelSm(color: AppColors.outline),
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
                  decoration: _inputDecoration('Briefly describe the purpose of this department...'),
                ),
                const SizedBox(height: AppSpacing.md),

                // Assign  Admin to department
                Text(
                  'ASSIGN Admin',
                  style: AppTypography.labelMd(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _adminSearchController,
                  onTap: () {
                    setState(() {
                      _showCandidateList = true;
                    });
                    if (controller.adminCandidates.isEmpty) {
                      controller.searchAdminCandidates(_adminSearchController.text.trim());
                    }
                  },
                  onChanged: (val) {
                    setState(() {
                      _showCandidateList = true;
                    });
                    _searchDebounce?.cancel();
                    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
                      controller.searchAdminCandidates(val.trim());
                    });
                  },
                  decoration: _inputDecoration('Search employees by name or email...').copyWith(
                    prefixIcon: const Icon(Icons.search, size: AppSizes.iconSm, color: AppColors.outline),
                    suffixIcon: _selectedAdmin != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              setState(() {
                                _selectedAdmin = null;
                                _adminSearchController.clear();
                                _showCandidateList = true;
                              });
                              controller.searchAdminCandidates('');
                            },
                          )
                        : null,
                  ),
                ),

                // Live Candidate Suggestions List
                Obx(() {
                  if (controller.isSearchingCandidates.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  if (_showCandidateList && _selectedAdmin == null && controller.adminCandidates.isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.only(top: AppSpacing.xs),
                      constraints: const BoxConstraints(maxHeight: 180),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: AppRadius.borderSm,
                        border: Border.all(color: AppColors.outlineVariant),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: controller.adminCandidates.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.outlineVariant),
                        itemBuilder: (context, index) {
                          final candidate = controller.adminCandidates[index];
                          return ListTile(
                            dense: true,
                            leading: AppUserAvatar(
                              imageUrl: candidate.profilePicture,
                              name: candidate.name,
                              radius: 14,
                            ),
                            title: Text(
                              candidate.name,
                              style: AppTypography.titleLg(color: AppColors.onSurface),
                            ),
                            subtitle: Text(
                              candidate.designation.isNotEmpty
                                  ? '${candidate.designation} • ${candidate.email}'
                                  : candidate.email,
                              style: AppTypography.labelSm(color: AppColors.outline),
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              setState(() {
                                _selectedAdmin = candidate;
                                _adminSearchController.text = candidate.name.isNotEmpty
                                    ? '${candidate.name} (${candidate.email})'
                                    : candidate.email;
                                _showCandidateList = false;
                              });
                            },
                          );
                        },
                      ),
                    );
                  }

                  if (_showCandidateList && _selectedAdmin == null && _adminSearchController.text.isNotEmpty && controller.adminCandidates.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Text('No matching Admin found.', style: AppTypography.bodyMd(color: AppColors.outline)),
                    );
                  }

                  return const SizedBox.shrink();
                }),

                const SizedBox(height: AppSpacing.xl),

                // Footer Actions
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
                    Obx(() => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.onSecondary,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.borderSm,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                          onPressed: controller.isSaving.value
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    final success = await controller.createDepartment(
                                      name: _nameController.text.trim(),
                                      code: _codeController.text.trim(),
                                      description: _descriptionController.text.trim(),
                                      initialAdminId: _selectedAdmin?.id,
                                    );
                                    if (success) {
                                      Get.back();
                                    }
                                  }
                                },
                          child: controller.isSaving.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  'CREATE DEPARTMENT',
                                  style: AppTypography.labelMd(color: AppColors.onSecondary),
                                ),
                        )),
                  ],
                ),
              ],
            ),
          ),
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
        borderSide: BorderSide(color: AppColors.secondary),
      ),
    );
  }
}