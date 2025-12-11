// lib/features/dashboard/presentation/widgets/employee_dashboard_content.dart
import 'package:flutter/material.dart';

class EmployeeDashboardContent extends StatelessWidget {
  final Map<String, dynamic> data;

  const EmployeeDashboardContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final user = data['user'];
    final attendance = (data['attendance'] as List?) ?? [];
    final projects = (data['projects'] as List?) ?? [];
    final todayStatus = data['todayStatus'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi, ${user['name']}!",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Text(
            "Employee • ${user['department']}",
            style: TextStyle(color: Colors.grey[600]),
          ),

          const SizedBox(height: 30),

          // Today Status
          Card(
            color: todayStatus != null
                ? (todayStatus['status'] == 'present'
                      ? Colors.green.shade50
                      : Colors.orange.shade50)
                : Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    todayStatus != null
                        ? Icons.check_circle
                        : Icons.access_time,
                    size: 50,
                    color: todayStatus != null ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todayStatus != null
                            ? "You're Checked In!"
                            : "Not Checked In Yet",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        todayStatus?['checkInTime']
                                ?.split('T')[1]
                                ?.substring(0, 5) ??
                            "Start your day!",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Projects
          const Text(
            "Your Projects",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (projects.isEmpty)
            const Text("No projects assigned yet")
          else
            ...projects.map(
              (p) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(p['name']),
                  subtitle: Text(p['status']),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Recent Attendance
          const Text(
            "Recent Attendance",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (attendance.isEmpty)
            const Text("No attendance records")
          else
            ...attendance
                .take(7)
                .map(
                  (a) => ListTile(
                    leading: Icon(
                      a['status'] == 'present'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: a['status'] == 'present'
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text(a['date']),
                    trailing: Text(
                      a['checkInTime']?.split('T')[1]?.substring(0, 5) ?? "-",
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
