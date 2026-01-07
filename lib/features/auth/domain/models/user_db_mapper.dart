// lib/features/auth/domain/models/user_db_mapper.dart
import 'package:appattendance/features/auth/domain/models/user_model.dart';
import 'package:appattendance/features/auth/domain/models/user_role.dart';

UserModel userFromDB(
  Map<String, dynamic> userRow,
  Map<String, dynamic> empRow,
) {
  final empId = userRow['emp_id'] ?? userRow['id'] ?? '';
  final email = userRow['email_id'] ?? userRow['email'] ?? '';
  final statusStr = userRow['emp_status'] ?? userRow['status'] ?? 'active';

  return UserModel(
    empId: empId as String,
    orgShortName: empRow['org_short_name'] as String? ?? 'NUTANTEK',
    name: empRow['emp_name'] as String? ?? 'Unknown',
    email: empRow['emp_email'] as String? ?? email,
    phone: empRow['emp_phone'] as String?,
    role: mapRole(empRow['emp_role'] as String?),
    department: empRow['emp_department'] as String?,
    designation: empRow['designation'] as String? ?? 'Employee',
    joiningDate: _parseDate(empRow['emp_joining_date'] as String?),
    joiningDateStr: empRow['emp_joining_date'] as String?,
    status: mapStatus(statusStr as String?),
    createdAt: _parseDate(userRow['created_at'] as String?),
    updatedAt: _parseDate(userRow['updated_at'] as String?),
    assignedProjectIds: [],
    projectNames: [],
    biometricEnabled: (userRow['biometric_enabled'] as int? ?? 0) == 1,
    shiftId: empRow['shift_id'] as String?,
    reportingManagerId: empRow['reporting_manager_id'] as String?,
    profilePhoto: empRow['profile_photo'] as String?,
  );
}

DateTime? _parseDate(String? dateStr) {
  if (dateStr == null) return null;
  try {
    return DateTime.parse(dateStr);
  } catch (_) {
    return null;
  }
}
