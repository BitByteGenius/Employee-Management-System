import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/department/controllers/department_controller.dart';

class CreateDepartmentDialog extends StatelessWidget {
  CreateDepartmentDialog({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _adminSearchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepartmentController>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
      ),
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
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
                validator: (val) => val == null || val.isEmpty ? 'Please enter department name' : null,
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
                validator: (val) => val == null || val.isEmpty ? 'Please enter department code' : null,
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

              // Assign Initial Admin
              Text(
                'ASSIGN INITIAL ADMIN',
                style: AppTypography.labelMd(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _adminSearchController,
                decoration: _inputDecoration('Search employees by name or email...').copyWith(
                  prefixIcon: const Icon(Icons.search, size: AppSizes.iconSm, color: AppColors.outline),
                ),
              ),
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
                          shape: RoundedRectangleBorder(
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
                                    name: _nameController.text,
                                    code: _codeController.text,
                                    description: _descriptionController.text,
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
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMd(color: AppColors.outline),
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      border: OutlineInputBorder(
        borderRadius: AppRadius.borderSm,
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderSm,
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderSm,
        borderSide: const BorderSide(color: AppColors.secondary),
      ),
    );
  }
}