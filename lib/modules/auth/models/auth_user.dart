class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.permissions = const [],
    this.accountStatus,
    this.avatar,
    this.department,
    this.departmentId,
    this.departmentName,
    this.assignedRoleLabel,
    this.designation,
    this.systemRole,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> permissions;
  final String? accountStatus;
  final String? avatar;
  final dynamic department;
  final String? departmentId;
  final String? departmentName;
  final String? assignedRoleLabel;
  final String? designation;
  final String? systemRole;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    String? parsedDeptId;
    String? parsedDeptName;
    if (json['department'] is Map) {
      final d = json['department'] as Map;
      parsedDeptId = (d['_id'] ?? d['id'])?.toString();
      parsedDeptName = (d['name'] ?? d['code'])?.toString();
    } else if (json['departmentName'] != null) {
      parsedDeptName = json['departmentName']?.toString();
      parsedDeptId = (json['departmentId'] ?? json['department'])?.toString();
    } else if (json['department'] is String) {
      parsedDeptId = json['department']?.toString();
    }

    return AuthUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? json['systemRole'] ?? 'employee').toString(),
      permissions: List<String>.from(json['permissions'] ?? const []),
      accountStatus: (json['accountStatus'] ?? json['status'])?.toString(),
      avatar: (json['avatar'] ?? json['profilePicture'])?.toString(),
      department: json['department'],
      departmentId: parsedDeptId ?? json['departmentId']?.toString(),
      departmentName: parsedDeptName ?? json['departmentName']?.toString(),
      assignedRoleLabel: (json['assignedRoleLabel'] ?? (json['assignedRole'] is Map ? json['assignedRole']['label'] : null))?.toString(),
      designation: json['designation']?.toString(),
      systemRole: (json['systemRole'] ?? json['role'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'name': name,
      'fullName': name,
      'email': email,
      'role': role,
      'systemRole': systemRole ?? role,
      'permissions': permissions,
      if (accountStatus != null) 'accountStatus': accountStatus,
      if (avatar != null) 'avatar': avatar,
      if (department != null) 'department': department,
      if (departmentId != null) 'departmentId': departmentId,
      if (departmentName != null) 'departmentName': departmentName,
      if (assignedRoleLabel != null) 'assignedRoleLabel': assignedRoleLabel,
      if (designation != null) 'designation': designation,
    };
  }
}
