import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tms/core/constants/app_colors.dart';

class EmployeeTaskModel {
  final String id;
  final String title;
  final String description;
  final String projectId;
  final String projectName;
  final String projectKey;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final List<Map<String, dynamic>> attachments;
  final DateTime? createdAt;

  const EmployeeTaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.projectId = '',
    this.projectName = '',
    this.projectKey = '',
    this.status = 'todo',
    this.priority = 'medium',
    this.dueDate,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.attachments = const [],
    this.createdAt,
  });

  factory EmployeeTaskModel.fromJson(Map<String, dynamic> json) {
    String pId = '';
    String pName = '';
    String pKey = '';

    if (json['project'] is Map) {
      final p = json['project'] as Map;
      pId = (p['_id'] ?? p['id'] ?? '').toString();
      pName = (p['name'] ?? '').toString();
      pKey = (p['key'] ?? '').toString();
    } else if (json['project'] != null) {
      pId = json['project'].toString();
    }

    final rawAttachments = json['attachments'];
    List<Map<String, dynamic>> parsedAttachments = [];
    if (rawAttachments is List) {
      parsedAttachments = rawAttachments.map((a) => Map<String, dynamic>.from(a as Map)).toList();
    }

    DateTime? parsedDue;
    if (json['dueDate'] != null) {
      parsedDue = DateTime.tryParse(json['dueDate'].toString());
    }

    DateTime? parsedCreated;
    if (json['createdAt'] != null) {
      parsedCreated = DateTime.tryParse(json['createdAt'].toString());
    }

    return EmployeeTaskModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['task'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      projectId: pId,
      projectName: pName.isNotEmpty ? pName : 'Project Assignment',
      projectKey: pKey,
      status: (json['status'] ?? 'todo').toString().toLowerCase(),
      priority: (json['priority'] ?? 'medium').toString().toLowerCase(),
      dueDate: parsedDue,
      fileUrl: json['fileUrl']?.toString(),
      fileName: json['fileName']?.toString(),
      fileSize: json['fileSize'] is int ? json['fileSize'] as int : null,
      attachments: parsedAttachments,
      createdAt: parsedCreated,
    );
  }

  bool get hasAttachment =>
      (fileUrl != null && fileUrl!.isNotEmpty) ||
      (fileName != null && fileName!.isNotEmpty) ||
      attachments.isNotEmpty;

  bool get isCompleted => status == 'completed' || status == 'done';
  bool get isInProgress => status == 'in_progress' || status == 'started';
  bool get isTodo => status == 'todo' || status == 'pending';

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  String get statusLabel {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'blocked':
        return 'Blocked';
      case 'review':
        return 'In Review';
      case 'todo':
      default:
        return 'To Do';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'in_progress':
        return AppColors.secondary;
      case 'completed':
        return AppColors.success;
      case 'blocked':
        return AppColors.error;
      case 'review':
        return const Color(0xFFF59E0B);
      case 'todo':
      default:
        return const Color(0xFF64748B);
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 'urgent':
        return const Color(0xFFDC2626);
      case 'high':
        return const Color(0xFFEA580C);
      case 'low':
        return const Color(0xFF16A34A);
      case 'medium':
      default:
        return const Color(0xFF2563EB);
    }
  }

  String get formattedDueDate {
    if (dueDate == null) return 'No Deadline';
    return DateFormat('MMM dd, yyyy').format(dueDate!);
  }
}
