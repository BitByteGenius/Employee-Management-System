class CreateDepartmentRequest {
  final String name;
  final String code;
  final String description;
  final String? initialAdminId;

  const CreateDepartmentRequest({
    required this.name,
    required this.code,
    this.description = '',
    this.initialAdminId,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'name': name.trim(),
      'code': code.trim().toUpperCase(),
      'description': description.trim(),
    };

    if (initialAdminId != null &&
        initialAdminId!.isNotEmpty) {
      data['initialAdminId'] = initialAdminId;
    }

    return data;
  }
}