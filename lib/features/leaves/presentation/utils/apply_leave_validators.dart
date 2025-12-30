// lib/features/leaves/presentation/utils/apply_leave_validators.dart
import 'package:appattendance/features/leaves/domain/models/leave_model.dart';
import 'package:flutter/material.dart';

class ApplyLeaveValidators {
  static String? validateDates(
    DateTime? fromDate,
    DateTime? toDate,
    BuildContext context,
  ) {
    if (fromDate == null || toDate == null) {
      return 'Please select both from and to dates';
    }
    if (fromDate.isAfter(toDate)) {
      return 'From date cannot be after To date';
    }
    return null;
  }

  static String? validateNotes(String notes) {
    if (notes.trim().isEmpty) {
      return 'Reason is required';
    }
    if (notes.trim().length < 10) {
      return 'Reason must be at least 10 characters';
    }
    return null;
  }

  static String? validateTime(
    TimeOfDay? fromTime,
    TimeOfDay? toTime,
    bool isHalfDayFrom,
    bool isHalfDayTo,
  ) {
    if (fromTime == null || toTime == null) {
      return 'Please select both from and to times';
    }
    if (!isHalfDayFrom && !isHalfDayTo) {
      // Full day — time optional, but if provided, from < to
      if (fromTime.hour > toTime.hour ||
          (fromTime.hour == toTime.hour && fromTime.minute >= toTime.minute)) {
        return 'From time cannot be after To time';
      }
    }
    return null;
  }

  static String? validateLeaveType(LeaveType? type) {
    if (type == null) {
      return 'Please select a leave type';
    }
    return null;
  }

  // Handover fields (optional, but validate if filled)
  static String? validateEmail(String? email) {
    if (email != null && email.isNotEmpty) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        return 'Invalid email format';
      }
    }
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone != null && phone.isNotEmpty) {
      if (phone.length < 10 || phone.length > 15) {
        return 'Phone number must be 10-15 digits';
      }
    }
    return null;
  }
}
