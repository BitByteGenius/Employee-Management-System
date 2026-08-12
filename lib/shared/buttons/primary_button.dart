import 'package:flutter/material.dart';

/// A primary, full-width button for major actions.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;
  final double? elevation;
  final ButtonStyle? style;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.padding,
    this.elevation,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style ??
            ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: padding ?? const EdgeInsets.symmetric(vertical: 16.0),
              elevation: elevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
        child: Text(text),
      ),
    );
  }
}
