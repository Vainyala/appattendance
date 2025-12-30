// lib/features/leaves/presentation/widgets/apply_leave_notes_section.dart
import 'package:flutter/material.dart';

class ApplyLeaveNotesSection extends StatelessWidget {
  final TextEditingController controller;

  const ApplyLeaveNotesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: 'Reason / Notes *',
        border: OutlineInputBorder(),
      ),
    );
  }
}
