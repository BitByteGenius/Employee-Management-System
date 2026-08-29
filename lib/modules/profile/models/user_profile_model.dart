class UserProfileModel {
  final String id;
  final String employeeCode;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String? phone;
  final String? designation;
  final String? address;
  final DateTime? dateOfBirth;
  final String? bio;
  final String? emergencyContact;
  final String? profilePicture;
  final String systemRole;
  final String? assignedRoleLabel;
  final String? departmentName;
  final String? departmentId;
  final String status;
  final bool isActive;
  final DateTime? createdAt;

  const UserProfileModel({
    required this.id,
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    this.phone,
    this.designation,
    this.address,
    this.dateOfBirth,
    this.bio,
    this.emergencyContact,
    this.profilePicture,
    this.systemRole = 'EMPLOYEE',
    this.assignedRoleLabel,
    this.departmentName,
    this.departmentId,
    this.status = 'approved',
    this.isActive = true,
    this.createdAt,
  });

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    if (fullName.isNotEmpty) {
      final parts = fullName.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }
    if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return 'U';
  }

  String get displayRole {
    final norm = systemRole.toUpperCase();
    if (norm == 'SUPER_ADMIN') return 'Super Admin';
    if (norm == 'ADMIN') return 'Department Admin';
    if (assignedRoleLabel != null && assignedRoleLabel!.isNotEmpty) {
      return assignedRoleLabel!;
    }
    return 'Employee';
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
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

    DateTime? dob;
    if (json['dateOfBirth'] != null) {
      dob = DateTime.tryParse(json['dateOfBirth'].toString());
    }

    DateTime? created;
    if (json['createdAt'] != null) {
      created = DateTime.tryParse(json['createdAt'].toString());
    }

    final first = (json['firstName'] ?? '').toString();
    final last = (json['lastName'] ?? '').toString();
    final full = (json['fullName'] ?? json['name'] ?? '$first $last'.trim()).toString();

    return UserProfileModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      employeeCode: (json['employeeCode'] ?? '').toString(),
      firstName: first,
      lastName: last,
      fullName: full.isNotEmpty ? full : 'User',
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      designation: json['designation']?.toString(),
      address: json['address']?.toString(),
      dateOfBirth: dob,
      bio: json['bio']?.toString(),
      emergencyContact: json['emergencyContact']?.toString(),
      profilePicture: (json['profilePicture'] ?? json['avatar'])?.toString(),
      systemRole: (json['systemRole'] ?? json['role'] ?? 'EMPLOYEE').toString(),
      assignedRoleLabel: (json['assignedRoleLabel'] ?? (json['assignedRole'] is Map ? json['assignedRole']['label'] : null))?.toString(),
      departmentName: parsedDeptName,
      departmentId: parsedDeptId,
      status: (json['status'] ?? json['accountStatus'] ?? 'approved').toString(),
      isActive: json['isActive'] == true || json['isActive'] == null,
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'employeeCode': employeeCode,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'name': fullName,
      'email': email,
      'phone': phone,
      'designation': designation,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'bio': bio,
      'emergencyContact': emergencyContact,
      'profilePicture': profilePicture,
      'avatar': profilePicture,
      'systemRole': systemRole,
      'role': systemRole,
      'assignedRoleLabel': assignedRoleLabel,
      'departmentName': departmentName,
      'departmentId': departmentId,
      'status': status,
      'accountStatus': status,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? employeeCode,
    String? firstName,
    String? lastName,
    String? fullName,
    String? email,
    String? phone,
    String? designation,
    String? address,
    DateTime? dateOfBirth,
    String? bio,
    String? emergencyContact,
    String? profilePicture,
    String? systemRole,
    String? assignedRoleLabel,
    String? departmentName,
    String? departmentId,
    String? status,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      designation: designation ?? this.designation,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      profilePicture: profilePicture ?? this.profilePicture,
      systemRole: systemRole ?? this.systemRole,
      assignedRoleLabel: assignedRoleLabel ?? this.assignedRoleLabel,
      departmentName: departmentName ?? this.departmentName,
      departmentId: departmentId ?? this.departmentId,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
