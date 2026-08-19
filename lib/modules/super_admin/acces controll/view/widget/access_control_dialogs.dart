import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/super_admin/acces%20controll/controller/access_control_controller.dart';
import 'package:tms/modules/super_admin/acces%20controll/models/access_control_pending_user.dart';

Future<void> showApprovalConfirmation({
  required AccessControlController controller,
  required AccessControlPendingUser user,
  required bool approve,
}) async {
  if (approve) {
    if (user.isEmployee) {
      if (!user.hasAssignedRole || !user.hasAssignedDepartment) {
        Get.snackbar(
          'Assignment Required',
          'Department and role assignment are required before approving an employee.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
    } else if (user.isAdmin) {
      if (!user.hasAssignedDepartment) {
        Get.snackbar(
          'Assignment Required',
          'Department assignment is required before approving an administrator.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
    }
  }

  await Get.dialog(
    Obx(
      () => AlertDialog(
        title: Text(approve ? 'Approve Registration' : 'Deny Registration'),
        content: Text(
          approve
              ? 'Approve ${user.fullName} (${user.email}) for ${user.systemRole.toUpperCase()} access?'
              : 'Reject ${user.fullName} (${user.email})? This registration will not be allowed to continue.',
          style: AppTypography.bodyMd(),
        ),
        actions: [
          TextButton(
            onPressed: controller.isActionLoading.value ? null : () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: controller.isActionLoading.value
                ? null
                : () async {
                    final ok = approve
                        ? await controller.approveUser(user)
                        : await controller.rejectUser(user);
                    if (ok) Get.back();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? AppColors.secondary : AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: controller.isActionLoading.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(approve ? 'Approve' : 'Deny'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showDepartmentAssignmentDialog(
  AccessControlController controller,
  AccessControlPendingUser user,
) async {
  await controller.fetchDepartments();

  final initialDept = user.resolvedDepartmentId ?? '';
  final deptExists = controller.departments
      .any((d) => (d['id'] ?? d['_id'])?.toString() == initialDept);
  final selected = (deptExists ? initialDept : '').obs;

  await Get.dialog(
    Obx(
      () => AlertDialog(
        title: const Text('Assign Department'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: AppTypography.bodyMd(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: selected.value.isEmpty ? null : selected.value,
                decoration: const InputDecoration(labelText: 'Department'),
                items: controller.departments.map((d) {
                  final id = (d['id'] ?? d['_id']).toString();
                  return DropdownMenuItem(
                    value: id,
                    child: Text(
                      (d['name'] ?? d['code'] ?? 'Department').toString(),
                    ),
                  );
                }).toList(),
                onChanged: (value) => selected.value = value ?? '',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: controller.isActionLoading.value ? null : () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: controller.isActionLoading.value
                ? null
                : () async {
                    if (selected.value.isEmpty) {
                      Get.snackbar(
                        'Department Required',
                        'Select a department before saving.',
                        snackPosition: SnackPosition.TOP,
                      );
                      return;
                    }
                    final ok = await controller.assignDepartment(
                      user,
                      selected.value,
                    );
                    if (ok) Get.back();
                  },
            child: controller.isActionLoading.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showRoleAssignmentDialog(
  AccessControlController controller,
  AccessControlPendingUser user,
) async {
  await Future.wait([
    controller.fetchRoles(),
    controller.fetchDepartments(),
  ]);

  final rawSelectable = controller.roles.where((r) {
    final name = (r['name'] ?? '').toString().toLowerCase();
    return name != 'super_admin' && name != 'admin';
  }).toList();
  final selectableRoles = rawSelectable.isNotEmpty
      ? rawSelectable
      : controller.roles
          .where(
            (r) => (r['name'] ?? '').toString().toLowerCase() != 'super_admin',
          )
          .toList();

  final initialRole = user.resolvedAssignedRoleId ?? '';
  final roleExists = selectableRoles
      .any((r) => (r['id'] ?? r['_id'])?.toString() == initialRole);
  final selectedRole = (roleExists ? initialRole : '').obs;

  final initialDept = user.resolvedDepartmentId ?? '';
  final deptExists = controller.departments
      .any((d) => (d['id'] ?? d['_id'])?.toString() == initialDept);
  final selectedDept = (deptExists ? initialDept : '').obs;

  await Get.dialog(
    Obx(
      () => AlertDialog(
        title: const Text('Assign Role'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: AppTypography.bodyMd(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: selectedRole.value.isEmpty ? null : selectedRole.value,
                decoration: const InputDecoration(labelText: 'Role'),
                items: selectableRoles.map((r) {
                  final id = (r['id'] ?? r['_id']).toString();
                  final label =
                      (r['label'] ?? r['name'] ?? 'Role').toString();
                  return DropdownMenuItem(value: id, child: Text(label));
                }).toList(),
                onChanged: (value) => selectedRole.value = value ?? '',
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: selectedDept.value.isEmpty ? null : selectedDept.value,
                decoration: const InputDecoration(labelText: 'Department'),
                items: controller.departments.map((d) {
                  final id = (d['id'] ?? d['_id']).toString();
                  return DropdownMenuItem(
                    value: id,
                    child: Text(
                      (d['name'] ?? d['code'] ?? 'Department').toString(),
                    ),
                  );
                }).toList(),
                onChanged: (value) => selectedDept.value = value ?? '',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: controller.isActionLoading.value ? null : () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: controller.isActionLoading.value
                ? null
                : () async {
                    if (selectedRole.value.isEmpty) {
                      Get.snackbar(
                        'Role Required',
                        'Select a role before saving.',
                        snackPosition: SnackPosition.TOP,
                      );
                      return;
                    }
                    if (selectedDept.value.isEmpty) {
                      Get.snackbar(
                        'Department Required',
                        'Select a department before saving.',
                        snackPosition: SnackPosition.TOP,
                      );
                      return;
                    }
                    final ok = await controller.assignEmployeeRoleAndDepartment(
                      user,
                      roleId: selectedRole.value,
                      departmentId: selectedDept.value,
                    );
                    if (ok) Get.back();
                  },
            child: controller.isActionLoading.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
