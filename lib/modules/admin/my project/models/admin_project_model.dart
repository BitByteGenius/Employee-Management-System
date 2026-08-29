import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tms/core/constants/app_colors.dart';

/// Deliverable / Attachment model for files & notes attached by Super Admin.
class AdminDeliverableModel {
  final String id;
  final String? filePath;
  final String? fileUrl;
  final String? fileName;
  final String? externalLink;
  final DateTime? submissionDeadline;
  final String? notes;
  final String? submittedByName;
  final DateTime? submittedAt;

  const AdminDeliverableModel({
    this.id = '',
    this.filePath,
    this.fileUrl,
    this.fileName,
    this.externalLink,
    this.submissionDeadline,
    this.notes,
    this.submittedByName,
    this.submittedAt,
  });

  bool get hasFile =>
      (fileName != null && fileName!.isNotEmpty) ||
      (fileUrl != null && fileUrl!.isNotEmpty) ||
      (filePath != null && filePath!.isNotEmpty);

  bool get hasNotes => notes != null && notes!.trim().isNotEmpty;

  String get effectiveFileUrl => fileUrl ?? filePath ?? '';

  String get displayFileName {
    if (fileName != null && fileName!.isNotEmpty) return fileName!;
    if (fileUrl != null && fileUrl!.isNotEmpty) {
      final uri = Uri.tryParse(fileUrl!);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
    }
    return 'Attached File';
  }

  factory AdminDeliverableModel.fromJson(Map<String, dynamic> json) {
    String submittedByName = '';
    if (json['submittedBy'] is Map) {
      final u = json['submittedBy'] as Map;
      submittedByName = (u['fullName'] ?? '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}').toString().trim();
    } else if (json['submittedByName'] != null) {
      submittedByName = json['submittedByName'].toString();
    }

    return AdminDeliverableModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      filePath: json['filePath']?.toString(),
      fileUrl: (json['fileUrl'] ?? json['filePath'])?.toString(),
      fileName: (json['fileName'] ?? json['name'] ?? json['originalName'])?.toString(),
      externalLink: json['externalLink']?.toString(),
      submissionDeadline: json['submissionDeadline'] != null
          ? DateTime.tryParse(json['submissionDeadline'].toString())
          : (json['selectedDate'] != null
              ? DateTime.tryParse(json['selectedDate'].toString())
              : (json['submissionDate'] != null ? DateTime.tryParse(json['submissionDate'].toString()) : null)),
      notes: (json['notes'] ?? json['description'])?.toString(),
      submittedByName: submittedByName.isNotEmpty ? submittedByName : null,
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'].toString())
          : (json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null),
    );
  }
}

/// Dynamic Project model for the Department Admin module.
/// 100% dynamic - all fields are parsed directly from backend MongoDB/API responses.
class AdminProjectModel {
  final String id;
  final String name;
  final String key;
  final String role;
  final String description;
  final String status;
  final int progress;
  final DateTime? dueDate;
  final DateTime? startDate;
  final DateTime? createdAt;
  final String? managerName;
  final String? managerId;
  final String? managerAvatar;
  final String? departmentName;
  final String? departmentId;
  final int tasksCount;
  final int completedTasksCount;
  final String tasksRatio;
  final List<AdminDeliverableModel> deliverables;
  final List<dynamic> members;

  const AdminProjectModel({
    required this.id,
    required this.name,
    this.key = '',
    this.role = '',
    this.description = '',
    this.status = 'active',
    this.progress = 0,
    this.dueDate,
    this.startDate,
    this.createdAt,
    this.managerName,
    this.managerId,
    this.managerAvatar,
    this.departmentName,
    this.departmentId,
    this.tasksCount = 0,
    this.completedTasksCount = 0,
    this.tasksRatio = '0/0',
    this.deliverables = const [],
    this.members = const [],
  });

  /// Display role or fallback to manager designation
  String get displayRole {
    if (role.trim().isNotEmpty) return role.trim();
    if (managerName != null && managerName!.isNotEmpty) return 'Lead ($managerName)';
    return 'Project Lead';
  }

  /// Has Super Admin uploaded files or deliverables
  bool get hasAttachedFiles => deliverables.any((d) => d.hasFile);

  /// Has Super Admin added notes/instructions
  bool get hasNotes =>
      description.trim().isNotEmpty || deliverables.any((d) => d.hasNotes);

  /// Primary deliverable with file
  AdminDeliverableModel? get primaryFileDeliverable {
    for (final d in deliverables) {
      if (d.hasFile) return d;
    }
    return null;
  }

  /// Combined or latest notes from deliverables or project description
  String? get displayNotes {
    for (final d in deliverables.reversed) {
      if (d.hasNotes) return d.notes;
    }
    if (description.trim().isNotEmpty) return description.trim();
    return null;
  }

  /// Normalized status key (e.g. 'active', 'planning', 'at_risk', 'completed')
  String get normalizedStatus {
    final s = status.toLowerCase().trim().replaceAll('-', '_').replaceAll(' ', '_');
    if (s.contains('risk') || s.contains('delay') || s.contains('overdue')) return 'at_risk';
    if (s.contains('plan')) return 'planning';
    if (s.contains('complete') || s.contains('done')) return 'completed';
    if (s.contains('hold')) return 'on_hold';
    return 'active';
  }

