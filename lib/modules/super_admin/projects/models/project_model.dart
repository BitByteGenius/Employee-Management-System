import 'package:intl/intl.dart';
import 'package:tms/modules/super_admin/projects/models/dilevariable_models.dart';

class ProjectModel {
  final String id;
  final String name;
  final String key;
  final String description;
  final String status;
  final int progress;
  final int tasksCount;
  final int completedTasksCount;
  final String tasksRatio;
  final String? managerName;
  final String? departmentName;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final List<DeliverableModel> deliverables;

  const ProjectModel({
    required this.id,
    required this.name,
    this.key = '',
    this.description = '',
    this.status = 'active',
    this.progress = 0,
    this.tasksCount = 0,
    this.completedTasksCount = 0,
    this.tasksRatio = '0/0',
    this.managerName,
    this.departmentName,
    this.dueDate,
    this.createdAt,
    this.deliverables = const [],
  });

  bool get isActive => status.toLowerCase() == 'active' || status.toLowerCase() == 'in_progress';

  String get formattedProgress => '$progress%';

  String get formattedDate {
    final date = dueDate ?? createdAt ?? DateTime.now();
    try {
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return 'N/A';
    }
  }

  bool get hasFileAttachment => deliverables.any((d) =>
      (d.filePath != null && d.filePath!.isNotEmpty) ||
      (d.fileUrl != null && d.fileUrl!.isNotEmpty) ||
      (d.externalLink != null && d.externalLink!.isNotEmpty));

  DeliverableModel? get primaryDeliverable {
    if (deliverables.isEmpty) return null;
    for (final d in deliverables) {
      if ((d.filePath != null && d.filePath!.isNotEmpty) ||
          (d.fileUrl != null && d.fileUrl!.isNotEmpty) ||
          (d.externalLink != null && d.externalLink!.isNotEmpty)) {
        return d;
      }
    }
    return deliverables.first;
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    String managerName = '';
    if (json['managerName'] != null) {
      managerName = json['managerName'].toString();
    } else if (json['manager'] is Map) {
      final m = json['manager'] as Map;
      managerName = (m['fullName'] ?? '${m['firstName'] ?? ''} ${m['lastName'] ?? ''}'.trim()).toString();
      if (managerName.isEmpty && m['email'] != null) managerName = m['email'].toString();
    } else if (json['owner'] is Map) {
      final o = json['owner'] as Map;
      managerName = (o['fullName'] ?? '${o['firstName'] ?? ''} ${o['lastName'] ?? ''}'.trim()).toString();
    }

    String departmentName = '';
    if (json['department'] is Map) {
      departmentName = (json['department']['name'] ?? '').toString();
    } else if (json['departmentName'] != null) {
      departmentName = json['departmentName'].toString();
    }

    final totalTasks = _int(json['tasksCount']);
    final completedTasks = _int(json['completedTasksCount']);
    final ratio = json['tasksRatio']?.toString() ?? '$completedTasks/$totalTasks';

    final rawDeliverables = json['deliverables'];
    final deliverablesList = <DeliverableModel>[];
    if (rawDeliverables is List) {
      for (final item in rawDeliverables) {
        if (item is Map<String, dynamic>) {
          deliverablesList.add(DeliverableModel.fromJson(item));
        } else if (item is Map) {
          deliverablesList.add(DeliverableModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return ProjectModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      key: (json['key'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? 'active').toString(),
      progress: _int(json['progress']),
      tasksCount: totalTasks,
      completedTasksCount: completedTasks,
      tasksRatio: ratio,
      managerName: managerName.isNotEmpty ? managerName : null,
      departmentName: departmentName.isNotEmpty ? departmentName : null,
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      deliverables: deliverablesList,
    );
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ProjectListResult {
  final List<ProjectModel> projects;
  final int page;
  final int totalPages;
  final int total;

  const ProjectListResult({
    required this.projects,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}
