import 'package:flutter/material.dart';
import '../../../shared/widgets/module_list_view.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});
  @override
  Widget build(BuildContext context) => const ModuleListView(title: 'Users', subtitle: 'Approve accounts, assign roles, and manage permissions.', icon: Icons.people_outline);
}
