import 'dart:convert';
import 'package:appattendance/features/attendance/domain/models/attendance_model.dart';
import 'package:appattendance/features/attendance/presentation/providers/attendance_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart'; // For background sync

class OfflineAttendanceService {
  static const String _queueKey = 'offline_checkin_queue';
  static const String _retryCountPrefix =
      'retry_count_'; // Per record retry tracking

  static final OfflineAttendanceService _instance =
      OfflineAttendanceService._internal();

  factory OfflineAttendanceService() => _instance;

  OfflineAttendanceService._internal();

  /// Queue a check-in record when offline
  Future<void> queueCheckIn(AttendanceModel att) async {
    final prefs = await SharedPreferences.getInstance();

    // Generate unique key for this record (att_id + timestamp)
    final recordKey = '${att.attId}_${att.timestamp.millisecondsSinceEpoch}';

    // Add to queue
    List<String> queue = prefs.getStringList(_queueKey) ?? [];
    if (!queue.contains(recordKey)) {
      queue.add(recordKey);
      await prefs.setStringList(_queueKey, queue);
    }

    // Save actual data with key
    await prefs.setString(recordKey, jsonEncode(att.toJson()));

    // Initialize retry count = 0
    await prefs.setInt('$_retryCountPrefix$recordKey', 0);

    // Schedule background sync
    await _scheduleBackgroundSync();
  }

  /// Sync all queued records (foreground + background)
  Future<void> syncQueue(
    WidgetRef? widgetRef, {
    bool isBackground = false,
  }) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_queueKey) ?? [];
    if (queue.isEmpty) return;

    final notifier = widgetRef!.read(attendanceProvider.notifier);
    List<String> failedQueue = [];

    for (var recordKey in queue) {
      final jsonStr = prefs.getString(recordKey);
      if (jsonStr == null) continue;

      final att = AttendanceModel.fromJson(jsonDecode(jsonStr));
      final retryCount = prefs.getInt('$_retryCountPrefix$recordKey') ?? 0;

      if (retryCount >= 3) {
        continue; // Drop after 3 failed attempts
      }

      try {
        await notifier.syncCheckIn(att);
        // Success → clean up
        await prefs.remove(recordKey);
        await prefs.remove('$_retryCountPrefix$recordKey');
      } catch (e) {
        await prefs.setInt('$_retryCountPrefix$recordKey', retryCount + 1);
        failedQueue.add(recordKey);
      }
    }

    // Update remaining queue
    await prefs.setStringList(_queueKey, failedQueue);
  }

  /// Schedule background sync using Workmanager
  Future<void> _scheduleBackgroundSync() async {
    await Workmanager().registerOneOffTask(
      "offline_attendance_sync",
      "syncOfflineAttendance",
      constraints: Constraints(networkType: NetworkType.connected),
      initialDelay: const Duration(minutes: 15), // Don't sync immediately
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 10),
    );
  }

  /// Workmanager callback (must be top-level or static)
  static Future<void> backgroundSyncCallback() async {
    // This runs in background isolate — no Riverpod context
    // We can only do basic sync here (e.g., via direct repository)
    // For full sync with notifier → use foreground sync when app opens

    final service = OfflineAttendanceService();
    // Minimal sync (you can extend this)
    await service.syncQueue(null, isBackground: true);
  }
}

// // lib/core/services/offline_attendance_service.dart
// import 'dart:convert';
// import 'package:appattendance/features/attendance/domain/models/attendance_model.dart';
// import 'package:appattendance/features/attendance/presentation/providers/attendance_provider.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class OfflineAttendanceService {
//   static const String _queueKey = 'offline_checkin_queue';

//   Future<void> queueCheckIn(AttendanceModel att) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> queue = prefs.getStringList(_queueKey) ?? [];
//     queue.add(jsonEncode(att.toJson()));
//     await prefs.setStringList(_queueKey, queue);
//   }

//   Future<void> syncQueue(WidgetRef widgetRef) async {
//     final connectivity = await Connectivity().checkConnectivity();
//     if (connectivity == ConnectivityResult.none) return;

//     final prefs = await SharedPreferences.getInstance();
//     List<String> queue = prefs.getStringList(_queueKey) ?? [];
//     if (queue.isEmpty) return;

//     final notifier = widgetRef.read(attendanceProvider.notifier);

//     List<String> failedQueue = [];

//     for (var jsonStr in queue) {
//       final att = AttendanceModel.fromJson(jsonDecode(jsonStr));
//       try {
//         await notifier.syncCheckIn(att);
//       } catch (e) {
//         failedQueue.add(jsonStr);
//       }
//     }

//     await prefs.setStringList(_queueKey, failedQueue);
//   }
// }
