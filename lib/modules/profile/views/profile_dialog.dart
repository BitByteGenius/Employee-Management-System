import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/api_client.dart';
import '../controllers/profile_controller.dart';
import '../models/user_profile_model.dart';
import '../services/profile_service.dart';

class ProfileDialog extends StatefulWidget {
  const ProfileDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ProfileDialog(),
    );
  }

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  late final ProfileController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ProfileController>()) {
      controller = Get.find<ProfileController>();
      controller.fetchProfile();
    } else {
      if (!Get.isRegistered<ProfileService>()) {
        Get.put(ProfileService(Get.find<ApiClient>()), permanent: true);
      }
      controller = Get.put(
        ProfileController(Get.find<ProfileService>()),
        permanent: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 24 : 32,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 680,
          maxHeight: 780,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(context, isDark),

            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E7EB),
            ),

            // Body
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final profile = controller.userProfile.value;
                if (profile == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 36, color: AppColors.error),
                        const SizedBox(height: 8),
                        Text(
                          controller.errorMessage.value.isNotEmpty
                              ? controller.errorMessage.value
                              : 'Failed to load profile details.',
                          style: AppTypography.bodyMd(),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: controller.fetchProfile,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar & Identity Card
                      _buildAvatarCard(context, profile, isDark, isMobile),

                      const SizedBox(height: 24),

                      // Section 1: Personal Details
                      _buildSectionTitle('Personal Details', isDark),
                      const SizedBox(height: 12),
                      _buildPersonalFields(context, profile, isDark, isMobile),

                      const SizedBox(height: 24),

                      // Section 2: Organizational Details (Read-only System Info)
                      _buildSectionTitle('Organizational Info', isDark),
                      const SizedBox(height: 12),
                      _buildOrganizationFields(context, profile, isDark, isMobile),

                      const SizedBox(height: 24),

                      // Section 3: Additional Information
                      _buildSectionTitle('Additional Information', isDark),
                      const SizedBox(height: 12),
                      _buildAdditionalFields(context, profile, isDark, isMobile),
                    ],
                  ),
                );
              }),
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E7EB),
            ),

            // Footer Actions
            _buildFooter(context, isDark),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Profile',
                  style: AppTypography.headlineSm(
                    color: isDark ? AppColors.darkOnSurface : const Color(0xFF191C1E),
                  ).copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'View and manage your personal and professional profile.',
                  style: AppTypography.bodySm(
                    color: isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF6B7280),
            ),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  // ================================================================
  // AVATAR & IDENTITY CARD
  // ================================================================

  Widget _buildAvatarCard(BuildContext context, UserProfileModel profile, bool isDark, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          // Avatar Stack
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                backgroundImage: (profile.profilePicture != null && profile.profilePicture!.isNotEmpty)
                    ? CachedNetworkImageProvider(profile.profilePicture!)
                    : null,
                child: (profile.profilePicture == null || profile.profilePicture!.isEmpty)
                    ? Text(
                        profile.initials,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),

              // Uploading spinner or camera icon overlay
              Positioned(
                bottom: 0,
                right: 0,
                child: Obx(() {
                  if (controller.isUploadingPicture.value) {
                    return Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    );
                  }

                  return InkWell(
                    onTap: controller.pickAndUploadPicture,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Identity Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: AppTypography.titleMd(
                    color: isDark ? AppColors.darkOnSurface : const Color(0xFF191C1E),
                    fontWeight: FontWeight.w700,
                  ).copyWith(fontSize: 17),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  style: AppTypography.bodySm(
                    color: isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),

                // Badges
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildBadge(
                      label: profile.displayRole,
                      bgColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                      textColor: const Color(0xFF2563EB),
                    ),
                    if (profile.employeeCode.isNotEmpty)
                      _buildBadge(
                        label: profile.employeeCode,
                        bgColor: isDark ? const Color(0xFF27272A) : const Color(0xFFF3F4F6),
                        textColor: isDark ? AppColors.darkOnSurface : const Color(0xFF374151),
                      ),
                    if (profile.departmentName != null && profile.departmentName!.isNotEmpty)
                      _buildBadge(
                        label: profile.departmentName!,
                        bgColor: isDark ? const Color(0xFF1E3A2F) : const Color(0xFFECFDF5),
                        textColor: const Color(0xFF059669),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ================================================================
  // SECTIONS & FIELDS
  // ================================================================

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppTypography.labelMd(
        color: isDark ? AppColors.darkOnSurface : const Color(0xFF191C1E),
        fontWeight: FontWeight.w700,
      ).copyWith(fontSize: 14),
    );
  }

  Widget _buildPersonalFields(BuildContext context, UserProfileModel profile, bool isDark, bool isMobile) {
    return Column(
      children: [
        if (isMobile) ...[
          _buildTextField(
            label: 'First Name',
            controller: controller.firstNameController,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Last Name',
            controller: controller.lastNameController,
            isDark: isDark,
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'First Name',
                  controller: controller.firstNameController,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildTextField(
                  label: 'Last Name',
                  controller: controller.lastNameController,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),

        if (isMobile) ...[
          _buildTextField(
            label: 'Email (Read-Only)',
            initialValue: profile.email,
            readOnly: true,
            isDark: isDark,
            prefixIcon: Icons.lock_outline,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Phone Number',
            controller: controller.phoneController,
            isDark: isDark,
            prefixIcon: Icons.phone_outlined,
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Email (Read-Only)',
                  initialValue: profile.email,
                  readOnly: true,
                  isDark: isDark,
                  prefixIcon: Icons.lock_outline,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildTextField(
                  label: 'Phone Number',
                  controller: controller.phoneController,
                  isDark: isDark,
                  prefixIcon: Icons.phone_outlined,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),

        // Date of birth
        Obx(() {
          final dob = controller.selectedDob.value;
          final formatted = dob != null ? DateFormat('MMM dd, yyyy').format(dob) : '';

          return InkWell(
            onTap: () => controller.selectDateOfBirth(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFD1D5DB),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cake_outlined,
                    size: 18,
                    color: isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      formatted.isNotEmpty ? formatted : 'Select Date of Birth',
                      style: AppTypography.bodyMd(
                        color: formatted.isNotEmpty
                            ? (isDark ? AppColors.darkOnSurface : AppColors.onSurface)
                            : (isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF9CA3AF)),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOrganizationFields(BuildContext context, UserProfileModel profile, bool isDark, bool isMobile) {
    return Column(
      children: [
        if (isMobile) ...[
          _buildTextField(
            label: 'Department (Read-Only)',
            initialValue: profile.departmentName ?? 'Unassigned',
            readOnly: true,
            isDark: isDark,
            prefixIcon: Icons.domain,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Designation / Job Title',
            controller: controller.designationController,
            isDark: isDark,
            prefixIcon: Icons.badge_outlined,
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Department (Read-Only)',
                  initialValue: profile.departmentName ?? 'Unassigned',
                  readOnly: true,
                  isDark: isDark,
                  prefixIcon: Icons.domain,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildTextField(
                  label: 'Designation / Job Title',
                  controller: controller.designationController,
                  isDark: isDark,
                  prefixIcon: Icons.badge_outlined,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),

        if (isMobile) ...[
          _buildTextField(
            label: 'System Role (Read-Only)',
            initialValue: profile.displayRole,
            readOnly: true,
            isDark: isDark,
            prefixIcon: Icons.security_outlined,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Employee Code (Read-Only)',
            initialValue: profile.employeeCode,
            readOnly: true,
            isDark: isDark,
            prefixIcon: Icons.pin_outlined,
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'System Role (Read-Only)',
                  initialValue: profile.displayRole,
                  readOnly: true,
                  isDark: isDark,
                  prefixIcon: Icons.security_outlined,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildTextField(
                  label: 'Employee Code (Read-Only)',
                  initialValue: profile.employeeCode,
                  readOnly: true,
                  isDark: isDark,
                  prefixIcon: Icons.pin_outlined,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAdditionalFields(BuildContext context, UserProfileModel profile, bool isDark, bool isMobile) {
    return Column(
      children: [
        _buildTextField(
          label: 'Residential Address',
          controller: controller.addressController,
          isDark: isDark,
          prefixIcon: Icons.home_outlined,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Emergency Contact Phone / Name',
          controller: controller.emergencyContactController,
          isDark: isDark,
          prefixIcon: Icons.contact_emergency_outlined,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Bio / About Me',
          controller: controller.bioController,
          isDark: isDark,
          maxLines: 3,
          prefixIcon: Icons.notes_outlined,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    bool readOnly = false,
    int maxLines = 1,
    IconData? prefixIcon,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      readOnly: readOnly,
      maxLines: maxLines,
      style: AppTypography.bodyMd(
        color: readOnly
            ? (isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF6B7280))
            : (isDark ? AppColors.darkOnSurface : AppColors.onSurface),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF6B7280),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: 18,
                color: isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF9CA3AF),
              )
            : null,
        filled: true,
        fillColor: readOnly
            ? (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF3F4F6))
            : (isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLowest),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFD1D5DB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFD1D5DB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.secondary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // FOOTER ACTIONS
  // ================================================================

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isSaving.value
                  ? null
                  : () async {
                      final success = await controller.saveProfile();
                      if (success && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
