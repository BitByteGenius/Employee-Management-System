import 'package:flutter/material.dart';
import '../../../shared/cards/dashboard_card.dart';
import '../../../shared/charts/analytics_chart.dart';

class DashboardGrid extends StatelessWidget {
  const DashboardGrid({super.key, required this.heading, required this.stats, required this.chartTitle, required this.values});
  final String heading;
  final Map<String, String> stats;
  final String chartTitle;
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (_, constraints) {
            final columns = constraints.maxWidth > 1100 ? 4 : constraints.maxWidth > 680 ? 2 : 1;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.8,
              children: stats.entries.map((e) => DashboardCard(title: e.key, value: e.value, icon: Icons.analytics_outlined)).toList(),
            );
          }),
          const SizedBox(height: 20),
          SizedBox(height: 320, child: AnalyticsChart(title: chartTitle, values: values)),
        ],
      ),
    );
  }
}
