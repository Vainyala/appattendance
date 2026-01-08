import 'package:appattendance/core/database/database_provider.dart';
import 'package:appattendance/core/database/db_helper.dart';
import 'package:appattendance/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:appattendance/features/attendance/data/services/offline_attendance_service.dart';
import 'package:appattendance/features/attendance/domain/models/attendance_model.dart';
import 'package:appattendance/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceNotifier
    extends StateNotifier<AsyncValue<List<AttendanceModel>>> {
  final Ref ref;

  AttendanceNotifier(this.ref) : super(const AsyncLoading()) {
    loadTodayAttendance();
    // syncOfflineQueue(); // Auto-sync on notifier init (app start/online)
  }

  Future<void> loadTodayAttendance() async {
    state = const AsyncLoading();
    final user = ref.read(authProvider).value;
    if (user == null) {
      state = AsyncError('Not logged in', StackTrace.current);
      return;
    }

    final repo = ref.read(attendanceRepositoryProvider);
    final attendance = await repo.getTodayAttendance(user.empId);
    state = AsyncData(attendance);
  }

  // Check-in aur Check-out methods (widget se call honge)
  Future<void> performCheckIn({
    required double latitude,
    required double longitude,
    required VerificationType verificationType,
    String? geofenceName,
    String? projectId,
    String? notes,
    String? photoProofPath,
  }) async {
    state = const AsyncLoading();
    final user = ref.read(authProvider).value;
    if (user == null) throw Exception('Not logged in');

    final repo = ref.read(attendanceRepositoryProvider);
    await repo.checkIn(
      empId: user.empId,
      latitude: latitude,
      longitude: longitude,
      verificationType: verificationType,
      geofenceName: geofenceName,
      projectId: projectId,
      notes: notes,
      photoProofPath: photoProofPath,
    );

    await loadTodayAttendance(); // Refresh
  }

  Future<void> performCheckOut({
    required double latitude,
    required double longitude,
    required VerificationType verificationType,
    String? geofenceName,
    String? projectId,
    String? notes,
  }) async {
    state = const AsyncLoading();
    final user = ref.read(authProvider).value;
    if (user == null) throw Exception('Not logged in');

    final repo = ref.read(attendanceRepositoryProvider);
    await repo.checkOut(
      empId: user.empId,
      latitude: latitude,
      longitude: longitude,
      verificationType: verificationType,
      geofenceName: geofenceName,
      projectId: projectId,
      notes: notes,
    );

    await loadTodayAttendance(); // Refresh
  }

  // Sync single offline check-in (called from OfflineAttendanceService)
  Future<void> syncCheckIn(AttendanceModel offlineAtt) async {
    final db = await ref.read(dbHelperProvider).database;

    // Check if already synced (avoid duplicate)
    final existing = await db.query(
      'employee_attendance',
      where: 'att_id = ?',
      whereArgs: [offlineAtt.attId],
    );

    if (existing.isNotEmpty) return; // Already synced

    // Insert to DB
    await db.insert('employee_attendance', {
      'att_id': offlineAtt.attId,
      'emp_id': offlineAtt.empId,
      'att_timestamp': offlineAtt.timestamp.toIso8601String(),
      'att_date': offlineAtt.attendanceDate.toIso8601String(),
      'att_latitude': offlineAtt.latitude,
      'att_longitude': offlineAtt.longitude,
      'att_geofence_name': offlineAtt.geofenceName,
      'project_id': offlineAtt.projectId,
      'att_notes': offlineAtt.notes,
      'att_status': offlineAtt.status.name,
      'verification_type': offlineAtt.verificationType?.name,
      'is_verified': offlineAtt.isVerified ? 1 : 0,
      'photo_proof_path': offlineAtt.photoProofPath,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await loadTodayAttendance();
  }

  // Sync all queued offline check-ins (widget se call karo - WidgetRef pass karo)
  Future<void> syncOfflineQueue(WidgetRef widgetRef) async {
    await OfflineAttendanceService().syncQueue(widgetRef);
  }
}
