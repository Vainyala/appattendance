// lib/features/team/domain/models/team_model.dart
// FINAL Refined Version (31 Dec 2025) - Manager View + Screenshots Compatible
// Fixed: Class name consistent, status as enum, computed helpers, projects list
// No hardcoding - All from DB joins (user + attendance + projects)

import 'package:appattendance/features/attendance/domain/models/attendance_model.dart';
import 'package:appattendance/features/auth/domain/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_model.freezed.dart';
part 'team_model.g.dart';

@freezed
class TeamMemberAnalytics with _$TeamMemberAnalytics {
  const TeamMemberAnalytics._();

  const factory TeamMemberAnalytics({
    required String empId, // emp_id (PK)
    required String name,
    String? designation,
    String? email,
    String? phone,
    @Default(UserStatus.active) UserStatus status, // From user_model enum
    String? profilePhoto, // Profile photo or generated
    DateTime? joinDate,
    String? department,
    @Default([]) List<String> assignedProjects, // Project names/IDs
    @Default([])
    @JsonKey(fromJson: _attendanceListFromJson, toJson: _attendanceListToJson)
    List<AttendanceModel>
    attendanceHistory, // Filtered history (e.g., current month)
  }) = _TeamMemberAnalytics;

  factory TeamMemberAnalytics.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberAnalyticsFromJson(json);

  // Computed helpers for UI (manager cards)
  String get shortName => name.split(' ').first;
  String get displayStatus =>
      status == UserStatus.active ? 'Active' : status.name.toUpperCase();
  Color get statusColor {
    return switch (status) {
      UserStatus.active => Colors.green,
      UserStatus.inactive => Colors.grey,
      UserStatus.suspended => Colors.orange,
      UserStatus.terminated => Colors.red,
    };
  }

  String get avatarInitial => name.isNotEmpty ? name[0].toUpperCase() : '?';
  String get avatarFallback =>
      profilePhoto ??
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(shortName)}&background=random';

  // Attendance stats (computed from history)
  int get presentCount => attendanceHistory.where((a) => a.isPresent).length;
  int get lateCount => attendanceHistory.where((a) => a.isLate).length;
  int get absentCount => attendanceHistory
      .where((a) => !a.isPresent && a.leaveType == null)
      .length;
  double get attendancePercentage {
    if (attendanceHistory.isEmpty) return 0.0;
    return (presentCount / attendanceHistory.length) * 100;
  }

  String get attendanceSummary =>
      '${presentCount} Present • ${lateCount} Late • ${absentCount} Absent';
}

// JSON Helpers (unchanged - perfect)
List<AttendanceModel> _attendanceListFromJson(List<dynamic>? list) {
  if (list == null) return [];
  return list
      .map((item) => AttendanceModel.fromJson(item as Map<String, dynamic>))
      .toList();
}

List<Map<String, dynamic>> _attendanceListToJson(List<AttendanceModel> list) {
  return list.map((item) => item.toJson()).toList();
}
