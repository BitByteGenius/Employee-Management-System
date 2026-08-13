import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/super_admin/controllers/access_control_controller.dart';
import 'package:tms/modules/super_admin/models/access_control_pending_user.dart';

Future<void> showApprovalConfirmation({
  required AccessControlController controller,
  required AccessControlPendingUser user,
  required bool approve,
}) async {
  await Get.dialog(
    Obx(
      () => AlertDialog(
        title: Text(approve ? 'Approve Registration' : 'Deny Registration'),
        content: Text(
          approve
              ? 'Approve ${user.fullName} (${user.email}) for ${user.role.toUpperCase()} access?'
              : 'Reject ${user.fullName} (${user.email})? This registration will not be allowed to continue.',
          style: AppTypography.bodyMd(),
        ),
        actions: [
          TextButton(onPressed: controller.isActionLoading.value ? null : () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: controller.isActionLoading.value
                ? null
                : () async {
                    final ok = approve ? await controller.approveUser(user) : await controller.rejectUser(user);
                    if (ok) Get.back();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? AppColors.secondary : AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: controller.isActionLoading.value
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(approve ? 'Approve' : 'Deny'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showDepartmentAssignmentDialog(AccessControlController controller, AccessControlPendingUser user) async {
  final selected = ''.obs;
  await controller.fetchDepartments();
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
              Text(user.fullName, style: AppTypography.bodyMd(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: selected.value.isEmpty ? null : selected.value,
                decoration: const InputDecoration(labelText: 'Department'),
                items: controller.departments.map((d) {
                  final id = (d['id'] ?? d['_id']).toString();
                  return DropdownMenuItem(value: id, child: Text((d['name'] ?? d['code'] ?? 'Department').toString()));
                }).toList(),
                onChanged: (value) => selected.value = value ?? '',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: controller.isActionLoading.value ? null : () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: controller.isActionLoading.value
                ? null
                : () async {
                    if (selected.value.isEmpty) {
                      Get.snackbar('Department Required', 'Select a department before saving.');
                      return;
                    }
                    final ok = await controller.assignDepartment(user, selected.value);
                    if (ok) Get.back();
                  },
            child: controller.isActionLoading.value
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showRoleAssignmentDialog(AccessControlController controller, AccessControlPendingUser user) async {
  final selected = ''.obs;
  await controller.fetchRoles();
  await Get.dialog(
    Obx(
      () => AlertDialog(
        title: const Text('Assign Role'),
        content: SizedBox(
          width: 420,
          child: DropdownButtonFormField<String>(
            initialValue: selected.value.isEmpty ? null : selected.value,
            decoration: const InputDecoration(labelText: 'Role'),
            items: controller.roles.map((r) {
              final id = (r['id'] ?? r['_id']).toString();
              final label = (r['label'] ?? r['name'] ?? 'Role').toString();
              return DropdownMenuItem(value: id, child: Text(label));
            }).toList(),
            onChanged: (value) => selected.value = value ?? '',
          ),
        ),
        actions: [
          TextButton(onPressed: controller.isActionLoading.value ? null : () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: controller.isActionLoading.value
                ? null
                : () async {
                    if (selected.value.isEmpty) {
                      Get.snackbar('Role Required', 'Select a role before saving.');
                      return;
                    }
                    final ok = await controller.assignRole(user, selected.value);
                    if (ok) Get.back();
                  },
            child: controller.isActionLoading.value
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
