import 'package:appattendance/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class ApplyRegularisationTypeSection extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  ApplyRegularisationTypeSection({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  final List<String> _types = [
    'Full Day',
    'Check-in Only',
    'Check-out Only',
    'Half Day',
    'Shortfall',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Regularisation Type *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _types.map((type) {
            final isSelected = selectedType == type;
            return ChoiceChip(
              label: Text(
                type,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onTypeChanged(type);
              },
              selectedColor: AppColors.primary,
              backgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
            );
          }).toList(),
        ),
      ],
    );
  }
}
