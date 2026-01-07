import 'package:appattendance/features/attendance/presentation/providers/analytics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsCards extends ConsumerWidget {
  const StatisticsCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return analyticsAsync.when(
      data: (analytics) {
        final stats = analytics.teamStats;
        final pct = analytics.teamPercentages;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatCard('Team', '${stats['team']}', Colors.blue),
            _StatCard(
              'Present',
              '${stats['present']} (${pct['present']?.toStringAsFixed(0)}%)',
              Colors.green,
            ),
            _StatCard('Leave', '${stats['leave']}', Colors.blue),
            _StatCard('Absent', '${stats['absent']}', Colors.red),
            _StatCard('OnTime', '${stats['onTime']}', Colors.greenAccent),
            _StatCard('Late', '${stats['late']}', Colors.orange),
          ],
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (e, s) => Text('Error'),
    );
  }
}

Widget _StatCard(String label, String value, Color color) {
  return Card(
    color: color.withOpacity(0.1),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );
}
