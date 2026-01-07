import 'package:appattendance/core/utils/string_extensions.dart';
import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';
import 'package:appattendance/features/attendance/presentation/providers/analytics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(analyticsPeriodProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: AnalyticsPeriod.values.map((p) {
        return FilterChip(
          label: Text(p.name.capitalize()),
          selected: period == p,
          onSelected: (selected) {
            if (selected) ref.read(analyticsProvider.notifier).changePeriod(p);
          },
          selectedColor: Colors.blue,
          backgroundColor: Colors.grey[200],
        );
      }).toList(),
    );
  }
}
