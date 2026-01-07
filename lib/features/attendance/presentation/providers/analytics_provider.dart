// lib/features/attendance/presentation/providers/analytics_provider.dart
// Riverpod Providers for Analytics

import 'package:appattendance/core/database/database_provider.dart';
import 'package:appattendance/core/database/db_helper.dart';
import 'package:appattendance/features/attendance/data/repositories/analytics_repository.dart';
import 'package:appattendance/features/attendance/data/repositories/analytics_repository_impl.dart';
import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';
import 'package:appattendance/features/attendance/presentation/providers/analytics_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository Provider (switch to API impl later)
final attendanceAnalyticsRepositoryProvider =
    Provider<AttendanceAnalyticsRepository>((ref) {
      final dbHelper = ref.watch(dbHelperProvider);
      return AttendanceAnalyticsRepositoryImpl(dbHelper);
    });

// Analytics Period Provider (user can switch daily/weekly/etc.)
final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>(
  (ref) => AnalyticsPeriod.daily,
);

// Analytics State Notifier Provider
final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AsyncValue<AnalyticsModel>>((ref) {
      final repo = ref.watch(attendanceAnalyticsRepositoryProvider);
      return AnalyticsNotifier(repo, ref);
    });

// // lib/features/attendance/presentation/providers/analytics_provider.dart
// // Riverpod Providers for Analytics

// import 'package:appattendance/core/database/database_provider.dart';
// import 'package:appattendance/core/database/db_helper.dart';
// import 'package:appattendance/features/attendance/data/repositories/analytics_repository.dart';
// import 'package:appattendance/features/attendance/data/repositories/analytics_repository_impl.dart';
// import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';
// import 'package:appattendance/features/attendance/presentation/providers/analytics_notifier.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Repository Provider (switch to API impl later)
// final attendanceAnalyticsRepositoryProvider =
//     Provider<AttendanceAnalyticsRepository>((ref) {
//       final dbHelper = ref.watch(dbHelperProvider);
//       return AttendanceAnalyticsRepositoryImpl(dbHelper);
//     });

// // Analytics Period Provider (user can switch daily/weekly/etc.)
// final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>(
//   (ref) => AnalyticsPeriod.daily,
// );

// // Analytics State Notifier Provider
// final analyticsProvider =
//     StateNotifierProvider<AnalyticsNotifier, AsyncValue<AnalyticsModel>>((ref) {
//       final repo = ref.watch(attendanceAnalyticsRepositoryProvider);
//       return AnalyticsNotifier(repo, ref);
//     });

// // lib/features/attendance/presentation/providers/analytics_provider.dart
// // Riverpod Providers for Analytics

// import 'package:appattendance/core/database/database_provider.dart';
// import 'package:appattendance/core/database/db_helper.dart';
// import 'package:appattendance/features/attendance/data/repositories/analytics_repository.dart';
// import 'package:appattendance/features/attendance/data/repositories/analytics_repository_impl.dart';
// import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';
// import 'package:appattendance/features/attendance/presentation/providers/analytics_notifier.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Repository Provider (switch to API impl later)
// final attendanceAnalyticsRepositoryProvider =
//     Provider<AttendanceAnalyticsRepository>((ref) {
//       final dbHelper = ref.watch(dbHelperProvider);
//       return AttendanceAnalyticsRepositoryImpl(dbHelper);
//     });

// // Analytics Period Provider (user can switch daily/weekly/etc.)
// final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>(
//   (ref) => AnalyticsPeriod.daily,
// );

// // Analytics State Notifier Provider
// final analyticsProvider =
//     StateNotifierProvider<AnalyticsNotifier, AsyncValue<AnalyticsModel>>((ref) {
//       final repo = ref.watch(attendanceAnalyticsRepositoryProvider);
//       return AnalyticsNotifier(repo, ref);
//     });
// // lib/features/analytics/presentation/providers/analytics_provider.dart

// import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';
// import 'package:appattendance/features/attendance/presentation/providers/analytics_notifier.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final analyticsProvider =
//     StateNotifierProvider<AnalyticsNotifier, AsyncValue<AnalyticsModel>>(
//       (ref) => AnalyticsNotifier(ref),
//     );
