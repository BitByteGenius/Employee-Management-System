import 'package:flutter/material.dart';
import 'empty_state.dart';

class ModuleListView extends StatelessWidget {
  const ModuleListView({super.key, required this.title, required this.subtitle, required this.icon});
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(title: title, message: subtitle, icon: icon),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Create')),
    );
  }
}
