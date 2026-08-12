import 'package:flutter/material.dart';
import '../../../shared/widgets/module_list_view.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});
  @override
  Widget build(BuildContext context) => const ModuleListView(title: 'Reports', subtitle: 'Workload, project progress, productivity, and analytics exports.', icon: Icons.bar_chart_outlined);
}
