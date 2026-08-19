import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/modules/super_admin/projects/models/dilevariable_models.dart';

import 'package:file_picker/file_picker.dart';

class DeliverableService {
  final ApiClient _apiClient;

  DeliverableService(this._apiClient);

  /// Submits project deliverables via multipart/form-data using the central ApiClient
  Future<bool> submitDeliverable({
    required String projectId,
    required DeliverableModel deliverable,
    PlatformFile? platformFile,
    File? file,
  }) async {
    try {
      // 1. Construct FormData for multipart request
      final Map<String, dynamic> map = {
        if (deliverable.departmentId != null && deliverable.departmentId!.isNotEmpty)
          'departmentId': deliverable.departmentId,
        if (deliverable.externalLink != null && deliverable.externalLink!.isNotEmpty)
          'externalLink': deliverable.externalLink,
        if (deliverable.submissionDeadline != null)
          'selectedDate': deliverable.submissionDeadline!.toIso8601String(),
        if (deliverable.notes != null && deliverable.notes!.isNotEmpty)
          'notes': deliverable.notes,
      };

      final formData = FormData.fromMap(map);

      // 2. Append file if selected
      if (platformFile != null) {
        if (kIsWeb && platformFile.bytes != null) {
          formData.files.add(MapEntry(
            'file',
            MultipartFile.fromBytes(
              platformFile.bytes!,
              filename: platformFile.name,
            ),
          ));
        } else if (platformFile.path != null) {
          formData.files.add(MapEntry(
            'file',
            await MultipartFile.fromFile(
              platformFile.path!,
              filename: platformFile.name,
            ),
          ));
        }
      } else if (file != null) {
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last.split('\\').last,
          ),
        ));
      }

      // 3. Make POST request using ApiClient's configured dio instance
      final response = await _apiClient.dio.post(
        ApiEndpoints.projectDeliverables(projectId),
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          (response.data is Map ? response.data['success'] != false : true)) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error submitting deliverable: $e');
      rethrow;
    }
  }
}