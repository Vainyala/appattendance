// lib/features/projects/domain/models/project_model.dart
// FINAL MERGED & UPGRADED VERSION - January 07, 2026
// ProjectModel now covers both core project data + analytics fields (teamSize, totalTasks, daysLeft, progress, teamMembers)
// No need for separate ProjectAnalytics - one model for everything
// Null-safe, role-based helpers, aligned with latest dummy data & table

import 'package:appattendance/features/team/domain/models/team_model.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_model.freezed.dart';
part 'project_model.g.dart';

enum ProjectStatus { active, inactive, completed, onHold, cancelled }

enum ProjectPriority { urgent, high, medium, low }

@freezed
class ProjectModel with _$ProjectModel {
  const ProjectModel._();

  const factory ProjectModel({
    required String projectId,
    required String orgShortName,
    required String projectName,
    String? projectSite,
    String? clientName,
    String? clientLocation,
    String? clientContact,
    String? mngName,
    String? mngEmail,
    String? mngContact,
    String? projectDescription,
    String? projectTechstack,
    String? projectAssignedDate,
    String? estdStartDate,
    String? estdEndDate,
    String? estdEffort,
    String? estdCost,
    @Default(ProjectStatus.active) ProjectStatus status,
    @Default(ProjectPriority.high) ProjectPriority priority,
    @Default(0.0) double progress, // 0.0 to 100.0
    @Default(0) int teamSize, // ← From analytics
    @Default(0) int totalTasks, // ← From analytics
    @Default(0) int completedTasks, // ← From analytics
    @Default(0) int daysLeft, // ← From analytics
    // @Default([]) List<String> teamMemberIds, // empIds
    // @Default([]) List<String> teamMemberNames, // Names (manager view ke liye)
    // Replace old teamMemberNames/teamMemberIds
    @Default([]) List<TeamMemberAnalytics> teamMembers,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProjectModel;

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  // Computed helpers for UI
  String get displayStatus => status.name.toUpperCase();
  String get displayPriority => priority.name.toUpperCase();
  String get progressString => '${progress.toStringAsFixed(1)}%';
  bool get isActive => status == ProjectStatus.active;
  String get formattedDaysLeft =>
      daysLeft > 0 ? '$daysLeft days left' : 'Overdue';
}

@freezed
class MappedProject with _$MappedProject {
  const MappedProject._();
  const factory MappedProject({
    required String empId,
    required String projectId,
    required String mappingStatus,
    required ProjectModel project,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MappedProject;
  factory MappedProject.fromJson(Map<String, dynamic> json) =>
      _$MappedProjectFromJson(json);
}

// Extension for extra helpers
extension ProjectModelExtension on ProjectModel {
  Color get priorityColor {
    return switch (priority) {
      ProjectPriority.urgent => Colors.red,
      ProjectPriority.high => Colors.orange,
      ProjectPriority.medium => Colors.yellow,
      ProjectPriority.low => Colors.green,
    };
  }

  Color get statusColor {
    return switch (status) {
      ProjectStatus.active => Colors.green,
      ProjectStatus.completed => Colors.blue,
      ProjectStatus.onHold => Colors.orange,
      ProjectStatus.cancelled => Colors.red,
      ProjectStatus.inactive => Colors.grey,
    };
  }
}

// DB Factory (null-safe, fully aligned with latest table + dummy data)
ProjectModel projectFromDB(Map<String, dynamic> row) {
  return ProjectModel(
    projectId: row['project_id'] as String? ?? '',
    orgShortName: row['org_short_name'] as String? ?? 'NUTANTEK',
    projectName: row['project_name'] as String? ?? 'Unnamed Project',
    projectSite: row['project_site'] as String?,
    clientName: row['client_name'] as String?,
    clientLocation: row['client_location'] as String?,
    clientContact: row['client_contact'] as String?,
    mngName: row['mng_name'] as String?,
    mngEmail: row['mng_email'] as String?,
    mngContact: row['mng_contact'] as String?,
    projectDescription: row['project_description'] as String?,
    projectTechstack: row['project_techstack'] as String?,
    projectAssignedDate: row['project_assigned_date'] as String?,
    estdStartDate: row['estd_start_date'] as String?,
    estdEndDate: row['estd_end_date'] as String?,
    estdEffort: row['estd_effort'] as String?,
    estdCost: row['estd_cost'] as String?,
    status: _mapProjectStatus(row['status'] as String? ?? 'active'),
    priority: _mapProjectPriority(row['priority'] as String? ?? 'HIGH'),
    progress: (row['progress'] as num?)?.toDouble() ?? 0.0,
    teamSize: row['team_size'] as int? ?? 0,
    totalTasks: row['total_tasks'] as int? ?? 0,
    completedTasks: row['completed_tasks'] as int? ?? 0,
    daysLeft: row['days_left'] as int? ?? 0,
    // teamMemberIds: [], // Populate from join query
    // teamMemberNames: [], // Populate from join query
    startDate: _parseDate(row['start_date'] as String?),
    endDate: _parseDate(row['end_date'] as String?),
    createdAt: _parseDate(row['created_at'] as String?),
    updatedAt: _parseDate(row['updated_at'] as String?),
  );
}

ProjectStatus _mapProjectStatus(String? status) {
  final lower = (status ?? '').toLowerCase();
  return switch (lower) {
    'inactive' => ProjectStatus.inactive,
    'completed' => ProjectStatus.completed,
    'onhold' => ProjectStatus.onHold,
    'cancelled' => ProjectStatus.cancelled,
    _ => ProjectStatus.active,
  };
}

ProjectPriority _mapProjectPriority(String? priority) {
  final lower = (priority ?? '').toLowerCase();
  return switch (lower) {
    'urgent' => ProjectPriority.urgent,
    'medium' => ProjectPriority.medium,
    'low' => ProjectPriority.low,
    _ => ProjectPriority.high,
  };
}

DateTime? _parseDate(String? dateStr) {
  if (dateStr == null) return null;
  try {
    return DateTime.parse(dateStr);
  } catch (_) {
    return null;
  }
}

// // lib/features/projects/domain/models/project_model.dart
// // FINAL Refined Version (31 Dec 2025)
// // Screenshot Compatible: Active Projects Cards + Detail Screen
// // Added: status, priority, progress, teamSize, tasks, daysLeft, teamMembers (names list)
// // No hardcoding - All from DB joins

// import 'package:flutter/material.dart';
// import 'package:freezed_annotation/freezed_annotation.dart';

// part 'project_model.freezed.dart';
// part 'project_model.g.dart';

// enum ProjectStatus { active, inactive, completed, onHold, cancelled }

// enum ProjectPriority { urgent, high, medium, low }

// @freezed
// class ProjectModel with _$ProjectModel {
//   const ProjectModel._();

//   const factory ProjectModel({
//     required String projectId,
//     required String orgShortName,
//     required String projectName,
//     String? projectSite,
//     String? clientName,
//     String? clientLocation,
//     String? clientContact,
//     String? mngName,
//     String? mngEmail,
//     String? mngContact,
//     String? projectDescription,
//     String? projectTechstack,
//     String? projectAssignedDate,
//     @Default(ProjectStatus.active) ProjectStatus status,
//     @Default(ProjectPriority.high) ProjectPriority priority,
//     @Default(0.0) double progress, // 0.0 to 100.0
//     @Default(0) int teamSize,
//     @Default(0) int totalTasks,
//     @Default(0) int completedTasks,
//     @Default(0) int daysLeft,
//     @Default([]) List<String> teamMemberIds, // empIds
//     @Default([]) List<String> teamMemberNames, // Pre-fetched for UI
//     DateTime? startDate,
//     DateTime? endDate,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) = _ProjectModel;

//   factory ProjectModel.fromJson(Map<String, dynamic> json) =>
//       _$ProjectModelFromJson(json);

//   // Computed helpers for UI
//   String get displayStatus => status.name.toUpperCase();
//   String get displayPriority => priority.name.toUpperCase();
//   String get progressString => '${progress.toStringAsFixed(1)}%';
//   bool get isActive => status == ProjectStatus.active;
//   String get formattedDaysLeft =>
//       daysLeft > 0 ? '$daysLeft days left' : 'Overdue';
// }

// @freezed
// @freezed
// class MappedProject with _$MappedProject {
//   const MappedProject._();
//   const factory MappedProject({
//     required String empId,
//     required String projectId,
//     required String mappingStatus,
//     required ProjectModel project,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) = _MappedProject;
//   factory MappedProject.fromJson(Map<String, dynamic> json) =>
//       _$MappedProjectFromJson(json);
// }

// // Extension for extra helpers
// extension ProjectModelExtension on ProjectModel {
//   Color get priorityColor {
//     return switch (priority) {
//       ProjectPriority.urgent => Colors.red,
//       ProjectPriority.high => Colors.orange,
//       ProjectPriority.medium => Colors.yellow,
//       ProjectPriority.low => Colors.green,
//     };
//   }

//   Color get statusColor {
//     return switch (status) {
//       ProjectStatus.active => Colors.green,
//       ProjectStatus.completed => Colors.blue,
//       ProjectStatus.onHold => Colors.orange,
//       ProjectStatus.cancelled || ProjectStatus.inactive => Colors.red,
//     };
//   }
// }

// // DB Factory (from project_master + joins)
// ProjectModel projectFromDB(Map<String, dynamic> row) {
//   return ProjectModel(
//     projectId: row['project_id'] as String,
//     orgShortName: row['org_short_name'] as String? ?? 'NUTANTEK',
//     projectName: row['project_name'] as String,
//     projectSite: row['project_site'] as String?,
//     clientName: row['client_name'] as String?,
//     clientLocation: row['client_location'] as String?,
//     clientContact: row['client_contact'] as String?,
//     mngName: row['mng_name'] as String?,
//     mngEmail: row['mng_email'] as String?,
//     mngContact: row['mng_contact'] as String?,
//     projectDescription: row['project_description'] as String?,
//     projectTechstack: row['project_techstack'] as String?,
//     projectAssignedDate: row['project_assigned_date'] as String?,
//     status: _mapProjectStatus(row['status'] as String? ?? 'active'),
//     priority: _mapProjectPriority(row['priority'] as String? ?? 'high'),
//     progress: (row['progress'] as num?)?.toDouble() ?? 0.0,
//     teamSize: row['team_size'] as int? ?? 0,
//     totalTasks: row['total_tasks'] as int? ?? 0,
//     completedTasks: row['completed_tasks'] as int? ?? 0,
//     daysLeft: row['days_left'] as int? ?? 0,
//     teamMemberIds: [], // Populate from join query
//     teamMemberNames: [], // Populate from join
//     startDate: _parseDate(row['start_date'] as String?),
//     endDate: _parseDate(row['end_date'] as String?),
//     createdAt: _parseDate(row['created_at'] as String?),
//     updatedAt: _parseDate(row['updated_at'] as String?),
//   );
// }

// ProjectStatus _mapProjectStatus(String? status) {
//   final lower = (status ?? '').toLowerCase();
//   return switch (lower) {
//     'inactive' => ProjectStatus.inactive,
//     'completed' => ProjectStatus.completed,
//     'onhold' => ProjectStatus.onHold,
//     'cancelled' => ProjectStatus.cancelled,
//     _ => ProjectStatus.active,
//   };
// }

// ProjectPriority _mapProjectPriority(String? priority) {
//   final lower = (priority ?? '').toLowerCase();
//   return switch (lower) {
//     'urgent' => ProjectPriority.urgent,
//     'medium' => ProjectPriority.medium,
//     'low' => ProjectPriority.low,
//     _ => ProjectPriority.high,
//   };
// }

// DateTime? _parseDate(String? dateStr) {
//   if (dateStr == null) return null;
//   try {
//     return DateTime.parse(dateStr);
//   } catch (_) {
//     return null;
//   }
// }

// // lib/features/projects/domain/models/project_model.dart
// // REFINED & Upgraded Version (31 Dec 2025)
// // Enhanced for Manager Analytics + Screenshots (Active Projects Card)
// // Added: status, priority, progress, team size/tasks/days left, team members list
// // No hardcoding - All fields from DB (project_master + joins)
// // Supports Excel export & fl_chart workload distribution

// import 'package:freezed_annotation/freezed_annotation.dart';

// part 'project_model.freezed.dart';
// part 'project_model.g.dart';

// enum ProjectStatus { active, inactive, completed, onHold }

// enum ProjectPriority { high, medium, low, urgent }

// @freezed
// class ProjectModel with _$ProjectModel {
//   const ProjectModel._();

//   const factory ProjectModel({
//     required String projectId, // PK
//     required String orgShortName,
//     required String projectName,
//     String? projectSite,
//     String? clientName,
//     String? clientLocation,
//     String? clientContact,
//     String? mngName, // Project Manager Name
//     String? mngEmail,
//     String? mngContact,
//     String? projectDescription, // Short summary for cards
//     String? projectTechstack, // Comma-separated or JSON
//     String? projectAssignedDate,
//     @Default(ProjectStatus.active) ProjectStatus status,
//     @Default(ProjectPriority.high) ProjectPriority priority,
//     @Default(0.0) double progress, // 0.0 to 100.0 (computed from tasks)
//     @Default(0) int teamSize, // Count of assigned employees
//     @Default(0) int totalTasks, // From task table
//     @Default(0) int completedTasks, // For progress
//     @Default(0) int daysLeft, // Computed from end date
//     @Default([])
//     List<String> teamMemberIds, // empIds (join user table for names)
//     @Default([]) List<String> teamMemberNames, // Pre-fetched names for cards
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     DateTime? startDate, // For days left calculation
//     DateTime? endDate,
//   }) = _ProjectModel;

//   factory ProjectModel.fromJson(Map<String, dynamic> json) =>
//       _$ProjectModelFromJson(json);

//   // Computed helpers
//   String get displayStatus => status.name.toUpperCase();
//   String get displayPriority => priority.name.toUpperCase();
//   String get progressString => '${progress.toStringAsFixed(1)}%';
//   bool get isActive => status == ProjectStatus.active;
//   String get formattedDaysLeft =>
//       daysLeft > 0 ? '$daysLeft days left' : 'Overdue';
// }

// @freezed
// class MappedProject with _$MappedProject {
//   const MappedProject._();

//   const factory MappedProject({
//     required String empId,
//     required String projectId,
//     required String mappingStatus, // 'active' / 'deactive' / 'pending'
//     required ProjectModel project, // Joined project details
//     DateTime? assignedAt,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) = _MappedProject;

//   factory MappedProject.fromJson(Map<String, dynamic> json) =>
//       _$MappedProjectFromJson(json);
// }

// // // lib/features/projects/domain/models/project_model.dart
// // import 'package:freezed_annotation/freezed_annotation.dart';

// // part 'project_model.freezed.dart';
// // part 'project_model.g.dart';

// // @freezed
// // class ProjectModel with _$ProjectModel {
// //   const ProjectModel._();

// //   const factory ProjectModel({
// //     required String id,
// //     required String name,
// //     String? status,
// //     String? site,
// //     String? shift,
// //     String? clientName,
// //     String? clientContact,
// //     String? managerName,
// //     String? managerEmail,
// //     String? managerContact,
// //     String? description,
// //     String? techStack,
// //     DateTime? assignedDate,
// //   }) = _ProjectModel;

// //   factory ProjectModel.fromJson(Map<String, dynamic> json) =>
// //       _$ProjectModelFromJson(json);
// // }

// // @freezed
// // class ProjectAnalytics with _$ProjectAnalytics {
// //   const factory ProjectAnalytics({
// //     required Map<String, List<double>> graphData,
// //     required List<String> labels,
// //     required int totalProjects,
// //     required int totalEmployees,
// //     required Map<String, double> statusDistribution,
// //     @Default({}) Map<String, dynamic> additionalStats,
// //   }) = _ProjectAnalytics;

// //   factory ProjectAnalytics.fromJson(Map<String, dynamic> json) =>
// //       _$ProjectAnalyticsFromJson(json);
// // }
// // lib/features/project/domain/models/project_model.dart
// // import 'package:freezed_annotation/freezed_annotation.dart';

// // part 'project_model.freezed.dart';
// // part 'project_model.g.dart';

// // @freezed
// // class ProjectModel with _$ProjectModel {
// //   const ProjectModel._();

// //   const factory ProjectModel({
// //     required String projectId, // PK
// //     required String orgShortName,
// //     required String projectName,
// //     String? projectSite,
// //     String? clientName,
// //     String? clientLocation,
// //     String? clientContact,
// //     String? mngName,
// //     String? mngEmail,
// //     String? mngContact,
// //     String? projectDescription,
// //     String? projectTechstack,
// //     String? projectAssignedDate,
// //     DateTime? createdAt,
// //     DateTime? updatedAt,
// //   }) = _ProjectModel;

// //   factory ProjectModel.fromJson(Map<String, dynamic> json) =>
// //       _$ProjectModelFromJson(json);
// // }

// // // Mapped Project (employee_mapped_projects join)
// // @freezed
// // class MappedProject with _$MappedProject {
// //   const MappedProject._();

// //   const factory MappedProject({
// //     required String empId,
// //     required String projectId,
// //     required String mappingStatus, // 'active' / 'deactive'
// //     required ProjectModel project,
// //     DateTime? createdAt,
// //     DateTime? updatedAt,
// //   }) = _MappedProject;

// //   factory MappedProject.fromJson(Map<String, dynamic> json) =>
// //       _$MappedProjectFromJson(json);
// // }
