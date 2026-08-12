import 'package:flutter/material.dart';
import '../../../shared/widgets/module_list_view.dart';

class ProjectListView extends StatelessWidget {
  const ProjectListView({super.key});
  @override
  Widget build(BuildContext context) => const ModuleListView(title: 'Projects', subtitle: 'Track projects, owners, timelines, and progress.', icon: Icons.work_outline);
}
