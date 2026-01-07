// lib/features/dashboard/presentation/providers/dashboard_notifier.dart
// FINAL FIXED & ROLE-BASED VERSION - January 05, 2026
// Table name fixed: attendance_master → employee_attendance
// Role-based data loading (personal for employee, team for manager)
// Error handling, loading, refresh support

import 'package:appattendance/core/database/db_helper.dart';
import 'package:appattendance/features/auth/domain/models/user_model.dart';
import 'package:appattendance/features/auth/domain/models/user_extension.dart';
import 'package:appattendance/features/auth/domain/models/user_role.dart';
import 'package:appattendance/features/auth/domain/models/user_db_mapper.dart';
import 'package:appattendance/features/auth/presentation/providers/auth_provider.dart';
import 'package:appattendance/features/attendance/domain/models/attendance_model.dart';
import 'package:appattendance/features/regularisation/presentation/providers/view_mode_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class DashboardState {
  final UserModel? user;
  final List<AttendanceModel> todayAttendance;
  final int teamSize;
  final int presentToday;
  final String? welcomeMessage;
  final bool isLoading;

  DashboardState({
    this.user,
    this.todayAttendance = const [],
    this.teamSize = 0,
    this.presentToday = 0,
    this.welcomeMessage,
    this.isLoading = false,
  });

  DashboardState copyWith({
    UserModel? user,
    List<AttendanceModel>? todayAttendance,
    int? teamSize,
    int? presentToday,
    String? welcomeMessage,
    bool? isLoading,
  }) {
    return DashboardState(
      user: user ?? this.user,
      todayAttendance: todayAttendance ?? this.todayAttendance,
      teamSize: teamSize ?? this.teamSize,
      presentToday: presentToday ?? this.presentToday,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardState>>(
      (ref) => DashboardNotifier(ref),
    );

class DashboardNotifier extends StateNotifier<AsyncValue<DashboardState>> {
  final Ref ref;

  DashboardNotifier(this.ref) : super(const AsyncLoading()) {
    ref.listen(viewModeProvider, (_, __) {
      loadDashboard();
    });
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = const AsyncLoading();

    try {
      final userAsync = ref.read(authProvider);
      if (userAsync is AsyncError) {
        state = AsyncError(userAsync.error!, userAsync.stackTrace!);
        return;
      }
      final user = userAsync.value;
      if (user == null) {
        state = AsyncError('User not logged in', StackTrace.current);
        return;
      }

      final db = await DBHelper.instance.database;
      final today = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(today);

      // Role-based attendance fetch
      List<Map<String, dynamic>> attendanceRows = [];
      int teamSize = 0;
      int presentToday = 0;

      if (user.isManagerial) {
        // Manager: Fetch team members
        final teamRows = await db.query(
          'employee_master',
          where: 'reporting_manager_id = ?',
          whereArgs: [user.empId],
        );
        teamSize = teamRows.length;

        if (teamSize > 0) {
          final empIds = teamRows.map((m) => m['emp_id'] as String).toList();
          final placeholders = List.filled(teamSize, '?').join(',');

          // Team attendance today
          attendanceRows = await db.query(
            'employee_attendance', // FIXED: Correct table name
            where: 'att_date = ? AND emp_id IN ($placeholders)',
            whereArgs: [todayStr, ...empIds],
            orderBy: 'att_timestamp ASC',
          );

          // Count present (checkIn today)
          final presentQuery = await db.rawQuery(
            '''
            SELECT COUNT(DISTINCT emp_id) as count
            FROM employee_attendance
            WHERE att_date = ? AND att_status = 'checkIn' AND emp_id IN ($placeholders)
            ''',
            [todayStr, ...empIds],
          );
          presentToday = presentQuery.first['count'] as int? ?? 0;
        }
      } else {
        // Employee: Personal attendance only
        attendanceRows = await db.query(
          'employee_attendance', // FIXED: Correct table name
          where: 'emp_id = ? AND att_date = ?',
          whereArgs: [user.empId, todayStr],
          orderBy: 'att_timestamp ASC',
        );
      }

      // Convert to model
      final todayAttendance = attendanceRows.map((row) {
        return AttendanceModel(
          attId: row['att_id'] as String,
          empId: row['emp_id'] as String,
          timestamp: DateTime.parse(row['att_timestamp'] as String),
          attendanceDate: DateTime.parse(row['att_date'] as String),
          status: _mapAttendanceStatus(row['att_status'] as String),
          latitude: row['att_latitude'] as double?,
          longitude: row['att_longitude'] as double?,
          geofenceName: row['att_geofence_name'] as String?,
          projectId: row['project_id'] as String?,
          notes: row['att_notes'] as String?,
        );
      }).toList();

      final welcome = user.isManagerial
          ? "Welcome, ${user.shortName} (Manager)"
          : "Welcome back, ${user.shortName}";

      state = AsyncData(
        DashboardState(
          user: user,
          todayAttendance: todayAttendance,
          teamSize: teamSize,
          presentToday: presentToday,
          welcomeMessage: welcome,
        ),
      );
    } catch (e, stack) {
      state = AsyncError('Failed to load dashboard: $e', stack);
    }
  }

  // Pull-to-refresh support
  Future<void> refresh() async {
    await loadDashboard();
  }

  AttendanceStatus _mapAttendanceStatus(String status) {
    return AttendanceStatus.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == status.toLowerCase(),
      orElse: () => AttendanceStatus.checkIn,
    );
  }
}