  /// Uppercase label for the badge (ACTIVE, PLANNING, AT RISK, COMPLETED)
  String get statusLabel {
    switch (normalizedStatus) {
      case 'planning':
        return 'PLANNING';
      case 'at_risk':
        return 'AT RISK';
      case 'completed':
        return 'COMPLETED';
      case 'on_hold':
        return 'ON HOLD';
      case 'active':
      default:
        return 'ACTIVE';
    }
  }

  /// Left vertical accent stripe color matching reference design
  Color get indicatorColor {
    switch (normalizedStatus) {
      case 'planning':
        return const Color(0xFF94A3B8); // Slate/Muted Blue-Gray
      case 'at_risk':
        return AppColors.error; // Red #BA1A1A / #DC2626
      case 'completed':
        return AppColors.success; // Green #16A34A
      case 'active':
      default:
        return AppColors.secondary; // Blue #0058BE
    }
  }

  /// Text color for the status badge
  Color get statusBadgeTextColor {
    switch (normalizedStatus) {
      case 'planning':
        return const Color(0xFF475569); // Darker slate
      case 'at_risk':
        return AppColors.error;
      case 'completed':
        return AppColors.success;
      case 'active':
      default:
        return AppColors.secondary;
    }
  }

  /// Background color for the status badge
  Color statusBadgeBgColor(bool isDark) {
    switch (normalizedStatus) {
      case 'planning':
        return isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      case 'at_risk':
        return isDark ? AppColors.error.withValues(alpha: 0.2) : const Color(0xFFFFE4E6);
      case 'completed':
        return isDark ? AppColors.success.withValues(alpha: 0.2) : const Color(0xFFDCFCE7);
      case 'active':
      default:
        return isDark ? AppColors.secondary.withValues(alpha: 0.2) : const Color(0xFFE0E7FF);
    }
  }

  /// Progress bar fill color matching the status
  Color get progressColor => indicatorColor;

  /// Progress fraction (0.0 to 1.0)
  double get progressFraction => (progress.clamp(0, 100)) / 100.0;

  /// Formatted percentage string (e.g. "75%")
  String get formattedProgress => '$progress%';

  /// Checks if deadline is overdue or marked at risk
  bool get isAtRiskOrOverdue {
    if (normalizedStatus == 'at_risk') return true;
    if (dueDate != null && normalizedStatus != 'completed') {
      return dueDate!.isBefore(DateTime.now());
    }
    return false;
  }

  /// Formatted deadline string (e.g. "Oct 15, 2024")
  String get formattedDeadline {
    final date = dueDate ?? createdAt ?? DateTime.now();
    try {
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return 'N/A';
    }
  }

  factory AdminProjectModel.fromJson(Map<String, dynamic> json) {
    String managerName = '';
    String managerId = '';
    String? managerAvatar;

    if (json['managerName'] != null) {
      managerName = json['managerName'].toString();
    } else if (json['manager'] is Map) {
      final m = json['manager'] as Map;
      managerId = (m['_id'] ?? m['id'] ?? '').toString();
      managerName = (m['fullName'] ?? '${m['firstName'] ?? ''} ${m['lastName'] ?? ''}'.trim()).toString();
      managerAvatar = (m['profilePicture'] ?? m['avatar'])?.toString();
      if (managerName.isEmpty && m['email'] != null) managerName = m['email'].toString();
    } else if (json['owner'] is Map) {
      final o = json['owner'] as Map;
      managerId = (o['_id'] ?? o['id'] ?? '').toString();
      managerName = (o['fullName'] ?? '${o['firstName'] ?? ''} ${o['lastName'] ?? ''}'.trim()).toString();
      managerAvatar = (o['profilePicture'] ?? o['avatar'])?.toString();
    }

    String departmentName = '';
    String departmentId = '';
    if (json['department'] is Map) {
      final d = json['department'] as Map;
      departmentId = (d['_id'] ?? d['id'] ?? '').toString();
      departmentName = (d['name'] ?? d['code'] ?? '').toString();
    } else if (json['departmentName'] != null) {
      departmentName = json['departmentName'].toString();
      departmentId = (json['departmentId'] ?? json['department'] ?? '').toString();
    } else if (json['department'] != null) {
      departmentId = json['department'].toString();
    }

    final totalTasks = _int(json['tasksCount']);
    final completedTasks = _int(json['completedTasksCount']);
    final ratio = json['tasksRatio']?.toString() ?? '$completedTasks/$totalTasks';

    final rawDeliverables = json['deliverables'];
    final deliverablesList = <AdminDeliverableModel>[];
    if (rawDeliverables is List) {
      for (final item in rawDeliverables) {
        if (item is Map<String, dynamic>) {
          deliverablesList.add(AdminDeliverableModel.fromJson(item));
        } else if (item is Map) {
          deliverablesList.add(AdminDeliverableModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final members = (json['members'] is List) ? (json['members'] as List) : [];

    return AdminProjectModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      key: (json['key'] ?? json['code'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? 'active').toString(),
      progress: _int(json['progress']),
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate'].toString()) : null,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      managerName: managerName.isNotEmpty ? managerName : null,
      managerId: managerId.isNotEmpty ? managerId : null,
      managerAvatar: managerAvatar,
      departmentName: departmentName.isNotEmpty ? departmentName : null,
      departmentId: departmentId.isNotEmpty ? departmentId : null,
      tasksCount: totalTasks,
      completedTasksCount: completedTasks,
      tasksRatio: ratio,
      deliverables: deliverablesList,
      members: members,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'key': key,
      'role': role,
      'description': description,
      'status': status,
      'progress': progress,
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (departmentId != null) 'department': departmentId,
      if (managerId != null) 'manager': managerId,
    };
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
