// lib/features/dashboard/presentation/widgets/managerwidgets/metrics_counter.dart

import 'package:flutter/material.dart';

class MetricsCounter extends StatelessWidget {
  final int projectsCount;
  final int teamSize;
  final int presentToday;
  final String timesheetPeriod; // "Q4 2025"

  const MetricsCounter({
    super.key,
    required this.projectsCount,
    required this.teamSize,
    required this.presentToday,
    required this.timesheetPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate attendance percentage
    final double attendancePercent = teamSize > 0
        ? (presentToday / teamSize * 100)
        : 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        final crossAxisCount = isLandscape ? 4 : 2;
        final childAspectRatio = isLandscape ? 1.3 : 1.4;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMetricCard(
              title: "PROJECTS",
              value: projectsCount.toString(),
              icon: Icons.folder_rounded,
              color: Colors.orange,
              isDark: isDark,
            ),
            _buildMetricCard(
              title: "TEAM",
              value: teamSize.toString(),
              icon: Icons.people_alt_rounded,
              color: Colors.cyan,
              isDark: isDark,
            ),
            _buildMetricCard(
              title: "ATTENDANCE",
              value: "${attendancePercent.round()}%",
              icon: Icons.bar_chart_rounded,
              color: Colors.green,
              isDark: isDark,
            ),
            _buildMetricCard(
              title: "TIMESHEET",
              value: timesheetPeriod,
              icon: Icons.timeline_rounded,
              color: Colors.purple,
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.15) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? color.withOpacity(0.4) : color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.3 : 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.2 : 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 16),

            // Value
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
