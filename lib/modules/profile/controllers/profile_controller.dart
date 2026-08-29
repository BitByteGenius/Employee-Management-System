import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/storage_service.dart';
import '../../admin/dashboard/controllers/admin_shell_controller.dart';
import '../../employee/dashboard/controllers/employee_dashboard_controller.dart';
import '../models/user_profile_model.dart';
import '../services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService;

  ProfileController(this._profileService);

  final userProfile = Rxn<UserProfileModel>();
  final isLoading = false.obs;
  final isSaving = false.obs;
  final isUploadingPicture = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  // Text Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final designationController = TextEditingController();
  final addressController = TextEditingController();
  final bioController = TextEditingController();
  final emergencyContactController = TextEditingController();

  final selectedDob = Rxn<DateTime>();

  StorageService get _storage => Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    designationController.dispose();
    addressController.dispose();
    bioController.dispose();
    emergencyContactController.dispose();
    super.onClose();
  }

  /// Load profile data from backend
  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final profile = await _profileService.getProfile();
      userProfile.value = profile;
      _populateFields(profile);
      await _syncWithSession(profile);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
      // Fallback to local storage if network fails initially
      final localUser = _storage.getUser();
      if (localUser != null) {
        final profile = UserProfileModel.fromJson(localUser);
        userProfile.value = profile;
        _populateFields(profile);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _populateFields(UserProfileModel profile) {
    firstNameController.text = profile.firstName;
    lastNameController.text = profile.lastName;
    phoneController.text = profile.phone ?? '';
    designationController.text = profile.designation ?? '';
    addressController.text = profile.address ?? '';
    bioController.text = profile.bio ?? '';
    emergencyContactController.text = profile.emergencyContact ?? '';
    selectedDob.value = profile.dateOfBirth;
  }

  /// Select date of birth via Material date picker
  Future<void> selectDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = selectedDob.value ?? DateTime(now.year - 25, 1, 1);
    final firstDate = DateTime(1940);
    final lastDate = DateTime(now.year - 15);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.secondary,
                    onPrimary: Colors.white,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.darkOnSurface,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.secondary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.onSurface,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDob.value = picked;
    }
  }

  /// Pick and upload avatar image to Cloudinary
  Future<void> pickAndUploadPicture() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      isUploadingPicture.value = true;

      final Uint8List? fileBytes = file.bytes;
      final String? filePath = kIsWeb ? null : file.path;

      final updatedProfile = await _profileService.uploadProfilePicture(
        bytes: fileBytes,
        filePath: filePath,
        fileName: file.name,
      );

      userProfile.value = updatedProfile;
      await _syncWithSession(updatedProfile);

      Get.snackbar(
        'Success',
        'Profile picture updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDCFCE7),
        colorText: const Color(0xFF166534),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Upload Failed',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isUploadingPicture.value = false;
    }
  }

  /// Save profile updates to backend
  Future<bool> saveProfile() async {
    if (firstNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'First name cannot be empty.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    isSaving.value = true;
    errorMessage.value = '';

    try {
      final updateData = <String, dynamic>{
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'designation': designationController.text.trim(),
        'address': addressController.text.trim(),
        'dateOfBirth': selectedDob.value?.toIso8601String(),
        'bio': bioController.text.trim(),
        'emergencyContact': emergencyContactController.text.trim(),
      };

      final updatedProfile = await _profileService.updateProfile(updateData);
      userProfile.value = updatedProfile;
      await _syncWithSession(updatedProfile);

      Get.snackbar(
        'Profile Updated',
        'Your personal details have been saved successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDCFCE7),
        colorText: const Color(0xFF166534),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
      Get.snackbar(
        'Update Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Synchronize updated user profile data into persistent storage and active shell controllers
  Future<void> _syncWithSession(UserProfileModel profile) async {
    final jsonMap = profile.toJson();
    await _storage.saveUser(jsonMap);

    // Sync with AdminShellController if active
    if (Get.isRegistered<AdminShellController>()) {
      final adminCtrl = Get.find<AdminShellController>();
      adminCtrl.userName.value = profile.fullName;
      adminCtrl.userEmail.value = profile.email;
      adminCtrl.userAvatarUrl.value = profile.profilePicture;
      if (profile.designation != null && profile.designation!.isNotEmpty) {
        adminCtrl.userRoleDisplay.value = profile.designation!;
      }
    }

    // Sync with EmployeeDashboardController if active
    if (Get.isRegistered<EmployeeDashboardController>()) {
      final empCtrl = Get.find<EmployeeDashboardController>();
      empCtrl.userName.value = profile.fullName;
      empCtrl.userAvatarUrl.value = profile.profilePicture ?? '';
      if (profile.designation != null && profile.designation!.isNotEmpty) {
        empCtrl.userRoleDisplay.value = profile.designation!;
      }
    }
  }
}
