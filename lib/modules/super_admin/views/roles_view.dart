import 'package:flutter/material.dart';
import '../../../shared/widgets/module_list_view.dart';

class RolesView extends StatelessWidget {
  const RolesView({super.key});
  @override
  Widget build(BuildContext context) => const ModuleListView(title: 'Roles', subtitle: 'Define role permission matrices and authorization rules.', icon: Icons.admin_panel_settings_outlined);
}
