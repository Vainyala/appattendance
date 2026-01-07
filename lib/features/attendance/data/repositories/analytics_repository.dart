// lib/features/attendance/data/repositories/attendance_analytics_repository.dart
// Abstract Repository - Defines contract for analytics data fetching
// Future-proof for API switch (just change impl)

import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';

abstract class AttendanceAnalyticsRepository {
  Future<AnalyticsModel> getAnalytics({
    required AnalyticsPeriod period,
    required String empId, // Employee or Manager ID
  });
}

// // lib/features/analytics/domain/repositories/analytics_repository.dart
// import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';

// abstract class AnalyticsRepository {
//   /// Period ke hisaab se aggregated analytics fetch karta hai
//   Future<AnalyticsModel> getAnalytics({
//     required String empId,
//     required AnalyticsPeriod period,
//     required DateTime startDate,
//     required DateTime endDate,
//   });

//   /// Manager ke liye team analytics (team members ke saare stats)
//   Future<AnalyticsModel> getTeamAnalytics({
//     required String mgrEmpId,
//     required AnalyticsPeriod period,
//     required DateTime startDate,
//     required DateTime endDate,
//   });
// }
