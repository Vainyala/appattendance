import 'dart:io';

import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';
import 'package:appattendance/features/attendance/presentation/providers/analytics_provider.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class ExportAttendanceButton extends ConsumerWidget {
  const ExportAttendanceButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final analytics = ref.read(analyticsProvider).value;
        if (analytics == null) return;

        final csvData = analytics.toExcelRows(); // Use extension
        final csvString = const ListToCsvConverter().convert(csvData);

        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/attendance_${DateTime.now().toString()}.csv';
        final file = File(path);
        await file.writeAsString(csvString);

        OpenFilex.open(path);
      },
      child: Text('Export Monthly Sheet'),
    );
  }
}
