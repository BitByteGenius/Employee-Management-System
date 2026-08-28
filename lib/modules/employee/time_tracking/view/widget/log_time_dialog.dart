import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/core/network/api_client.dart';

class LogTimeDialog extends StatefulWidget {
  final VoidCallback onTimeLogged;

  const LogTimeDialog({
    super.key,
    required this.onTimeLogged,
  });

  @override
  State<LogTimeDialog> createState() => _LogTimeDialogState();
}

class _LogTimeDialogState extends State<LogTimeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  final _hoursController = TextEditingController(text: '7.5');
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _taskController.dispose();
    _hoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final api = Get.find<ApiClient>();
      final payload = {
        'taskName': _taskController.text.trim(),
        'hours': double.tryParse(_hoursController.text.trim()) ?? 1.0,
        'date': _selectedDate.toIso8601String(),
        'notes': _notesController.text.trim(),
        'status': 'approved',
      };

      final res = await api.dio.post(ApiEndpoints.timeTracking, data: payload);
      if (res.data != null && res.data['success'] == true) {
        Get.back();
        widget.onTimeLogged();
        Get.snackbar(
          'Time Logged',
          '${_hoursController.text} hours recorded in MongoDB successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Submission Failed',
        'Failed to log time: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFBA1A1A).withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
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
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled, color: AppColors.secondary, size: 22),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Log Work Hours',
                          style: AppTypography.headlineSm(
                            color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Task Name
                Text('Task / Activity Description *', style: AppTypography.labelMd(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _taskController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Implemented Cloudinary Upload Pipeline',
                    border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter task description' : null,
                ),

                const SizedBox(height: AppSpacing.md),

                // Hours & Date Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Duration (Hours) *', style: AppTypography.labelMd(fontWeight: FontWeight.w600)),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _hoursController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              hintText: 'e.g. 7.5',
                              border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            validator: (v) {
                              final d = double.tryParse(v ?? '');
                              if (d == null || d <= 0) return 'Valid hours required';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date *', style: AppTypography.labelMd(fontWeight: FontWeight.w600)),
                          const SizedBox(height: AppSpacing.xs),
                          InkWell(
                            onTap: () => _pickDate(context),
                            borderRadius: AppRadius.borderMd,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
                                borderRadius: AppRadius.borderMd,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.secondary),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                                      style: AppTypography.bodyMd(),
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

                // Notes
                Text('Notes / Accomplishments', style: AppTypography.labelMd(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Optional summary of work done today...',
                    border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                      ),
                      onPressed: _isSubmitting ? null : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check, size: 18),
                      label: const Text('Save Time Entry'),
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
}
