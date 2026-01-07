// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeamMemberAnalyticsImpl _$$TeamMemberAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$TeamMemberAnalyticsImpl(
  empId: json['empId'] as String,
  name: json['name'] as String,
  designation: json['designation'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  status:
      $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
      UserStatus.active,
  profilePhoto: json['profilePhoto'] as String?,
  joinDate: json['joinDate'] == null
      ? null
      : DateTime.parse(json['joinDate'] as String),
  department: json['department'] as String?,
  assignedProjects:
      (json['assignedProjects'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  attendanceHistory: json['attendanceHistory'] == null
      ? const []
      : _attendanceListFromJson(json['attendanceHistory'] as List?),
);

Map<String, dynamic> _$$TeamMemberAnalyticsImplToJson(
  _$TeamMemberAnalyticsImpl instance,
) => <String, dynamic>{
  'empId': instance.empId,
  'name': instance.name,
  'designation': instance.designation,
  'email': instance.email,
  'phone': instance.phone,
  'status': _$UserStatusEnumMap[instance.status]!,
  'profilePhoto': instance.profilePhoto,
  'joinDate': instance.joinDate?.toIso8601String(),
  'department': instance.department,
  'assignedProjects': instance.assignedProjects,
  'attendanceHistory': _attendanceListToJson(instance.attendanceHistory),
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.inactive: 'inactive',
  UserStatus.suspended: 'suspended',
  UserStatus.terminated: 'terminated',
};
