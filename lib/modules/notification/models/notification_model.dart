import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String? recipient;
  final dynamic sender;
  final String title;
  final String message;
  final String type;
  final String category; // 'projects', 'system', 'team', 'task', 'general'
  final String? entityType;
  final dynamic entityId;
  final bool isRead;
  final DateTime? readAt;
  final bool isDismissed;
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final String actionType; // 'view_task', 'more_info', 'view_project', 'none'
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    this.recipient,
    this.sender,
    required this.title,
    required this.message,
    this.type = 'task_assigned',
    this.category = 'projects',
    this.entityType,
    this.entityId,
    this.isRead = false,
    this.readAt,
    this.isDismissed = false,
    this.priority = 'medium',
    this.actionType = 'none',
    this.actionUrl,
    this.metadata,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    final rawId = json['_id'] ?? json['id'] ?? '';
    final isReadVal = json['isRead'] == true || json['readAt'] != null;

    return NotificationModel(
      id: rawId.toString(),
      recipient: json['recipient']?.toString(),
      sender: json['sender'],
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'task_assigned',
      category: json['category']?.toString() ?? 'projects',
      entityType: json['entityType']?.toString(),
      entityId: json['entityId'],
      isRead: isReadVal,
      readAt: parseDate(json['readAt']),
      isDismissed: json['isDismissed'] == true,
      priority: json['priority']?.toString() ?? 'medium',
      actionType: json['actionType']?.toString() ??
          (json['entityType'] == 'Task'
              ? 'view_task'
              : (json['category'] == 'system' ? 'more_info' : 'none')),
      actionUrl: json['actionUrl']?.toString(),
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : null,
      createdAt: parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient': recipient,
      'sender': sender,
      'title': title,
      'message': message,
      'type': type,
      'category': category,
      'entityType': entityType,
      'entityId': entityId,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'isDismissed': isDismissed,
      'priority': priority,
      'actionType': actionType,
      'actionUrl': actionUrl,
      'metadata': metadata,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? recipient,
    dynamic sender,
    String? title,
    String? message,
    String? type,
    String? category,
    String? entityType,
    dynamic entityId,
    bool? isRead,
    DateTime? readAt,
    bool? isDismissed,
    String? priority,
    String? actionType,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipient: recipient ?? this.recipient,
      sender: sender ?? this.sender,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      category: category ?? this.category,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      isDismissed: isDismissed ?? this.isDismissed,
      priority: priority ?? this.priority,
      actionType: actionType ?? this.actionType,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Relative human-readable time (e.g., "Just now", "10m ago", "2h ago", "Yesterday")
  String get relativeTime {
    if (createdAt == null) return 'Just now';

    final now = DateTime.now();
    final difference = now.difference(createdAt!.toLocal());

    if (difference.inSeconds < 45) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(createdAt!.toLocal());
    }
  }

  bool get isSystem =>
      category.toLowerCase() == 'system' || type.toLowerCase().contains('system');

  bool get isProject =>
      category.toLowerCase() == 'projects' ||
      category.toLowerCase() == 'project' ||
      category.toLowerCase() == 'task' ||
      type.toLowerCase().contains('task') ||
      type.toLowerCase().contains('project');

  bool get isTeam =>
      category.toLowerCase() == 'team' || type.toLowerCase().contains('user');
}
