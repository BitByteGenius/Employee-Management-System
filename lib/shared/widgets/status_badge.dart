import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(label),
      backgroundColor: color.withValues(alpha: .12),
      side: BorderSide(color: color.withValues(alpha: .25)),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
}
