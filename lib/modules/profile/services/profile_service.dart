import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_profile_model.dart';

class ProfileService {
  final ApiClient _apiClient;

  ProfileService(this._apiClient);

  /// Fetch full user profile from backend
  Future<UserProfileModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.profile);
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UserProfileModel.fromJson(data);
      }
      throw Exception(response.data?['message'] ?? 'Failed to load profile');
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to load profile';
      throw Exception(message);
    }
  }

  /// Update editable profile details
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch(
        ApiEndpoints.profile,
        data: data,
      );
      if (response.data != null && response.data['success'] == true) {
        final resData = response.data['data'] as Map<String, dynamic>;
        return UserProfileModel.fromJson(resData);
      }
      throw Exception(response.data?['message'] ?? 'Failed to update profile');
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to update profile';
      throw Exception(message);
    }
  }

  /// Upload profile avatar to Cloudinary via backend
  Future<UserProfileModel> uploadProfilePicture({
    Uint8List? bytes,
    String? filePath,
    required String fileName,
  }) async {
    MultipartFile file;
    if (bytes != null) {
      file = MultipartFile.fromBytes(bytes, filename: fileName);
    } else if (filePath != null) {
      file = await MultipartFile.fromFile(filePath, filename: fileName);
    } else {
      throw Exception('No file data provided');
    }

    final formData = FormData.fromMap({
      'avatar': file,
    });

    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.profilePicture,
        data: formData,
      );

      if (response.data != null && response.data['success'] == true) {
        final resData = response.data['data'] as Map<String, dynamic>;
        return UserProfileModel.fromJson(resData);
      }
      throw Exception(response.data?['message'] ?? 'Failed to upload profile picture');
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to upload profile picture';
      throw Exception(message);
    }
  }
}
