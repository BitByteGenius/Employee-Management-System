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
    final firstName =
        json['firstName']?.toString() ?? '';

    final lastName =
        json['lastName']?.toString() ?? '';

    final generatedName =
        '$firstName $lastName'.trim();

    return DepartmentEmployeeModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      employeeCode:
          (json['employeeCode'] ?? '').toString(),
      name: (
        json['fullName'] ??
        json['name'] ??
        generatedName
      ).toString(),
      email:
          (json['email'] ?? '').toString(),
      designation:
          (json['designation'] ?? '').toString(),
      profilePicture:
          json['profilePicture']?.toString(),
      isActive:
          json['isActive'] ?? true,
    );
  }
}