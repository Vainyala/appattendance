// lib/features/leaves/presentation/widgets/apply_leave_handover_section.dart
import 'package:flutter/material.dart';

class ApplyLeaveHandoverSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const ApplyLeaveHandoverSection({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Handover Person (Optional)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
