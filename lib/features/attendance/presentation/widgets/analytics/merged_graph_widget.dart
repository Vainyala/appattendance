import 'package:appattendance/features/attendance/presentation/providers/analytics_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MergedGraph extends ConsumerWidget {
  const MergedGraph({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider).value;

    if (analytics == null) return SizedBox.shrink();

    return Column(
      children: [
        Text('Daily Network Data'),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: analytics.getNetworkSpots(),
                  isCurved: true,
                  barWidth: 4,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.download),
          onPressed: () {
            // Use analytics.toExcelRows() for export
            // Implement file save with excel package
          },
        ),
      ],
    );
  }
}
