// lib/features/attendance/presentation/screens/attendance_screen.dart
// Manager Attendance Analytics Full Screen
// Features: Period selector (6-month limit), stats row, toggle (Merge Graph / Employee Overview / Active Projects), download
// Employee card click → individual details (current month history)
// Active project card click → project details (black background)
// Uses Riverpod for state, freezed models, and db_helper for data

import 'package:appattendance/core/utils/app_colors.dart';
import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';
import 'package:appattendance/features/attendance/presentation/providers/analytics_provider.dart';
import 'package:appattendance/features/attendance/presentation/widgets/analytics/active_projects.dart';
import 'package:appattendance/features/attendance/presentation/widgets/analytics/employee_overview_widget.dart';
import 'package:appattendance/features/attendance/presentation/widgets/analytics/graph_toggle.dart'
    as toggle;
import 'package:appattendance/features/attendance/presentation/widgets/analytics/merged_graph_widget.dart';
import 'package:appattendance/features/attendance/presentation/widgets/analytics/period_selector_widget.dart';
import 'package:appattendance/features/attendance/presentation/widgets/analytics/statistics_cards.dart';
import 'package:appattendance/features/attendance/presentation/screens/employee_individual_details_screen.dart';
import 'package:appattendance/features/attendance/presentation/screens/project_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  toggle.ViewMode _currentMode = toggle.ViewMode.mergeGraph; // Toggle state

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Analytics'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => ref.read(analyticsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: analyticsAsync.when(
        data: (analytics) {
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // 1. Top Period Selector (daily/weekly/monthly/quarterly - 6-month limit)
              PeriodSelector(),

              SizedBox(height: 16),

              // 2. Stats Row (team, present, leave, absent, onTime, late - period-based)
              StatisticsCards(),

              SizedBox(height: 16),

              // 3. Toggle (Merge Graph / Employee Overview / Active Projects)
              toggle.GraphToggle(
                currentMode: _currentMode,
                onModeChanged: (mode) {
                  setState(() {
                    _currentMode = mode;
                  });
                },
              ),

              SizedBox(height: 16),

              // Conditional content based on toggle state
              if (_currentMode == toggle.ViewMode.mergeGraph) MergedGraph(),
              if (_currentMode == toggle.ViewMode.employeeOverview)
                EmployeeOverview(),
              if (_currentMode == toggle.ViewMode.activeProjects)
                ActiveProjects(),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
