class DeliverableModel {
  final String? filePath;
  final String? externalLink;
  final DateTime? submissionDeadline;
  final String? notes;
  final String? departmentId;

  DeliverableModel({
    this.filePath,
    this.externalLink,
    this.submissionDeadline,
    this.notes,
    this.departmentId,
  });

  factory DeliverableModel.fromJson(Map<String, dynamic> json) {
    return DeliverableModel(
      filePath: json['filePath']?.toString(),
      externalLink: json['externalLink']?.toString(),
      submissionDeadline: json['submissionDate'] != null
          ? DateTime.tryParse(json['submissionDate'].toString())
          : (json['submissionDeadline'] != null
              ? DateTime.tryParse(json['submissionDeadline'].toString())
              : (json['selectedDate'] != null
                  ? DateTime.tryParse(json['selectedDate'].toString())
                  : null)),
      notes: json['notes']?.toString(),
      departmentId: (json['departmentId'] ?? json['department'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'filePath': filePath,
    'externalLink': externalLink,
    'submissionDeadline': submissionDeadline?.toIso8601String(),
    'notes': notes,
    if (departmentId != null && departmentId!.isNotEmpty)
      'departmentId': departmentId,
  };
}