// lib/features/auth/domain/models/user_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

enum UserRole {
  @JsonValue('Admin')
  admin,
  @JsonValue('Employee')
  employee,
  @JsonValue('Project Manager')
  projectManager,
  @JsonValue('Sr. Manager')
  srManager,
  @JsonValue('Operations Manager')
  operationsManager,
  @JsonValue('HR Manager')
  hrManager,
  @JsonValue('Finance Manager')
  financeManager,
  @JsonValue('Manager')
  manager,
  @JsonValue('Unknown')
  unknown,
}

enum UserStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('suspended')
  suspended,
  @JsonValue('terminated')
  terminated,
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String empId,
    required String orgShortName,
    required String name,
    required String email,
    String? phone,
    required UserRole role,
    String? department,
    @Default('Employee') String designation,
    DateTime? joiningDate,
    String? joiningDateStr,
    @Default(UserStatus.active) UserStatus status,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default([]) List<String> assignedProjectIds,
    @Default([]) List<String> projectNames,
    @Default(false) bool biometricEnabled,
    String? shiftId,
    String? reportingManagerId,
    String? profilePhoto,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
