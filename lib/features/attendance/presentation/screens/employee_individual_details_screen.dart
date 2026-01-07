// lib/features/attendance/presentation/screens/employee_individual_details_screen.dart
// Individual Employee Details Screen (Manager View)
// Shows name, photo, email, phone, daily status, overview (pie), current month history
// Download selected period data as Excel

import 'package:appattendance/core/utils/app_colors.dart';
import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';
import 'package:appattendance/features/attendance/presentation/providers/analytics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart'; // For pie chart
import 'package:excel/excel.dart'; // For Excel export
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class EmployeeIndividualDetailsScreen extends ConsumerWidget {
  final EmployeeAnalytics employee;

  const EmployeeIndividualDetailsScreen({required this.employee, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(employee.name),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              await _exportEmployeeData(context, ref, employee);
            },
          ),
        ],
      ),
      body: analyticsAsync.when(
        data: (analytics) {
          // Find employee data from analytics (real selected period)
          final empData = analytics.employeeBreakdown.firstWhere(
            (e) => e.empId == employee.empId,
            orElse: () => employee,
          );

          // Current month history (only current month + live day)
          final currentMonth = DateTime.now();
          final monthStart = DateTime(currentMonth.year, currentMonth.month, 1);
          final history = analytics.employeeBreakdown
              .where((e) => e.empId == employee.empId)
              .toList(); // TODO: Filter by date range from analytics

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          'https://ui-avatars.com/api/?name=${empData.name}&background=random',
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        empData.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        empData.designation,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Email: example@${empData.empId.toLowerCase()}.com',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Phone: +91-XXXXXXXXXX',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Chip(
                        label: Text(
                          empData.status,
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: empData.status == 'Present'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Attendance Overview (Pie Chart for selected period)
                Text(
                  'Attendance Overview (${ref.watch(analyticsPeriodProvider).name})',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: analytics.presentDays.toDouble(),
                          color: Colors.green,
                          title: 'Present',
                        ),
                        PieChartSectionData(
                          value: analytics.absentDays.toDouble(),
                          color: Colors.red,
                          title: 'Absent',
                        ),
                        PieChartSectionData(
                          value: analytics.leaveDays.toDouble(),
                          color: Colors.blue,
                          title: 'Leave',
                        ),
                        PieChartSectionData(
                          value: analytics.lateDays.toDouble(),
                          color: Colors.orange,
                          title: 'Late',
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Attendance History (Current month only - live day tak)
                Text(
                  'Attendance History (Current Month)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: entry.status == 'Present'
                            ? Colors.green
                            : Colors.red,
                        child: Text(entry.status[0]),
                      ),
                      title: Text(entry.checkInTime),
                      subtitle: Text(
                        'Date: ${DateFormat('dd MMM').format(DateTime.now())}',
                      ), // TODO: Real date
                      trailing: Text('Projects: ${entry.projectCount}'),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _exportEmployeeData(
    BuildContext context,
    WidgetRef ref,
    EmployeeAnalytics employee,
  ) async {
    final analytics = ref.read(analyticsProvider).value;
    if (analytics == null) return;

    // Create Excel file
    final excel = Excel.createExcel();
    final sheet = excel['Employee Data'];

    // Add header row
    sheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('Designation'),
      TextCellValue('Status'),
      TextCellValue('Check-In Time'),
      TextCellValue('Projects'),
    ]);

    // Add employee data row
    sheet.appendRow([
      TextCellValue(employee.name),
      TextCellValue(employee.designation),
      TextCellValue(employee.status),
      TextCellValue(employee.checkInTime),
      TextCellValue(employee.projects.join(', ')),
    ]);

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/employee_${employee.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(path);
    await file.writeAsBytes(excel.encode()!);

    // Open file
    OpenFilex.open(path);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Employee data downloaded!')));
  }

  // Future<void> _exportEmployeeData(
  //   BuildContext context,
  //   WidgetRef ref,
  //   EmployeeAnalytics employee,
  // ) async {
  //   final analytics = ref.read(analyticsProvider).value;
  //   if (analytics == null) return;

  //   // Create Excel file
  //   final excel = Excel.createExcel();
  //   final sheet = excel['Employee Data'];

  //   // Add header row
  //   sheet.appendRow([
  //     CellValue.string('Name'),
  //     CellValue.string('Designation'),
  //     CellValue.string('Status'),
  //     CellValue.string('Check-In Time'),
  //     CellValue.string('Projects'),
  //   ]);

  //   // Add employee data row
  //   sheet.appendRow([
  //     CellValue.string(employee.name),
  //     CellValue.string(employee.designation),
  //     CellValue.string(employee.status),
  //     CellValue.string(employee.checkInTime),
  //     CellValue.string(employee.projects.join(', ')),
  //   ]);

  //   // Save file
  //   final directory = await getApplicationDocumentsDirectory();
  //   final path =
  //       '${directory.path}/employee_${employee.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
  //   final file = File(path);
  //   await file.writeAsBytes(excel.encode()!);

  //   // Open file
  //   OpenFile.open(path);

  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(SnackBar(content: Text('Employee data downloaded!')));
  // }
}

// // lib/features/attendance/presentation/screens/employee_individual_details_screen.dart
// // Individual Employee Details Screen (Manager View)
// // Shows name, photo, email, phone, daily status, overview (pie), current month history
// // Download selected period data as Excel

// import 'package:appattendance/core/utils/app_colors.dart';
// import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';
// import 'package:appattendance/features/attendance/presentation/providers/analytics_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fl_chart/fl_chart.dart'; // For pie chart
// import 'package:excel/excel.dart'; // For Excel export
// import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';
// import 'dart:io';

// class EmployeeIndividualDetailsScreen extends ConsumerWidget {
//   final EmployeeAnalytics employee;

//   const EmployeeIndividualDetailsScreen({required this.employee, super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final analyticsAsync = ref.watch(analyticsProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(employee.name),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.download),
//             onPressed: () async {
//               await _exportEmployeeData(context, ref, employee);
//             },
//           ),
//         ],
//       ),
//       body: analyticsAsync.when(
//         data: (analytics) {
//           // Find employee data from analytics (real selected period)
//           final empData = analytics.employeeBreakdown.firstWhere(
//             (e) => e.empId == employee.empId,
//             orElse: () => employee,
//           );

//           // Current month history (only current month + live day)
//           final currentMonth = DateTime.now();
//           final monthStart = DateTime(currentMonth.year, currentMonth.month, 1);
//           final history = analytics.employeeBreakdown
//               .where((e) => e.empId == employee.empId)
//               .toList(); // TODO: Filter by date range from analytics

//           return SingleChildScrollView(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Profile Header
//                 Center(
//                   child: Column(
//                     children: [
//                       CircleAvatar(
//                         radius: 50,
//                         backgroundImage: NetworkImage(
//                           'https://ui-avatars.com/api/?name=${empData.name}&background=random',
//                         ),
//                       ),
//                       SizedBox(height: 12),
//                       Text(
//                         empData.name,
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         empData.designation,
//                         style: TextStyle(fontSize: 16, color: Colors.grey),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         'Email: example@${empData.empId.toLowerCase()}.com',
//                         style: TextStyle(fontSize: 14),
//                       ),
//                       Text(
//                         'Phone: +91-XXXXXXXXXX',
//                         style: TextStyle(fontSize: 14),
//                       ),
//                       SizedBox(height: 8),
//                       Chip(
//                         label: Text(
//                           empData.status,
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         backgroundColor: empData.status == 'Present'
//                             ? Colors.green
//                             : Colors.red,
//                       ),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: 32),

//                 // Attendance Overview (Pie Chart for selected period)
//                 Text(
//                   'Attendance Overview (${ref.watch(analyticsPeriodProvider).name})',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 16),
//                 SizedBox(
//                   height: 200,
//                   child: PieChart(
//                     PieChartData(
//                       sections: [
//                         PieChartSectionData(
//                           value: analytics.presentDays.toDouble(),
//                           color: Colors.green,
//                           title: 'Present',
//                         ),
//                         PieChartSectionData(
//                           value: analytics.absentDays.toDouble(),
//                           color: Colors.red,
//                           title: 'Absent',
//                         ),
//                         PieChartSectionData(
//                           value: analytics.leaveDays.toDouble(),
//                           color: Colors.blue,
//                           title: 'Leave',
//                         ),
//                         PieChartSectionData(
//                           value: analytics.lateDays.toDouble(),
//                           color: Colors.orange,
//                           title: 'Late',
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: 32),

//                 // Attendance History (Current month only - live day tak)
//                 Text(
//                   'Attendance History (Current Month)',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 16),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: history.length,
//                   itemBuilder: (context, index) {
//                     final entry = history[index];
//                     return ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor: entry.status == 'Present'
//                             ? Colors.green
//                             : Colors.red,
//                         child: Text(entry.status[0]),
//                       ),
//                       title: Text(entry.checkInTime),
//                       subtitle: Text(
//                         'Date: ${DateFormat('dd MMM').format(DateTime.now())}',
//                       ), // TODO: Real date
//                       trailing: Text('Projects: ${entry.projectCount}'),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//         loading: () => Center(child: CircularProgressIndicator()),
//         error: (e, s) => Center(child: Text('Error: $e')),
//       ),
//     );
//   }

//   Future<void> _exportEmployeeData(
//     BuildContext context,
//     WidgetRef ref,
//     EmployeeAnalytics employee,
//   ) async {
//     final analytics = ref.read(analyticsProvider).value;
//     if (analytics == null) return;

//     // Create simple Excel with employee data
//     final excel = Excel.createExcel();
//     final sheet = excel['Employee Data'];

//     sheet.appendRow(['Name', employee.name]);
//     sheet.appendRow(['Designation', employee.designation]);
//     sheet.appendRow(['Status', employee.status]);
//     sheet.appendRow(['Check-In Time', employee.checkInTime]);
//     sheet.appendRow(['Projects', employee.projects.join(', ')]);

//     // Save file
//     final directory = await getApplicationDocumentsDirectory();
//     final path =
//         '${directory.path}/employee_${employee.name}_${DateTime.now().toString()}.xlsx';
//     final file = File(path);
//     await file.writeAsBytes(excel.encode()!);

//     OpenFile.open(path);

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Downloading employee data...')));
//   }
// }
