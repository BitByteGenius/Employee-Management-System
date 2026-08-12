import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
  });

  final Widget child;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 450),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null)
                Text(title!, style: Theme.of(context).textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
