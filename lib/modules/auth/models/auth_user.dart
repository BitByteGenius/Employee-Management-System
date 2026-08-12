class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.permissions = const [],
    this.accountStatus,
    this.avatar,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> permissions;
  final String? accountStatus;
  final String? avatar;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'employee').toString(),
      permissions: List<String>.from(json['permissions'] ?? const []),
      accountStatus: json['accountStatus']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'permissions': permissions,
      if (accountStatus != null) 'accountStatus': accountStatus,
      if (avatar != null) 'avatar': avatar,
    };
  }
}
