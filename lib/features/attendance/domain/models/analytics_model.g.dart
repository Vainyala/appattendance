// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnalyticsModelImpl _$$AnalyticsModelImplFromJson(
  Map<String, dynamic> json,
) => _$AnalyticsModelImpl(
  period: $enumDecode(_$AnalyticsPeriodEnumMap, json['period']),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  teamStats:
      (json['teamStats'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  teamPercentages:
      (json['teamPercentages'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  employeeBreakdown:
      (json['employeeBreakdown'] as List<dynamic>?)
          ?.map((e) => EmployeeAnalytics.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  graphDataRaw:
      (json['graphDataRaw'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
        ),
      ) ??
      const {},
  graphLabels:
      (json['graphLabels'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  insights:
      (json['insights'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  activeProjects:
      (json['activeProjects'] as List<dynamic>?)
          ?.map((e) => ProjectAnalytics.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalDays: (json['totalDays'] as num?)?.toInt() ?? 0,
  presentDays: (json['presentDays'] as num?)?.toInt() ?? 0,
  absentDays: (json['absentDays'] as num?)?.toInt() ?? 0,
  leaveDays: (json['leaveDays'] as num?)?.toInt() ?? 0,
  lateDays: (json['lateDays'] as num?)?.toInt() ?? 0,
  onTimeDays: (json['onTimeDays'] as num?)?.toInt() ?? 0,
  dailyAvgHours: (json['dailyAvgHours'] as num?)?.toDouble() ?? 0.0,
  monthlyAvgHours: (json['monthlyAvgHours'] as num?)?.toDouble() ?? 0.0,
  pendingRegularisations:
      (json['pendingRegularisations'] as num?)?.toInt() ?? 0,
  pendingLeaves: (json['pendingLeaves'] as num?)?.toInt() ?? 0,
  periodTitle: json['periodTitle'] as String?,
);

Map<String, dynamic> _$$AnalyticsModelImplToJson(
  _$AnalyticsModelImpl instance,
) => <String, dynamic>{
  'period': _$AnalyticsPeriodEnumMap[instance.period]!,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'teamStats': instance.teamStats,
  'teamPercentages': instance.teamPercentages,
  'employeeBreakdown': instance.employeeBreakdown,
  'graphDataRaw': instance.graphDataRaw,
  'graphLabels': instance.graphLabels,
  'insights': instance.insights,
  'activeProjects': instance.activeProjects,
  'totalDays': instance.totalDays,
  'presentDays': instance.presentDays,
  'absentDays': instance.absentDays,
  'leaveDays': instance.leaveDays,
  'lateDays': instance.lateDays,
  'onTimeDays': instance.onTimeDays,
  'dailyAvgHours': instance.dailyAvgHours,
  'monthlyAvgHours': instance.monthlyAvgHours,
  'pendingRegularisations': instance.pendingRegularisations,
  'pendingLeaves': instance.pendingLeaves,
  'periodTitle': instance.periodTitle,
};

const _$AnalyticsPeriodEnumMap = {
  AnalyticsPeriod.daily: 'daily',
  AnalyticsPeriod.weekly: 'weekly',
  AnalyticsPeriod.monthly: 'monthly',
  AnalyticsPeriod.quarterly: 'quarterly',
};

_$EmployeeAnalyticsImpl _$$EmployeeAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$EmployeeAnalyticsImpl(
  empId: json['empId'] as String,
  name: json['name'] as String,
  designation: json['designation'] as String,
  status: json['status'] as String,
  checkInTime: json['checkInTime'] as String,
  projects:
      (json['projects'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  projectCount: (json['projectCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$EmployeeAnalyticsImplToJson(
  _$EmployeeAnalyticsImpl instance,
) => <String, dynamic>{
  'empId': instance.empId,
  'name': instance.name,
  'designation': instance.designation,
  'status': instance.status,
  'checkInTime': instance.checkInTime,
  'projects': instance.projects,
  'projectCount': instance.projectCount,
};

_$ProjectAnalyticsImpl _$$ProjectAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$ProjectAnalyticsImpl(
  projectId: json['projectId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  status: json['status'] as String? ?? 'ACTIVE',
  priority: json['priority'] as String? ?? 'HIGH',
  progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
  teamSize: (json['teamSize'] as num?)?.toInt() ?? 0,
  totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
  daysLeft: (json['daysLeft'] as num?)?.toInt() ?? 0,
  teamMembers:
      (json['teamMembers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ProjectAnalyticsImplToJson(
  _$ProjectAnalyticsImpl instance,
) => <String, dynamic>{
  'projectId': instance.projectId,
  'name': instance.name,
  'description': instance.description,
  'status': instance.status,
  'priority': instance.priority,
  'progress': instance.progress,
  'teamSize': instance.teamSize,
  'totalTasks': instance.totalTasks,
  'daysLeft': instance.daysLeft,
  'teamMembers': instance.teamMembers,
};
