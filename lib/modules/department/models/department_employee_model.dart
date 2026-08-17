class DepartmentEmployeeModel {
  final String id;
  final String employeeCode;
  final String name;
  final String email;
  final String designation;
  final String? profilePicture;
  final bool isActive;

  const DepartmentEmployeeModel({
    required this.id,
    this.employeeCode = '',
    required this.name,
    this.email = '',
    this.designation = '',
    this.profilePicture,
    this.isActive = true,
  });

  factory DepartmentEmployeeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final firstName = json['firstName']?.toString().trim() ?? '';
    final lastName = json['lastName']?.toString().trim() ?? '';
    final fullName = json['fullName']?.toString().trim() ?? '';
    final rawName = json['name']?.toString().trim() ?? '';
    final email = json['email']?.toString().trim() ?? '';

    String finalName = '';
    if (fullName.isNotEmpty) {
      finalName = fullName;
    } else if (rawName.isNotEmpty) {
      finalName = rawName;
    } else if (firstName.isNotEmpty || lastName.isNotEmpty) {
      finalName = '$firstName $lastName'.trim();
    } else if (email.isNotEmpty) {
      finalName = email.split('@').first;
    } else {
      finalName = 'User';
    }

    String designation = json['designation']?.toString().trim() ?? '';
    if (designation.isEmpty && json['role'] != null) {
      if (json['role'] is Map) {
        designation = (json['role']['name'] ?? json['role']['label'] ?? '').toString();
      } else {
        designation = json['role'].toString();
      }
    }

    return DepartmentEmployeeModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      employeeCode: (json['employeeCode'] ?? '').toString(),
      name: finalName,
      email: email,
      designation: designation,
      profilePicture: json['profilePicture']?.toString(),
      isActive: json['isActive'] ?? true,
    );
  }
}