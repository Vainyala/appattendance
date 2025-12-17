import 'package:flutter/material.dart';

class EmployeeDashboardContent extends StatelessWidget {
  final Map<String, dynamic> data;

  const EmployeeDashboardContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final user = data['user'];
    final projects = data['projects'] as List<dynamic>;
    final hasCheckedInToday = data['has_checked_in_today'] as bool;

    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${user['emp_name']}!",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text("${user['emp_role']} • ${user['emp_department']}"),

          SizedBox(height: 30),

          Card(
            color: hasCheckedInToday
                ? Colors.green.shade50
                : Colors.orange.shade50,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                hasCheckedInToday ? "Checked In Today" : "Not Checked In",
              ),
            ),
          ),

          SizedBox(height: 30),

          Text("Projects (${projects.length})"),
          ...projects.map(
            (p) => Card(
              child: ListTile(
                title: Text(p['project_name']),
                subtitle: Text(p['project_site']),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
