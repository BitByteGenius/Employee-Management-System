class AccessControlPendingUser {
  const AccessControlPendingUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.createdAt,
    this.department,
    this.initials = 'U',
  });

  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? createdAt;
  final dynamic department;
  final String initials;

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isEmployee => role.toLowerCase() == 'employee';

  factory AccessControlPendingUser.fromJson(Map<String, dynamic> json) {
    final name = (json['fullName'] ?? json['name'] ?? 'User').toString();
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    final initials = parts.isEmpty
        ? 'U'
        : parts.take(2).map((e) => e[0].toUpperCase()).join();

    return AccessControlPendingUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: name,
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'employee').toString(),
      createdAt: json['createdAt']?.toString(),
      department: json['department'],
      initials: initials,
    );
  }
}
