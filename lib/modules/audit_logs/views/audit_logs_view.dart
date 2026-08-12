import 'package:flutter/material.dart';
import '../../../shared/widgets/module_list_view.dart';

class AuditLogsView extends StatelessWidget {
  const AuditLogsView({super.key});
  @override
  Widget build(BuildContext context) => const ModuleListView(title: 'Audit Logs', subtitle: 'Review security-sensitive actions and workflow history.', icon: Icons.history_outlined);
}
