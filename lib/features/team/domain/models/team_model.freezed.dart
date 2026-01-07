// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeamMemberAnalytics _$TeamMemberAnalyticsFromJson(Map<String, dynamic> json) {
  return _TeamMemberAnalytics.fromJson(json);
}

/// @nodoc
mixin _$TeamMemberAnalytics {
  String get empId => throw _privateConstructorUsedError; // emp_id (PK)
  String get name => throw _privateConstructorUsedError;
  String get designation => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  UserStatus get status =>
      throw _privateConstructorUsedError; // From user_model enum
  String? get profilePhoto =>
      throw _privateConstructorUsedError; // Profile photo or generated
  DateTime? get joinDate => throw _privateConstructorUsedError;
  String? get department => throw _privateConstructorUsedError;
  List<String> get assignedProjects =>
      throw _privateConstructorUsedError; // Project names/IDs
  @JsonKey(fromJson: _attendanceListFromJson, toJson: _attendanceListToJson)
  List<AttendanceModel> get attendanceHistory =>
      throw _privateConstructorUsedError;

  /// Serializes this TeamMemberAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamMemberAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamMemberAnalyticsCopyWith<TeamMemberAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamMemberAnalyticsCopyWith<$Res> {
  factory $TeamMemberAnalyticsCopyWith(
    TeamMemberAnalytics value,
    $Res Function(TeamMemberAnalytics) then,
  ) = _$TeamMemberAnalyticsCopyWithImpl<$Res, TeamMemberAnalytics>;
  @useResult
  $Res call({
    String empId,
    String name,
    String designation,
    String email,
    String? phone,
    UserStatus status,
    String? profilePhoto,
    DateTime? joinDate,
    String? department,
    List<String> assignedProjects,
    @JsonKey(fromJson: _attendanceListFromJson, toJson: _attendanceListToJson)
    List<AttendanceModel> attendanceHistory,
  });
}

