import 'package:appattendance/core/database/db_helper.dart';
import 'package:appattendance/features/attendance/data/repositories/analytics_repository.dart';
import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';
import 'package:intl/intl.dart';

class AttendanceAnalyticsRepositoryImpl
    implements AttendanceAnalyticsRepository {
  final DBHelper dbHelper;

  AttendanceAnalyticsRepositoryImpl(this.dbHelper);

  @override
  Future<AnalyticsModel> getAnalytics({
    required AnalyticsPeriod period,
    required String empId,
  }) async {
    final db = await dbHelper.database;

    // Calculate period dates (last 6 months limit)
    DateTime end = DateTime.now();
    DateTime start = switch (period) {
      AnalyticsPeriod.daily => end,
      AnalyticsPeriod.weekly => end.subtract(const Duration(days: 7)),
      AnalyticsPeriod.monthly => DateTime(end.year, end.month, 1),
      AnalyticsPeriod.quarterly => DateTime(
        end.year,
        ((end.month - 1) ~/ 3) * 3 + 1,
        1,
      ),
    };
    final sixMonthsAgo = end.subtract(const Duration(days: 180));
    start = start.isBefore(sixMonthsAgo) ? sixMonthsAgo : start;

    // Fetch raw analytics data (per-employee stats)
    final rawAnalytics = await db.query(
      'attendance_analytics',
      where: 'emp_id = ? AND att_date BETWEEN ? AND ?',
      whereArgs: [
        empId,
        DateFormat('yyyy-MM-dd').format(start),
        DateFormat('yyyy-MM-dd').format(end),
      ],
      orderBy: 'att_date ASC',
    );

    // Fetch team members (only for manager)
    final teamMembers = await db.query(
      'employee_master',
      where: 'reporting_manager_id = ?',
      whereArgs: [empId],
    );

    // Fetch active projects (for manager)
    // final activeProjectsRows = await db.query(
    //   'project_master',
    //   where: 'mng_emp_id = ? AND status = ?',
    //   whereArgs: [empId, 'active'],
    // );

    // Pending counts (real DB)
    final pendingLeaves = await dbHelper.getPendingLeavesCount(empId);
    final pendingRegularisations = await dbHelper
        .getPendingRegularisationsCount(empId);

    // Aggregate team stats
    Map<String, int> teamStats = {
      'team': teamMembers.length,
      'present': 0,
      'leave': 0,
      'absent': 0,
      'onTime': 0,
      'late': 0,
    };

    for (var record in rawAnalytics) {
      final attType = record['att_type'] as String?;

      if (attType == 'Present') {
        teamStats['present'] = (teamStats['present'] ?? 0) + 1;
        teamStats['onTime'] =
            (teamStats['onTime'] ?? 0) + ((record['on_time'] as int?) ?? 0);
        teamStats['late'] =
            (teamStats['late'] ?? 0) + ((record['late'] as int?) ?? 0);
      } else if (attType == 'Leave') {
        teamStats['leave'] = (teamStats['leave'] ?? 0) + 1;
      } else {
        teamStats['absent'] = (teamStats['absent'] ?? 0) + 1;
      }
    }

    // Percentages
    Map<String, double> teamPercentages = {};
    teamStats.forEach((key, value) {
      if (key != 'team') {
        teamPercentages[key] = teamStats['team']! > 0
            ? (value / teamStats['team']! * 100)
            : 0.0;
      }
    });

    // Graph data (real hourly count - from first_checkin)
    Map<String, List<double>> graphDataRaw = {'network': List.filled(6, 0.0)};
    List<String> graphLabels = ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];

    for (var record in rawAnalytics) {
      final checkIn = record['first_checkin'] as String?;
      if (checkIn != null) {
        final hour = int.tryParse(checkIn.split(':')[0]) ?? 9;
        final index = (hour - 9) ~/ 2; // 9-10 → 0, 11-12 → 1, etc.
        if (index >= 0 && index < 6) {
          graphDataRaw['network']![index] += 1;
        }
      }
    }

    // Insights (dynamic)
    List<String> insights = [];
    final presentPct = teamPercentages['present'] ?? 0.0;
    if (presentPct < 70) insights.add('Attendance needs improvement');
    if ((teamStats['late'] ?? 0) > 5)
      insights.add('High late arrivals - review schedules');

    // Employee breakdown (real data)
    List<EmployeeAnalytics> employeeBreakdown = teamMembers.map((emp) {
      final empId = emp['emp_id'] as String;
      final todayRecord = rawAnalytics.firstWhere(
        (r) =>
            r['emp_id'] == empId &&
            r['att_date'] == DateFormat('yyyy-MM-dd').format(DateTime.now()),
        orElse: () => {},
      );

      return EmployeeAnalytics(
        empId: empId,
        name: emp['emp_name'] as String,
        designation: emp['designation'] as String? ?? 'Employee',
        status: todayRecord.isNotEmpty
            ? (todayRecord['att_type'] as String? ?? 'Absent')
            : 'Absent',
        checkInTime: todayRecord.isNotEmpty
            ? (todayRecord['first_checkin'] as String? ?? 'N/A')
            : 'N/A',
        projects: [], // TODO: Real from employee_mapped_projects
        projectCount: 0,
      );
    }).toList();

    // Active projects (real data)
    // List<ProjectAnalytics> activeProjects = activeProjectsRows.map((proj) {
    //   return ProjectAnalytics(
    //     projectId: proj['project_id'] as String,
    //     name: proj['project_name'] as String,
    //     description: proj['project_description'] as String? ?? '',
    //     status: proj['status'] as String? ?? 'ACTIVE',
    //     priority: proj['priority'] as String? ?? 'HIGH',
    //     progress: (proj['progress'] as num?)?.toDouble() ?? 0.0,
    //     teamSize: (proj['team_size'] as int?) ?? 0,
    //     totalTasks: (proj['total_tasks'] as int?) ?? 0,
    //     daysLeft: (proj['days_left'] as int?) ?? 0,
    //     teamMembers: [], // TODO: Real from join
    //   );
    // }).toList();

    return AnalyticsModel(
      period: period,
      startDate: start,
      endDate: end,
      teamStats: teamStats,
      teamPercentages: teamPercentages,
      employeeBreakdown: employeeBreakdown,
      graphDataRaw: graphDataRaw,
      graphLabels: graphLabels,
      insights: insights,
      // activeProjects: activeProjects,
      totalDays: end.difference(start).inDays + 1,
      presentDays: teamStats['present']!,
      absentDays: teamStats['absent']!,
      leaveDays: teamStats['leave']!,
      lateDays: teamStats['late']!,
      onTimeDays: teamStats['onTime']!,
      dailyAvgHours: 8.0, // TODO: Real avg from DB
      monthlyAvgHours: 160.0, // TODO: Real
      pendingRegularisations: pendingRegularisations,
      pendingLeaves: pendingLeaves,
    );
  }
}
