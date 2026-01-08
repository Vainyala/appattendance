import 'package:appattendance/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class ApplyRegularisationReasonSection extends StatelessWidget {
  final TextEditingController controller;

  const ApplyRegularisationReasonSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reason / Justification *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 5,
          minLines: 4,
          decoration: InputDecoration(
            hintText: 'Explain why you need regularisation...',
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: isDark ? Colors.grey.shade700 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: TextStyle(color: theme.colorScheme.onSurface),
          validator: (value) {
            if (value == null || value.trim().isEmpty)
              return 'Reason is required';
            if (value.trim().length < 20) return 'Min 20 characters';
            return null;
          },
        ),
      ],
    );
  }
}
