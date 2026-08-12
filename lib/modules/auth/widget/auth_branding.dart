import 'package:flutter/material.dart';

class AuthBranding extends StatelessWidget {
  const AuthBranding({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;

    return Container(
      color: color.primaryContainer.withValues(alpha: 0.35),
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 120, color: color.primary),
          const SizedBox(height: 24),
          Text(
            'Task Management',
            style: text.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Manage projects, teams, and tasks from one role-aware dashboard.',
            style: text.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
