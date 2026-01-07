// lib/features/auth/domain/models/user_extension.dart
import 'package:appattendance/features/auth/domain/models/user_model.dart';
import 'package:intl/intl.dart';

extension UserModelExtension on UserModel {
  // Managerial check
  bool get isManagerial =>
      role == UserRole.manager ||
      role == UserRole.projectManager ||
      role == UserRole.srManager ||
      role == UserRole.operationsManager ||
      role == UserRole.hrManager ||
      role == UserRole.financeManager ||
      role == UserRole.admin;

  bool get isActive => status == UserStatus.active;

  // Privileges (R01-R08 style)
  bool get canViewTeamAttendance => isManagerial;
  bool get canApproveAttendance =>
      role == UserRole.admin || role == UserRole.hrManager;
  bool get canApplyRegularisation => role == UserRole.employee;
  bool get canApproveRegularisation => isManagerial;
  bool get canViewTeamLeaves => isManagerial;
  bool get canApproveLeaves => isManagerial || role == UserRole.hrManager;
  bool get canManageEmployees =>
      role == UserRole.hrManager || role == UserRole.admin;

  // Display helpers
  String get displayRole {
    final roleName = role.toString().split('.').last;
    return roleName
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
        .trim();
  }

  String get displayDesignation => designation;

  String get shortName => name.split(' ').firstOrNull ?? name;

  String get displayJoinDate {
    if (joiningDate != null)
      return DateFormat('dd MMM yyyy').format(joiningDate!);
    if (joiningDateStr != null && joiningDateStr!.isNotEmpty) {
      try {
        return DateFormat(
          'dd MMM yyyy',
        ).format(DateTime.parse(joiningDateStr!));
      } catch (_) {
        return joiningDateStr!;
      }
    }
    return 'N/A';
  }

  String get avatarInitial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  String get avatarUrl =>
      profilePhoto ??
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(shortName)}&background=random';
}
