// lib/features/attendance/presentation/widgets/active_projects.dart
// Active Projects Widget for Manager View
// Shows list of active projects with progress bar, team size, tasks, days left
// Card tap → ProjectDetailScreen (black background style)
// Period-based data (selected period se filter)

import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';
import 'package:appattendance/features/attendance/presentation/providers/analytics_provider.dart';
import 'package:appattendance/features/attendance/presentation/screens/project_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveProjects extends ConsumerWidget {
  const ActiveProjects({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return analyticsAsync.when(
      data: (analytics) {
        final projects = analytics.activeProjects;

        if (projects.isEmpty) {
          return Center(child: Text('No active projects found'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Projects (${projects.length})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProjectDetailScreen(project: project),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  project.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Chip(
                                label: Text(
                                  project.status,
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            project.description,
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Progress: ${project.progress.toStringAsFixed(1)}%',
                          ),
                          LinearProgressIndicator(
                            value: project.progress / 100,
                            backgroundColor: Colors.grey[300],
                            color: Colors.green,
                            minHeight: 10,
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _ProjectStat(
                                'Team',
                                '${project.teamSize}',
                                Icons.people,
                              ),
                              _ProjectStat(
                                'Tasks',
                                '${project.totalTasks}',
                                Icons.task,
                              ),
                              _ProjectStat(
                                'Days Left',
                                '${project.daysLeft}',
                                Icons.calendar_today,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error loading projects')),
    );
  }

  Widget _ProjectStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16),
        SizedBox(width: 4),
        Text('$value $label', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
