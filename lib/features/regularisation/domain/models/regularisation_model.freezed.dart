// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'regularisation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RegularisationModel _$RegularisationModelFromJson(Map<String, dynamic> json) {
  return _RegularisationModel.fromJson(json);
}

/// @nodoc
mixin _$RegularisationModel {
  String get regId => throw _privateConstructorUsedError; // reg_id
  String get empId => throw _privateConstructorUsedError; // emp_id
  DateTime get appliedForDate =>
      throw _privateConstructorUsedError; // reg_applied_for_date (main date)
  DateTime get appliedDate =>
      throw _privateConstructorUsedError; // reg_date_applied (application date)
  RegularisationType get type => throw _privateConstructorUsedError;
  String get justification => throw _privateConstructorUsedError;
  RegularisationStatus get status => throw _privateConstructorUsedError;
  String? get managerRemarks => throw _privateConstructorUsedError;
  List<String> get supportingDocs =>
      throw _privateConstructorUsedError; // NEW: Time range for half-day/full-day regularisation
  String? get fromTime =>
      throw _privateConstructorUsedError; // e.g., "09:00" (HH:mm string)
  String? get toTime =>
      throw _privateConstructorUsedError; // e.g., "18:00" (HH:mm string)
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this RegularisationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegularisationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegularisationModelCopyWith<RegularisationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegularisationModelCopyWith<$Res> {
  factory $RegularisationModelCopyWith(
    RegularisationModel value,
    $Res Function(RegularisationModel) then,
  ) = _$RegularisationModelCopyWithImpl<$Res, RegularisationModel>;
  @useResult
  $Res call({
    String regId,
    String empId,
    DateTime appliedForDate,
    DateTime appliedDate,
    RegularisationType type,
    String justification,
    RegularisationStatus status,
    String? managerRemarks,
    List<String> supportingDocs,
    String? fromTime,
    String? toTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$RegularisationModelCopyWithImpl<$Res, $Val extends RegularisationModel>
    implements $RegularisationModelCopyWith<$Res> {
  _$RegularisationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegularisationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? regId = null,
    Object? empId = null,
    Object? appliedForDate = null,
    Object? appliedDate = null,
    Object? type = null,
    Object? justification = null,
    Object? status = null,
    Object? managerRemarks = freezed,
    Object? supportingDocs = null,
    Object? fromTime = freezed,
    Object? toTime = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            regId: null == regId
                ? _value.regId
                : regId // ignore: cast_nullable_to_non_nullable
                      as String,
            empId: null == empId
                ? _value.empId
                : empId // ignore: cast_nullable_to_non_nullable
                      as String,
            appliedForDate: null == appliedForDate
                ? _value.appliedForDate
                : appliedForDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            appliedDate: null == appliedDate
                ? _value.appliedDate
                : appliedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as RegularisationType,
            justification: null == justification
                ? _value.justification
                : justification // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RegularisationStatus,
            managerRemarks: freezed == managerRemarks
                ? _value.managerRemarks
                : managerRemarks // ignore: cast_nullable_to_non_nullable
                      as String?,
            supportingDocs: null == supportingDocs
                ? _value.supportingDocs
                : supportingDocs // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            fromTime: freezed == fromTime
                ? _value.fromTime
                : fromTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            toTime: freezed == toTime
                ? _value.toTime
                : toTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RegularisationModelImplCopyWith<$Res>
    implements $RegularisationModelCopyWith<$Res> {
  factory _$$RegularisationModelImplCopyWith(
    _$RegularisationModelImpl value,
    $Res Function(_$RegularisationModelImpl) then,
  ) = __$$RegularisationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String regId,
    String empId,
    DateTime appliedForDate,
    DateTime appliedDate,
    RegularisationType type,
    String justification,
    RegularisationStatus status,
    String? managerRemarks,
    List<String> supportingDocs,
    String? fromTime,
    String? toTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$RegularisationModelImplCopyWithImpl<$Res>
    extends _$RegularisationModelCopyWithImpl<$Res, _$RegularisationModelImpl>
    implements _$$RegularisationModelImplCopyWith<$Res> {
  __$$RegularisationModelImplCopyWithImpl(
    _$RegularisationModelImpl _value,
    $Res Function(_$RegularisationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RegularisationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? regId = null,
    Object? empId = null,
    Object? appliedForDate = null,
    Object? appliedDate = null,
    Object? type = null,
    Object? justification = null,
    Object? status = null,
    Object? managerRemarks = freezed,
    Object? supportingDocs = null,
    Object? fromTime = freezed,
    Object? toTime = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$RegularisationModelImpl(
        regId: null == regId
            ? _value.regId
            : regId // ignore: cast_nullable_to_non_nullable
                  as String,
        empId: null == empId
            ? _value.empId
            : empId // ignore: cast_nullable_to_non_nullable
                  as String,
        appliedForDate: null == appliedForDate
            ? _value.appliedForDate
            : appliedForDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        appliedDate: null == appliedDate
            ? _value.appliedDate
            : appliedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as RegularisationType,
        justification: null == justification
            ? _value.justification
            : justification // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RegularisationStatus,
        managerRemarks: freezed == managerRemarks
            ? _value.managerRemarks
            : managerRemarks // ignore: cast_nullable_to_non_nullable
                  as String?,
        supportingDocs: null == supportingDocs
            ? _value._supportingDocs
            : supportingDocs // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        fromTime: freezed == fromTime
            ? _value.fromTime
            : fromTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        toTime: freezed == toTime
            ? _value.toTime
            : toTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RegularisationModelImpl extends _RegularisationModel {
  const _$RegularisationModelImpl({
    required this.regId,
    required this.empId,
    required this.appliedForDate,
    required this.appliedDate,
    required this.type,
    required this.justification,
    required this.status,
    this.managerRemarks,
    final List<String> supportingDocs = const [],
    this.fromTime,
    this.toTime,
    this.createdAt,
    this.updatedAt,
  }) : _supportingDocs = supportingDocs,
       super._();

  factory _$RegularisationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegularisationModelImplFromJson(json);

  @override
  final String regId;
  // reg_id
  @override
  final String empId;
  // emp_id
  @override
  final DateTime appliedForDate;
  // reg_applied_for_date (main date)
  @override
  final DateTime appliedDate;
  // reg_date_applied (application date)
  @override
  final RegularisationType type;
  @override
  final String justification;
  @override
  final RegularisationStatus status;
  @override
  final String? managerRemarks;
  final List<String> _supportingDocs;
  @override
  @JsonKey()
  List<String> get supportingDocs {
    if (_supportingDocs is EqualUnmodifiableListView) return _supportingDocs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_supportingDocs);
  }

  // NEW: Time range for half-day/full-day regularisation
  @override
  final String? fromTime;
  // e.g., "09:00" (HH:mm string)
  @override
  final String? toTime;
  // e.g., "18:00" (HH:mm string)
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'RegularisationModel(regId: $regId, empId: $empId, appliedForDate: $appliedForDate, appliedDate: $appliedDate, type: $type, justification: $justification, status: $status, managerRemarks: $managerRemarks, supportingDocs: $supportingDocs, fromTime: $fromTime, toTime: $toTime, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegularisationModelImpl &&
            (identical(other.regId, regId) || other.regId == regId) &&
            (identical(other.empId, empId) || other.empId == empId) &&
            (identical(other.appliedForDate, appliedForDate) ||
                other.appliedForDate == appliedForDate) &&
            (identical(other.appliedDate, appliedDate) ||
                other.appliedDate == appliedDate) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.justification, justification) ||
                other.justification == justification) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.managerRemarks, managerRemarks) ||
                other.managerRemarks == managerRemarks) &&
            const DeepCollectionEquality().equals(
              other._supportingDocs,
              _supportingDocs,
            ) &&
            (identical(other.fromTime, fromTime) ||
                other.fromTime == fromTime) &&
            (identical(other.toTime, toTime) || other.toTime == toTime) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    regId,
    empId,
    appliedForDate,
    appliedDate,
    type,
    justification,
    status,
    managerRemarks,
    const DeepCollectionEquality().hash(_supportingDocs),
    fromTime,
    toTime,
    createdAt,
    updatedAt,
  );

  /// Create a copy of RegularisationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegularisationModelImplCopyWith<_$RegularisationModelImpl> get copyWith =>
      __$$RegularisationModelImplCopyWithImpl<_$RegularisationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RegularisationModelImplToJson(this);
  }
}

abstract class _RegularisationModel extends RegularisationModel {
  const factory _RegularisationModel({
    required final String regId,
    required final String empId,
    required final DateTime appliedForDate,
    required final DateTime appliedDate,
    required final RegularisationType type,
    required final String justification,
    required final RegularisationStatus status,
    final String? managerRemarks,
    final List<String> supportingDocs,
    final String? fromTime,
    final String? toTime,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$RegularisationModelImpl;
  const _RegularisationModel._() : super._();

  factory _RegularisationModel.fromJson(Map<String, dynamic> json) =
      _$RegularisationModelImpl.fromJson;

  @override
  String get regId; // reg_id
  @override
  String get empId; // emp_id
  @override
  DateTime get appliedForDate; // reg_applied_for_date (main date)
  @override
  DateTime get appliedDate; // reg_date_applied (application date)
  @override
  RegularisationType get type;
  @override
  String get justification;
  @override
  RegularisationStatus get status;
  @override
  String? get managerRemarks;
  @override
  List<String> get supportingDocs; // NEW: Time range for half-day/full-day regularisation
  @override
  String? get fromTime; // e.g., "09:00" (HH:mm string)
  @override
  String? get toTime; // e.g., "18:00" (HH:mm string)
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of RegularisationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegularisationModelImplCopyWith<_$RegularisationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
