// lib/features/auth/domain/models/user_role.dart
import 'package:appattendance/features/auth/domain/models/user_model.dart';

/// Role mapping helpers (DB string se enum mein convert)
UserRole mapRole(String? roleStr) {
  final lower = (roleStr ?? '').toLowerCase();
  if (lower.contains('admin')) return UserRole.admin;
  if (lower.contains('hr')) return UserRole.hrManager;
  if (lower.contains('finance')) return UserRole.financeManager;
  if (lower.contains('operations')) return UserRole.operationsManager;
  if (lower.contains('sr') || lower.contains('senior'))
    return UserRole.srManager;
  if (lower.contains('project')) return UserRole.projectManager;
  if (lower.contains('manager')) return UserRole.manager;
  return UserRole.employee;
}

/// Status mapping
UserStatus mapStatus(String? status) {
  final lower = (status ?? '').toLowerCase();
  if (lower == 'inactive') return UserStatus.inactive;
  if (lower == 'suspended') return UserStatus.suspended;
  if (lower == 'terminated') return UserStatus.terminated;
  return UserStatus.active;
}
