// lib/features/leaves/presentation/widgets/apply_leave_type_section.dart
import 'package:appattendance/features/leaves/domain/models/leave_model.dart';
import 'package:flutter/material.dart';

class ApplyLeaveTypeSection extends StatelessWidget {
  final LeaveType selectedType;
  final ValueChanged<LeaveType> onTypeChanged;

  const ApplyLeaveTypeSection({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<LeaveType>(
      value: selectedType,
      decoration: const InputDecoration(
        labelText: 'Leave Type',
        border: OutlineInputBorder(),
      ),
      items: LeaveType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.name.toUpperCase()),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) onTypeChanged(val);
      },
    );
  }
}
