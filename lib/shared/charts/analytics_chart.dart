import 'package:flutter/material.dart';

class AnalyticsChart extends StatelessWidget {
  const AnalyticsChart({super.key, required this.title, required this.values});
  final String title;
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final max = values.fold<double>(1, (a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: values
                    .map((value) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FractionallySizedBox(
                              heightFactor: (value / max).clamp(.08, 1),
                              alignment: Alignment.bottomCenter,
                              child: DecoratedBox(decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(6))),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
