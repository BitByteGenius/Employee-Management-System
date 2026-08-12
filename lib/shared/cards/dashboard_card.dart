import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key, required this.title, required this.value, required this.icon, this.color});
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.lg),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: (color ?? Theme.of(context).colorScheme.primary).withValues(alpha: .12), child: Icon(icon, color: color)),
            const SizedBox(width: AppPadding.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
