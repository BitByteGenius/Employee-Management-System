import 'package:flutter/material.dart';
import '../../../shared/widgets/module_list_view.dart';

class DepartmentListView extends StatelessWidget {
  const DepartmentListView({super.key});
  @override
  Widget build(BuildContext context) => const ModuleListView(title: 'Departments', subtitle: 'Create departments, assign heads, and monitor teams.', icon: Icons.account_tree_outlined);
}
