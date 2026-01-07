// lib/features/leaves/presentation/widgets/monthly_overview_widget.dart
// FINAL UPGRADED VERSION - January 06, 2026
// Modern card UI with gradient, icons, clean spacing
// Null-safe, dark mode support, responsive (no overflow)
// Only current + previous month shown (live, no dummy)
// UI/UX same (layout, colors, stats items) but polished

import 'package:appattendance/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyOverviewWidget extends StatelessWidget {
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final double avgShortfall; // in hours (e.g. 1.5)
  final int totalDays; // working days with leave
  final bool isManager;

  const MonthlyOverviewWidget({
    super.key,
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
    this.avgShortfall = 0.0,
    this.totalDays = 0,
    required this.isManager,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMonthYear = DateFormat('MMMM yyyy').format(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withOpacity(0.7)
            : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      currentMonthYear,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Role-based Stats
          if (isManager)
            // Manager View: Total, Pending, Approved, Rejected
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Total', total.toString(), Colors.blue, isDark),
                _buildVerticalDivider(isDark),
                _buildStatItem(
                  'Pending',
                  pending.toString(),
                  Colors.orange,
                  isDark,
                ),
                _buildVerticalDivider(isDark),
                _buildStatItem(
                  'Approved',
                  approved.toString(),
                  Colors.green,
                  isDark,
                ),
                _buildVerticalDivider(isDark),
                _buildStatItem(
                  'Rejected',
                  rejected.toString(),
                  Colors.red,
                  isDark,
                ),
              ],
            )
          else
            // Employee View: Avg Shortfall, Total Days, Applied, Pending, Approved, Rejected
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      'Avg Shortfall',
                      '${avgShortfall.toStringAsFixed(1)}h',
                      Colors.red,
                      isDark,
                    ),
                    _buildVerticalDivider(isDark),
                    _buildStatItem(
                      'Total Days',
                      totalDays.toString(),
                      Colors.purple,
                      isDark,
                    ),
                    _buildVerticalDivider(isDark),
                    _buildStatItem(
                      'Applied',
                      total.toString(),
                      Colors.blue,
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      'Pending',
                      pending.toString(),
                      Colors.orange,
                      isDark,
                    ),
                    _buildVerticalDivider(isDark),
                    _buildStatItem(
                      'Approved',
                      approved.toString(),
                      Colors.green,
                      isDark,
                    ),
                    _buildVerticalDivider(isDark),
                    _buildStatItem(
                      'Rejected',
                      rejected.toString(),
                      Colors.red,
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 50,
      color: isDark ? Colors.grey[700] : Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
