// lib/features/leaves/presentation/widgets/apply_leave_date_time_section.dart
// Final error-free version: No path conflict, safe BuildContext usage
// Dec 30, 2025 - Production-ready, dark mode, clean

import 'package:appattendance/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ApplyLeaveDateTimeSection extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final TimeOfDay? fromTime;
  final TimeOfDay? toTime;
  final bool isHalfDayFrom;
  final bool isHalfDayTo;
  final VoidCallback onFromDateTap;
  final VoidCallback onToDateTap;
  final VoidCallback onFromTimeTap;
  final VoidCallback onToTimeTap;
  final ValueChanged<bool> onHalfDayFromChanged;
  final ValueChanged<bool> onHalfDayToChanged;

  const ApplyLeaveDateTimeSection({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.fromTime,
    required this.toTime,
    required this.isHalfDayFrom,
    required this.isHalfDayTo,
    required this.onFromDateTap,
    required this.onToDateTap,
    required this.onFromTimeTap,
    required this.onToTimeTap,
    required this.onHalfDayFromChanged,
    required this.onHalfDayToChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDatePicker(context, 'From Date', fromDate, onFromDateTap),
        const SizedBox(height: 16),
        _buildTimePicker(context, 'From Time', fromTime, onFromTimeTap),
        SwitchListTile(
          title: const Text('Half Day From'),
          value: isHalfDayFrom,
          onChanged: onHalfDayFromChanged,
        ),
        const SizedBox(height: 16),
        _buildDatePicker(context, 'To Date', toDate, onToDateTap),
        const SizedBox(height: 16),
        _buildTimePicker(context, 'To Time', toTime, onToTimeTap),
        SwitchListTile(
          title: const Text('Half Day To'),
          value: isHalfDayTo,
          onChanged: onHalfDayToChanged,
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    BuildContext buildContext,
    String label,
    DateTime? date,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          date == null ? 'Select Date' : DateFormat('dd/MM/yyyy').format(date),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext buildContext,
    String label,
    TimeOfDay? time,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          time == null
              ? 'Select Time'
              : time.format(buildContext), // Safe BuildContext
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
// // lib/features/leaves/presentation/widgets/apply_leave_date_time_section.dart
// import 'package:appattendance/core/utils/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ApplyLeaveDateTimeSection extends StatelessWidget {
//   final DateTime? fromDate;
//   final DateTime? toDate;
//   final TimeOfDay? fromTime;
//   final TimeOfDay? toTime;
//   final bool isHalfDayFrom;
//   final bool isHalfDayTo;
//   final VoidCallback onFromDateTap;
//   final VoidCallback onToDateTap;
//   final VoidCallback onFromTimeTap;
//   final VoidCallback onToTimeTap;
//   final ValueChanged<bool> onHalfDayFromChanged;
//   final ValueChanged<bool> onHalfDayToChanged;

//   const ApplyLeaveDateTimeSection({
//     super.key,
//     required this.fromDate,
//     required this.toDate,
//     required this.fromTime,
//     required this.toTime,
//     required this.isHalfDayFrom,
//     required this.isHalfDayTo,
//     required this.onFromDateTap,
//     required this.onToDateTap,
//     required this.onFromTimeTap,
//     required this.onToTimeTap,
//     required this.onHalfDayFromChanged,
//     required this.onHalfDayToChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildDatePicker('From Date', fromDate, onFromDateTap),
//         const SizedBox(height: 16),
//         _buildTimePicker('From Time', fromTime, onFromTimeTap),
//         SwitchListTile(
//           title: const Text('Half Day From'),
//           value: isHalfDayFrom,
//           onChanged: onHalfDayFromChanged,
//         ),
//         const SizedBox(height: 16),
//         _buildDatePicker('To Date', toDate, onToDateTap),
//         const SizedBox(height: 16),
//         _buildTimePicker('To Time', toTime, onToTimeTap),
//         SwitchListTile(
//           title: const Text('Half Day To'),
//           value: isHalfDayTo,
//           onChanged: onHalfDayToChanged,
//         ),
//       ],
//     );
//   }

//   Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: InputDecorator(
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//         ),
//         child: Text(
//           date == null ? 'Select Date' : DateFormat('dd/MM/yyyy').format(date),
//           style: const TextStyle(fontSize: 16),
//         ),
//       ),
//     );
//   }

//   Widget _buildTimePicker(
//     BuildContext buildContext,
//     label,
//     TimeOfDay? time,
//     VoidCallback onTap,
//   ) {
//     return InkWell(
//       onTap: onTap,
//       child: InputDecorator(
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//         ),
//         child: Text(
//           time == null ? 'Select Time' : time.format(buildContext),
//           style: const TextStyle(fontSize: 16),
//         ),
//       ),
//     );
//   }
// }
