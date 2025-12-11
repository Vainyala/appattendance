// lib/features/dashboard/presentation/widgets/manager_dashboard_content.dart
import 'package:flutter/material.dart';

class ManagerDashboardContent extends StatelessWidget {
  final Map<String, dynamic> data;

  const ManagerDashboardContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final user = data['user'];
    final teamSize = data['teamSize'] ?? 0;
    final todayPresent = data['todayPresent'] ?? 0;
    final todayAbsent = data['todayAbsent'] ?? 0;
    final todayLate = data['todayLate'] ?? 0;
    final onLeave = data['onLeave'] ?? 0;
    final team = (data['team'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome
          Text(
            "Welcome back, ${user['name']}!",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            "Manager • ${user['department']}",
            style: TextStyle(color: Colors.grey[600]),
          ),

          const SizedBox(height: 30),

          // Today's Summary Cards
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  "Present",
                  todayPresent.toString(),
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _summaryCard(
                  "Absent",
                  todayAbsent.toString(),
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Other Stats
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _statCard("Total Team", teamSize.toString(), Icons.people),
              _statCard("On Leave", onLeave.toString(), Icons.beach_access),
              _statCard("Late Today", todayLate.toString(), Icons.access_time),
              _statCard("WFH", "2", Icons.home), // Baad mein API se aayega
            ],
          ),

          const SizedBox(height: 30),

          // Team Members List
          const Text(
            "Team Members",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (team.isEmpty)
            const Center(child: Text("No employees found"))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: team.length,
              itemBuilder: (ctx, i) {
                final emp = team[i];
                final isPresent =
                    data['recentAttendance']?.any(
                      (a) => a['userId'] == emp['_id'].toString(),
                    ) ??
                    false;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        emp['avatar'] ??
                            "https://ui-avatars.com/api/?name=${emp['name']}",
                      ),
                    ),
                    title: Text(emp['name']),
                    subtitle: Text(emp['department'] ?? "N/A"),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isPresent
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isPresent ? "Present" : "Absent",
                        style: TextStyle(
                          color: isPresent
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 16, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.blue),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
