import 'package:flutter/material.dart';
import '../../../shared/widgets/module_list_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) => const ModuleListView(title: 'Profile', subtitle: 'Edit profile, avatar, password, and personal preferences.', icon: Icons.person_outline);
}
