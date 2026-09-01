import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/activity_model.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  /// Fetch paginated notifications with optional category and read status filters
  Future<NotificationFetchResult> fetchNotifications({
    int page = 1,
    int limit = 20,
    String? category,
    bool? isRead,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (category != null && category.isNotEmpty && category != 'all') {
        queryParams['category'] = category;
      }

      if (isRead != null) {
        queryParams['isRead'] = isRead;
      }

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.notifications,
        queryParameters: queryParams,
      );

      final body = response.data;
      if (body == null || body['success'] != true) {
        throw Exception(body?['message'] ?? 'Failed to load notifications');
      }

      final rawData = body['data'];
      final List<NotificationModel> notifications = [];

      if (rawData is List) {
        for (final item in rawData) {
          if (item is Map<String, dynamic>) {
            notifications.add(NotificationModel.fromJson(item));
          }
        }
      }

      final unreadCount = body['unreadCount'] is int
          ? body['unreadCount'] as int
          : (body['unreadCount'] != null
              ? int.tryParse(body['unreadCount'].toString()) ?? 0
              : 0);

      final paginationMap = body['pagination'] is Map<String, dynamic>
          ? body['pagination'] as Map<String, dynamic>
          : null;

      final totalPages = paginationMap?['totalPages'] is int
          ? paginationMap!['totalPages'] as int
          : 1;

      return NotificationFetchResult(
        notifications: notifications,
        unreadCount: unreadCount,
        totalPages: totalPages,
        page: page,
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  /// Get real-time unread notification count
  Future<int> fetchUnreadCount() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.unreadNotificationsCount,
      );

      final body = response.data;
      if (body != null && body['success'] == true) {
        if (body['count'] is int) return body['count'] as int;
        if (body['data'] is Map && body['data']['count'] is int) {
          return body['data']['count'] as int;
        }
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Mark a single notification as read
  Future<NotificationModel?> markAsRead(String id) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiEndpoints.markNotificationRead(id),
      );

      final body = response.data;
      if (body != null && body['success'] == true && body['data'] is Map<String, dynamic>) {
        return NotificationModel.fromJson(body['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Mark all notifications as read for current user
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiEndpoints.markAllNotificationsRead,
      );

      final body = response.data;
      return body?['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Dismiss / Delete a notification
  Future<bool> dismissNotification(String id) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiEndpoints.dismissNotification(id),
      );

      final body = response.data;
      return body?['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Fetch recent activities stream
  Future<List<ActivityModel>> fetchRecentActivities({int limit = 10}) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.recentActivity,
        queryParameters: {'limit': limit},
      );

      final body = response.data;
      if (body == null || body['success'] != true) {
        return [];
      }

      final rawData = body['data'];
      final List<ActivityModel> activities = [];

      if (rawData is List) {
        for (final item in rawData) {
          if (item is Map<String, dynamic>) {
            activities.add(ActivityModel.fromJson(item));
          }
        }
      }

      return activities;
    } catch (_) {
      return [];
    }
  }
}

class NotificationFetchResult {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int totalPages;
  final int page;

  const NotificationFetchResult({
    required this.notifications,
    required this.unreadCount,
    required this.totalPages,
    required this.page,
  });
}
