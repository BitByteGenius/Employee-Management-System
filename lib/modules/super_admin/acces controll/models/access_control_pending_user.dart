class AccessControlPendingUser {
  const AccessControlPendingUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.systemRole,
    required this.createdAt,
    required this.isDeleted,
    this.assignedRole,
    this.assignedRoleId,
    this.assignedRoleLabel,
    this.department,
    this.departmentId,
    this.departmentName,
    this.profilePicture,
    this.initials = 'U',
  });

  final String id;
  final String fullName;
  final String email;
  final String systemRole;
  final String? createdAt;
  final bool isDeleted;
  final dynamic assignedRole;
  final String? assignedRoleId;
  final String? assignedRoleLabel;
  final dynamic department;
  final String? departmentId;
  final String? departmentName;
  final String? profilePicture;
  final String initials;

  /// Backward-compatible role accessor returning the system role
  String get role => systemRole;

  bool get isAdmin => systemRole.toUpperCase() == 'ADMIN';
  bool get isEmployee => systemRole.toUpperCase() == 'EMPLOYEE';
  bool get isSuperAdmin => systemRole.toUpperCase() == 'SUPER_ADMIN';

  bool get hasAssignedRole =>
      resolvedAssignedRoleId != null && resolvedAssignedRoleId!.isNotEmpty;

  bool get hasAssignedDepartment =>
      resolvedDepartmentId != null && resolvedDepartmentId!.isNotEmpty;

  String? get resolvedAssignedRoleId {
    if (assignedRoleId != null && assignedRoleId!.isNotEmpty) {
      return assignedRoleId;
    }
    if (assignedRole is Map) {
      return (assignedRole['_id'] ?? assignedRole['id'])?.toString();
    }
    return null;
  }

  String? get resolvedAssignedRoleName {
    if (assignedRoleLabel != null && assignedRoleLabel!.isNotEmpty) {
      return assignedRoleLabel;
    }
    if (assignedRole is Map) {
      return (assignedRole['label'] ?? assignedRole['name'])?.toString();
    }
    return null;
  }

  String? get resolvedDepartmentId {
    if (departmentId != null && departmentId!.isNotEmpty) {
      return departmentId;
    }
    if (department is Map) {
      return (department['_id'] ?? department['id'])?.toString();
    }
    if (department is String && department.isNotEmpty) {
      return department;
    }
    return null;
  }

  String? get resolvedDepartmentName {
    if (departmentName != null && departmentName!.isNotEmpty) {
      return departmentName;
    }
    if (department is Map) {
      return (department['name'] ?? department['code'])?.toString();
    }
    return null;
  }

  factory AccessControlPendingUser.fromJson(Map<String, dynamic> json) {
    final name = (json['fullName'] ?? json['name'] ?? 'User').toString();
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    final initials = parts.isEmpty
        ? 'U'
        : parts.take(2).map((e) => e[0].toUpperCase()).join();

    final rawSysRole = json['systemRole']?.toString().toUpperCase();
    final roleValue = json['role'];
    final roleStr = roleValue is Map
        ? (roleValue['name'] ?? roleValue['label'] ?? 'EMPLOYEE').toString().toUpperCase()
        : (roleValue ?? json['roleName'] ?? 'EMPLOYEE').toString().toUpperCase();

    final systemRole = (rawSysRole != null && rawSysRole.isNotEmpty)
        ? rawSysRole
        : (roleStr.contains('ADMIN') ? 'ADMIN' : 'EMPLOYEE');

    final assignedRoleVal = json['assignedRole'];
    final assignedRoleId = json['assignedRoleId']?.toString() ??
        (assignedRoleVal is Map
            ? (assignedRoleVal['_id'] ?? assignedRoleVal['id'])?.toString()
            : null);
    final assignedRoleLabel = json['assignedRoleLabel']?.toString() ??
        (assignedRoleVal is Map
            ? (assignedRoleVal['label'] ?? assignedRoleVal['name'])?.toString()
            : null);

    final deptVal = json['department'];
    final deptId = json['departmentId']?.toString() ??
        (deptVal is Map
            ? (deptVal['_id'] ?? deptVal['id'])?.toString()
            : (deptVal is String ? deptVal : null));
    final deptName = json['departmentName']?.toString() ??
        (deptVal is Map
            ? (deptVal['name'] ?? deptVal['code'])?.toString()
            : null);

    return AccessControlPendingUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: name,
      email: (json['email'] ?? '').toString(),
      systemRole: systemRole,
      createdAt: json['createdAt']?.toString(),
      isDeleted: json['isDeleted'] == true,
      assignedRole: assignedRoleVal,
      assignedRoleId: assignedRoleId,
      assignedRoleLabel: assignedRoleLabel,
      department: deptVal,
      departmentId: deptId,
      departmentName: deptName,
      profilePicture: (json['profilePicture'] ?? json['avatar'])?.toString(),
      initials: initials,
    );
  }
}
