// lib/features/leaves/presentation/widgets/month_filter_widget.dart
// Final upgraded version: Dynamic year + month picker (Dec 30, 2025)
// Configurable range, current month default, dark mode, production-ready

import 'package:appattendance/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthFilterWidget extends StatefulWidget {
  final String? initialMonth; // Optional: "December 2025"
  final ValueChanged<String> onMonthChanged;

  const MonthFilterWidget({
    super.key,
    this.initialMonth,
    required this.onMonthChanged,
  });

  @override
  State<MonthFilterWidget> createState() => _MonthFilterWidgetState();
}

class _MonthFilterWidgetState extends State<MonthFilterWidget> {
  late String _selectedMonth;
  late int _selectedYear;

  // Configurable: Kitne months pehle se dikhaaye (default 24 months)
  static const int monthsToShow = 24;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    // Default to current month if not provided
    _selectedMonth = widget.initialMonth ?? DateFormat('MMMM yyyy').format(now);
    _selectedYear = int.tryParse(_selectedMonth.split(' ').last) ?? now.year;
  }

  List<String> _getMonthsForYear(int year) {
    final months = <String>[];
    for (int month = 1; month <= 12; month++) {
      final date = DateTime(year, month, 1);
      months.add(DateFormat('MMMM yyyy').format(date));
    }
    return months.reversed.toList(); // Latest month first
  }

  void _showYearPicker() async {
    final selectedYear = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Year'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: YearPicker(
            firstDate: DateTime.now().subtract(
              const Duration(days: 365 * 5),
            ), // 5 years back
            lastDate: DateTime.now().add(
              const Duration(days: 365),
            ), // 1 year forward
            initialDate: DateTime(_selectedYear),
            selectedDate: DateTime(_selectedYear),
            onChanged: (date) {
              Navigator.pop(context, date.year);
            },
          ),
        ),
      ),
    );

    if (selectedYear != null && selectedYear != _selectedYear) {
      setState(() {
        _selectedYear = selectedYear;
        // Auto-select first month of selected year
        final date = DateTime(selectedYear, DateTime.now().month, 1);
        _selectedMonth = DateFormat('MMMM yyyy').format(date);
        widget.onMonthChanged(_selectedMonth);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final months = _getMonthsForYear(_selectedYear);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year Selector Button
          GestureDetector(
            onTap: _showYearPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Year: $_selectedYear',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down, color: AppColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal Month Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: months.map((month) {
                final isSelected = month == _selectedMonth;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedMonth = month);
                      widget.onMonthChanged(month);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        month,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// // lib/features/leaves/presentation/widgets/month_filter_widget.dart
// // Final upgraded version: Dynamic year + month picker (Dec 30, 2025)
// // Configurable range, current month default, dark mode, production-ready

// import 'package:appattendance/core/utils/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class MonthFilterWidget extends StatefulWidget {
//   final String? initialMonth; // Optional: "December 2025"
//   final ValueChanged<String> onMonthChanged;

//   const MonthFilterWidget({
//     super.key,
//     this.initialMonth,
//     required this.onMonthChanged,
//   });

//   @override
//   State<MonthFilterWidget> createState() => _MonthFilterWidgetState();
// }

// class _MonthFilterWidgetState extends State<MonthFilterWidget> {
//   late String _selectedMonth;
//   late int _selectedYear;

//   // Configurable: Kitne months pehle se dikhaaye (default 24 months)
//   static const int monthsToShow = 24;

//   @override
//   void initState() {
//     super.initState();
//     final now = DateTime.now();

//     // Default to current month if not provided
//     _selectedMonth = widget.initialMonth ?? DateFormat('MMMM yyyy').format(now);
//     _selectedYear = int.tryParse(_selectedMonth.split(' ').last) ?? now.year;
//   }

//   List<String> _getMonthsForYear(int year) {
//     final months = <String>[];
//     for (int month = 1; month <= 12; month++) {
//       final date = DateTime(year, month, 1);
//       months.add(DateFormat('MMMM yyyy').format(date));
//     }
//     return months.reversed.toList(); // Latest month first
//   }

//   void _showYearPicker() async {
//     final selectedYear = await showDialog<int>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Select Year'),
//         content: SizedBox(
//           width: double.maxFinite,
//           height: 300,
//           child: YearPicker(
//             firstDate: DateTime.now().subtract(
//               const Duration(days: 365 * 5),
//             ), // 5 years back
//             lastDate: DateTime.now().add(
//               const Duration(days: 365),
//             ), // 1 year forward
//             initialDate: DateTime(_selectedYear),
//             selectedDate: DateTime(_selectedYear),
//             onChanged: (date) {
//               Navigator.pop(context, date.year);
//             },
//           ),
//         ),
//       ),
//     );

//     if (selectedYear != null && selectedYear != _selectedYear) {
//       setState(() {
//         _selectedYear = selectedYear;
//         // Auto-select first month of selected year
//         final date = DateTime(selectedYear, DateTime.now().month, 1);
//         _selectedMonth = DateFormat('MMMM yyyy').format(date);
//         widget.onMonthChanged(_selectedMonth);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final months = _getMonthsForYear(_selectedYear);

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Year Selector Button
//           GestureDetector(
//             onTap: _showYearPicker,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               decoration: BoxDecoration(
//                 color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(30),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 8,
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Year: $_selectedYear',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Icon(Icons.arrow_drop_down, color: AppColors.primary),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Horizontal Month Chips
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: months.map((month) {
//                 final isSelected = month == _selectedMonth;
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 12),
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() => _selectedMonth = month);
//                       widget.onMonthChanged(month);
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 10,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? AppColors.primary
//                             : Colors.grey.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(30),
//                         boxShadow: isSelected
//                             ? [
//                                 BoxShadow(
//                                   color: AppColors.primary.withOpacity(0.4),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ]
//                             : null,
//                       ),
//                       child: Text(
//                         month,
//                         style: TextStyle(
//                           color: isSelected
//                               ? Colors.white
//                               : (isDark ? Colors.white70 : Colors.black87),
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// // lib/features/leaves/presentation/widgets/month_filter_widget.dart
// // Updated: Dynamic months based on current date (Dec 24, 2025), no hardcoded values, production-ready, dark mode support, flexible for future

// import 'package:appattendance/core/utils/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class MonthFilterWidget extends StatelessWidget {
//   final String selectedMonth;
//   final ValueChanged<String> onMonthChanged;

//   const MonthFilterWidget({
//     super.key,
//     required this.selectedMonth,
//     required this.onMonthChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now(); // Current date: Dec 24, 2025

//     // Generate last 6 months dynamically (including current month)
//     final months = List.generate(6, (index) {
//       final date = DateTime(now.year, now.month - index, 1);
//       return DateFormat('MMMM yyyy').format(date);
//     }).reversed.toList(); // Latest month first

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: months.map((month) {
//             final isSelected = month == selectedMonth;
//             return Padding(
//               padding: const EdgeInsets.only(right: 12),
//               child: GestureDetector(
//                 onTap: () => onMonthChanged(month),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 10,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? AppColors.primary
//                         : Colors.grey.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(30),
//                     boxShadow: isSelected
//                         ? [
//                             BoxShadow(
//                               color: AppColors.primary.withOpacity(0.4),
//                               blurRadius: 8,
//                               offset: const Offset(0, 4),
//                             ),
//                           ]
//                         : null,
//                   ),
//                   child: Text(
//                     month,
//                     style: TextStyle(
//                       color: isSelected
//                           ? Colors.white
//                           : (Theme.of(context).brightness == Brightness.dark
//                                 ? Colors.white70
//                                 : Colors.black87),
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }

// // lib/features/leaves/presentation/widgets/month_filter_widget.dart

// import 'package:appattendance/core/utils/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class MonthFilterWidget extends StatelessWidget {
//   final String selectedMonth;
//   final ValueChanged<String> onMonthChanged;

//   const MonthFilterWidget({
//     super.key,
//     required this.selectedMonth,
//     required this.onMonthChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final months = [
//       DateFormat('MMMM yyyy').format(now),
//       DateFormat('MMMM yyyy').format(now.subtract(const Duration(days: 30))),
//       DateFormat('MMMM yyyy').format(now.subtract(const Duration(days: 60))),
//     ];

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: months.map((month) {
//             final isSelected = month == selectedMonth;
//             return Padding(
//               padding: const EdgeInsets.only(right: 12),
//               child: GestureDetector(
//                 onTap: () => onMonthChanged(month),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 10,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? AppColors.primary
//                         : Colors.grey.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: Text(
//                     month,
//                     style: TextStyle(
//                       color: isSelected
//                           ? Colors.white
//                           : (Theme.of(context).brightness == Brightness.dark
//                                 ? Colors.white70
//                                 : Colors.black87),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }
