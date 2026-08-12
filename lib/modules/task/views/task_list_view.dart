import 'package:flutter/material.dart';
import '../../../shared/widgets/module_list_view.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({super.key});
  @override
  Widget build(BuildContext context) => const ModuleListView(title: 'Tasks', subtitle: 'Manage assigned work, approvals, priorities, and deadlines.', icon: Icons.task_alt_outlined);
}
