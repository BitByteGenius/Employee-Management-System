import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tms/core/constants/api_endpoints.dart';
import 'package:tms/core/network/api_client.dart';

class DeliverableModel {
  final String? filePath;
  final String? externalLink;
  final DateTime? submissionDeadline;
  final String? notes;

  DeliverableModel({
    this.filePath,
    this.externalLink,
    this.submissionDeadline,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'externalLink': externalLink,
        'submissionDeadline': submissionDeadline?.toIso8601String(),
        'notes': notes,
      };
}

class DeliverableService {
  final ApiClient _apiClient;

  DeliverableService(this._apiClient);

  /// Submits project deliverables via multipart/form-data using the central ApiClient
  Future<bool> submitDeliverable({
    required String projectId,
    required DeliverableModel deliverable,
    File? file, // Actual file object from FilePicker
  }) async {
    try {
      // 1. Construct FormData for multipart request
      FormData formData = FormData.fromMap({
        if (deliverable.externalLink != null && deliverable.externalLink!.isNotEmpty)
          'externalLink': deliverable.externalLink,
        if (deliverable.submissionDeadline != null)
          'selectedDate': deliverable.submissionDeadline!.toIso8601String(),
        if (deliverable.notes != null && deliverable.notes!.isNotEmpty)
          'notes': deliverable.notes,

        // 2. Append file if selected
        if (file != null)
          'file': await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
      });

      // 3. Make POST request using ApiClient's configured dio instance
      // Note: We explicitly override Content-Type header to multipart/form-data for this request
      final response = await _apiClient.dio.post(
        ApiEndpoints.projectDeliverables(projectId),
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error submitting deliverable: $e');
      return false;
    }
  }
}