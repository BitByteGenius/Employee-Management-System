import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/modules/department/controllers/department_controller.dart';
import 'package:tms/shared/views/placeholder_view.dart';

class DepartmentView extends GetView<DepartmentController> {
  const DepartmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderView(title: 'Departments');
  }
}