/// @nodoc
class _$TeamMemberAnalyticsCopyWithImpl<$Res, $Val extends TeamMemberAnalytics>
    implements $TeamMemberAnalyticsCopyWith<$Res> {
  _$TeamMemberAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamMemberAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? empId = null,
    Object? name = null,
    Object? designation = null,
    Object? email = null,
    Object? phone = freezed,
    Object? status = null,
    Object? profilePhoto = freezed,
    Object? joinDate = freezed,
    Object? department = freezed,
    Object? assignedProjects = null,
    Object? attendanceHistory = null,
  }) {
    return _then(
      _value.copyWith(
            empId: null == empId
                ? _value.empId
                : empId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            designation: null == designation
                ? _value.designation
                : designation // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as UserStatus,
            profilePhoto: freezed == profilePhoto
                ? _value.profilePhoto
                : profilePhoto // ignore: cast_nullable_to_non_nullable
                      as String?,
            joinDate: freezed == joinDate
                ? _value.joinDate
                : joinDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            department: freezed == department
                ? _value.department
                : department // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedProjects: null == assignedProjects
                ? _value.assignedProjects
                : assignedProjects // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            attendanceHistory: null == attendanceHistory
                ? _value.attendanceHistory
                : attendanceHistory // ignore: cast_nullable_to_non_nullable
                      as List<AttendanceModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeamMemberAnalyticsImplCopyWith<$Res>
    implements $TeamMemberAnalyticsCopyWith<$Res> {
  factory _$$TeamMemberAnalyticsImplCopyWith(
    _$TeamMemberAnalyticsImpl value,
    $Res Function(_$TeamMemberAnalyticsImpl) then,
  ) = __$$TeamMemberAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String empId,
    String name,
    String designation,
    String email,
    String? phone,
    UserStatus status,
    String? profilePhoto,
    DateTime? joinDate,
    String? department,
    List<String> assignedProjects,
    @JsonKey(fromJson: _attendanceListFromJson, toJson: _attendanceListToJson)
    List<AttendanceModel> attendanceHistory,
  });
}

/// @nodoc
class __$$TeamMemberAnalyticsImplCopyWithImpl<$Res>
    extends _$TeamMemberAnalyticsCopyWithImpl<$Res, _$TeamMemberAnalyticsImpl>
    implements _$$TeamMemberAnalyticsImplCopyWith<$Res> {
  __$$TeamMemberAnalyticsImplCopyWithImpl(
    _$TeamMemberAnalyticsImpl _value,
    $Res Function(_$TeamMemberAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeamMemberAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? empId = null,
    Object? name = null,
    Object? designation = null,
    Object? email = null,
    Object? phone = freezed,
    Object? status = null,
    Object? profilePhoto = freezed,
    Object? joinDate = freezed,
    Object? department = freezed,
    Object? assignedProjects = null,
    Object? attendanceHistory = null,
  }) {
    return _then(
      _$TeamMemberAnalyticsImpl(
        empId: null == empId
            ? _value.empId
            : empId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        designation: null == designation
            ? _value.designation
            : designation // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as UserStatus,
        profilePhoto: freezed == profilePhoto
            ? _value.profilePhoto
            : profilePhoto // ignore: cast_nullable_to_non_nullable
                  as String?,
        joinDate: freezed == joinDate
            ? _value.joinDate
            : joinDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        department: freezed == department
            ? _value.department
            : department // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedProjects: null == assignedProjects
            ? _value._assignedProjects
            : assignedProjects // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        attendanceHistory: null == attendanceHistory
            ? _value._attendanceHistory
            : attendanceHistory // ignore: cast_nullable_to_non_nullable
                  as List<AttendanceModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamMemberAnalyticsImpl extends _TeamMemberAnalytics {
  const _$TeamMemberAnalyticsImpl({
    required this.empId,
    required this.name,
    required this.designation,
    required this.email,
    this.phone,
    this.status = UserStatus.active,
    this.profilePhoto,
    this.joinDate,
    this.department,
    final List<String> assignedProjects = const [],
    @JsonKey(fromJson: _attendanceListFromJson, toJson: _attendanceListToJson)
    final List<AttendanceModel> attendanceHistory = const [],
  }) : _assignedProjects = assignedProjects,
       _attendanceHistory = attendanceHistory,
       super._();

  factory _$TeamMemberAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamMemberAnalyticsImplFromJson(json);

  @override
  final String empId;
  // emp_id (PK)
  @override
  final String name;
  @override
  final String designation;
  @override
  final String email;
  @override
  final String? phone;
  @override
  @JsonKey()
  final UserStatus status;
  // From user_model enum
  @override
  final String? profilePhoto;
  // Profile photo or generated
  @override
  final DateTime? joinDate;
  @override
  final String? department;
  final List<String> _assignedProjects;
  @override
  @JsonKey()
  List<String> get assignedProjects {
    if (_assignedProjects is EqualUnmodifiableListView)
      return _assignedProjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assignedProjects);
  }

  // Project names/IDs
  final List<AttendanceModel> _attendanceHistory;
  // Project names/IDs
  @override
  @JsonKey(fromJson: _attendanceListFromJson, toJson: _attendanceListToJson)
  List<AttendanceModel> get attendanceHistory {
    if (_attendanceHistory is EqualUnmodifiableListView)
      return _attendanceHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attendanceHistory);
  }

  @override
  String toString() {
    return 'TeamMemberAnalytics(empId: $empId, name: $name, designation: $designation, email: $email, phone: $phone, status: $status, profilePhoto: $profilePhoto, joinDate: $joinDate, department: $department, assignedProjects: $assignedProjects, attendanceHistory: $attendanceHistory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamMemberAnalyticsImpl &&
            (identical(other.empId, empId) || other.empId == empId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.designation, designation) ||
                other.designation == designation) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.profilePhoto, profilePhoto) ||
                other.profilePhoto == profilePhoto) &&
            (identical(other.joinDate, joinDate) ||
                other.joinDate == joinDate) &&
            (identical(other.department, department) ||
                other.department == department) &&
            const DeepCollectionEquality().equals(
              other._assignedProjects,
              _assignedProjects,
            ) &&
            const DeepCollectionEquality().equals(
              other._attendanceHistory,
              _attendanceHistory,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    empId,
    name,
    designation,
    email,
    phone,
    status,
    profilePhoto,
    joinDate,
    department,
    const DeepCollectionEquality().hash(_assignedProjects),
    const DeepCollectionEquality().hash(_attendanceHistory),
  );

  /// Create a copy of TeamMemberAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamMemberAnalyticsImplCopyWith<_$TeamMemberAnalyticsImpl> get copyWith =>
      __$$TeamMemberAnalyticsImplCopyWithImpl<_$TeamMemberAnalyticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamMemberAnalyticsImplToJson(this);
  }
}

abstract class _TeamMemberAnalytics extends TeamMemberAnalytics {
  const factory _TeamMemberAnalytics({
    required final String empId,
    required final String name,
    required final String designation,
    required final String email,
    final String? phone,
    final UserStatus status,
    final String? profilePhoto,
    final DateTime? joinDate,
    final String? department,
    final List<String> assignedProjects,
    @JsonKey(fromJson: _attendanceListFromJson, toJson: _attendanceListToJson)
    final List<AttendanceModel> attendanceHistory,
  }) = _$TeamMemberAnalyticsImpl;
  const _TeamMemberAnalytics._() : super._();

  factory _TeamMemberAnalytics.fromJson(Map<String, dynamic> json) =
      _$TeamMemberAnalyticsImpl.fromJson;

  @override
  String get empId; // emp_id (PK)
  @override
  String get name;
  @override
  String get designation;
  @override
  String get email;
  @override
  String? get phone;
  @override
  UserStatus get status; // From user_model enum
  @override
  String? get profilePhoto; // Profile photo or generated
  @override
  DateTime? get joinDate;
  @override
  String? get department;
  @override
  List<String> get assignedProjects; // Project names/IDs
  @override
  @JsonKey(fromJson: _attendanceListFromJson, toJson: _attendanceListToJson)
  List<AttendanceModel> get attendanceHistory;

  /// Create a copy of TeamMemberAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamMemberAnalyticsImplCopyWith<_$TeamMemberAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
