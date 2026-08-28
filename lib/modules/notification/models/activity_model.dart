class ActivityModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final DateTime? createdAt;
  final String actorName;
  final String? actorEmail;
  final String? actorAvatar;
  final String? action;
  final String? entityType;
  final dynamic entityId;

  const ActivityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    this.createdAt,
    required this.actorName,
    this.actorEmail,
    this.actorAvatar,
    this.action,
    this.entityType,
    this.entityId,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    final rawId = json['_id'] ?? json['id'] ?? '';

    return ActivityModel(
      id: rawId.toString(),
      title: json['title']?.toString() ?? 'Activity',
      description: json['description']?.toString() ?? '',
      time: json['time']?.toString() ?? 'Recently',
      createdAt: parseDate(json['createdAt']),
      actorName: json['actorName']?.toString() ?? 'Team Member',
      actorEmail: json['actorEmail']?.toString(),
      actorAvatar: json['actorAvatar']?.toString(),
      action: json['action']?.toString(),
      entityType: json['entityType']?.toString(),
      entityId: json['entityId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
      'createdAt': createdAt?.toIso8601String(),
      'actorName': actorName,
      'actorEmail': actorEmail,
      'actorAvatar': actorAvatar,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
    };
  }

  String get actorInitials {
    if (actorName.trim().isEmpty) return 'U';
    final parts = actorName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return actorName.substring(0, 1).toUpperCase();
  }
}
