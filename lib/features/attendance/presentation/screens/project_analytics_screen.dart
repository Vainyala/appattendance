import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';
import 'package:appattendance/features/projects/domain/models/project_model.dart';
import 'package:flutter/material.dart';

class ProjectAnalyticsScreen extends StatelessWidget {
  final ProjectModel project;

  const ProjectAnalyticsScreen({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.projectName),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black, // Black background as in screenshot
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              project.projectDescription ?? 'No description available',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            _DetailRow('Status', project.displayStatus, Colors.green),
            _DetailRow('Priority', project.displayPriority, Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Progress: ${project.progress.toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            LinearProgressIndicator(
              value: project.progress / 100,
              backgroundColor: Colors.grey[800],
              color: Colors.green,
              minHeight: 12,
            ),
            const SizedBox(height: 24),
            _DetailRow('Team Size', '${project.teamSize} members', Colors.blue),
            _DetailRow('Total Tasks', '${project.totalTasks}', Colors.purple),
            _DetailRow(
              'Days Left',
              project.formattedDaysLeft,
              Colors.orangeAccent,
            ),
            const SizedBox(height: 24),
            const Text(
              'Team Members:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (project.teamMemberNames.isEmpty)
              const Text(
                'No team members assigned',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: project.teamMemberNames
                    .map(
                      (member) => Chip(
                        label: Text(
                          member,
                          style: const TextStyle(color: Colors.white),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
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

// class ProjectAnalyticsScreen extends ConsumerWidget {
//   final ProjectAnalytics project;

//   const ProjectAnalyticsScreen({required this.project, super.key});

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
