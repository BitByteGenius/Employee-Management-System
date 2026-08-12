import 'package:flutter/material.dart';
import '../../../shared/widgets/module_list_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) => const ModuleListView(title: 'Settings', subtitle: 'Theme, language, notifications, and security preferences.', icon: Icons.settings_outlined);
}
