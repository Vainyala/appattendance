// lib/features/leaves/presentation/widgets/apply_leave_submit_button.dart
import 'package:appattendance/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class ApplyLeaveSubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onPressed;

  const ApplyLeaveSubmitButton({
    super.key,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Submit Leave Request',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
      ),
    );
  }
}
