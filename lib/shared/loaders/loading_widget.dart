import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, __) => Container(height: 84, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: 6,
      ),
    );
  }
}
