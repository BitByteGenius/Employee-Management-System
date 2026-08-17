class DepartmentModel {
  final String id;
  final String name;
  final String code;
  final String description;
  final String status;
  final int headcount;
  final DepartmentAdminModel? admin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    this.description = '',
    this.status = 'active',
    this.headcount = 0,
    this.admin,
    this.createdAt,
    this.updatedAt,
  });

  factory DepartmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DepartmentModel(
      id: _string(json['_id'] ?? json['id']),
      name: _string(json['name']),
      code: _string(json['code']),
      description: _string(json['description']),
      status: _string(json['status'], fallback: 'active'),
      headcount: _int(
        json['headcount'] ??
            json['employeeCount'] ??
            json['employeesCount'],
      ),
      admin: _parseAdmin(
        json['admin'] ??
            json['departmentAdmin'] ??
            json['initialAdmin'],
      ),
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'status': status,
      'headcount': headcount,
      'admin': admin?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  DepartmentModel copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? status,
    int? headcount,
    DepartmentAdminModel? admin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      status: status ?? this.status,
      headcount: headcount ?? this.headcount,
      admin: admin ?? this.admin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _string(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) return fallback;
    return value.toString();
  }

  static int _int(dynamic value) {
    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(
      value.toString(),
    );
  }

  static DepartmentAdminModel? _parseAdmin(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is String) {
      return DepartmentAdminModel(
        id: value,
        name: 'Admin',
      );
    }

    if (value is Map<String, dynamic>) {
      return DepartmentAdminModel.fromJson(value);
    }

    return null;
  }
}

class DepartmentAdminModel {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;

  const DepartmentAdminModel({
    required this.id,
    required this.name,
    this.email = '',
    this.profilePicture,
  });

  factory DepartmentAdminModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DepartmentAdminModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (
        json['fullName'] ??
        json['name'] ??
        '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'
      ).toString().trim(),
      email: (json['email'] ?? '').toString(),
      profilePicture:
          json['profilePicture']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
    };
  }
}