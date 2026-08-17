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