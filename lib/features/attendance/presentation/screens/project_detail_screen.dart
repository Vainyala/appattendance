// lib/features/attendance/presentation/screens/project_detail_screen.dart
// Project Details Screen (Black background as in screenshot)
// Shows project info, progress, team, tasks, days left

import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';
import 'package:flutter/material.dart';

class ProjectDetailScreen extends StatelessWidget {
  final ProjectAnalytics project;

  const ProjectDetailScreen({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(project.name), backgroundColor: Colors.black),
      body: Container(
        color: Colors.black, // Black background as in screenshot
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              project.description,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 24),
            _DetailRow('Status', project.status, Colors.green),
            _DetailRow('Priority', project.priority, Colors.orange),
            SizedBox(height: 16),
            Text(
              'Progress: ${project.progress.toStringAsFixed(1)}%',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            LinearProgressIndicator(
              value: project.progress / 100,
              backgroundColor: Colors.grey[800],
              color: Colors.green,
              minHeight: 12,
            ),
            SizedBox(height: 24),
            _DetailRow('Team Size', '${project.teamSize} members', Colors.blue),
            _DetailRow('Total Tasks', '${project.totalTasks}', Colors.purple),
            _DetailRow('Days Left', '${project.daysLeft}', Colors.orangeAccent),
            SizedBox(height: 24),
            Text(
              'Team Members:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Wrap(
              spacing: 8,
              children: project.teamMembers
                  .map(
                    (member) => Chip(
                      label: Text(
                        member,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.grey[800],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _DetailRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class ProjectDetailScreen extends ConsumerWidget {
//   final ProjectAnalytics project;

//   const ProjectDetailScreen({required this.project, super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(title: Text(project.name)),
//       body: Container(
//         color: Colors.black, // Black background as in screenshot
//         padding: EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             Text(project.description, style: TextStyle(color: Colors.white)),
//             SizedBox(height: 16),
//             LinearProgressIndicator(
//               value: project.progress / 100,
//               color: Colors.green,
//             ),
//             Text(
//               '${project.progress}% Progress',
//               style: TextStyle(color: Colors.white),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Team: ${project.teamSize} members',
//               style: TextStyle(color: Colors.white),
//             ),
//             Text(
//               'Tasks: ${project.totalTasks}',
//               style: TextStyle(color: Colors.white),
//             ),
//             Text(
//               'Days Left: ${project.daysLeft}',
//               style: TextStyle(color: Colors.white),
//             ),
//             // Add graphs if needed (fl_chart)
//           ],
//         ),
//       ),
//     );
//   }
// }
