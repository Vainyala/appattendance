import 'package:appattendance/core/providers/view_mode_provider.dart';
import 'package:appattendance/features/attendance/presentation/screens/project_analytics_screen.dart';
import 'package:appattendance/features/auth/domain/models/user_extension.dart';
import 'package:appattendance/features/auth/presentation/providers/auth_provider.dart';
import 'package:appattendance/features/projects/domain/models/project_model.dart';
import 'package:appattendance/features/projects/presentation/providers/project_provider.dart';
import 'package:appattendance/features/projects/presentation/screens/project_analytics_screen.dart'; // ya project_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveProjects extends ConsumerWidget {
  const ActiveProjects({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authProvider);
    final viewMode = ref.watch(viewModeProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Please login to see projects'));
        }

        final isManagerial = user.isManagerial;
        final isEmployeeView = viewMode == ViewMode.employee;

        // Manager → team projects, Employee → mapped projects
        final projectsAsync = isManagerial && !isEmployeeView
            ? ref.watch(teamProjectProvider)
            : ref.watch(mappedProjectProvider);

        return projectsAsync.when(
          data: (projectsData) {
            List<ProjectModel> activeProjects = [];

            if (isManagerial && !isEmployeeView) {
              activeProjects = projectsData as List<ProjectModel>;
            } else {
              final mapped = projectsData as List<MappedProject>;
              activeProjects = mapped.map((m) => m.project).toList();
            }

            // Optional: Filter only active projects (if status exists)
            activeProjects = activeProjects
                .where((p) => p.isActive) // using extension helper
                .toList();

            if (activeProjects.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('No active projects found')),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isManagerial && !isEmployeeView
                      ? 'Team Active Projects (${activeProjects.length})'
                      : 'My Active Projects (${activeProjects.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeProjects.length,
                  itemBuilder: (context, index) {
                    final project = activeProjects[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProjectAnalyticsScreen(project: project),
                              // Ya agar detail screen chahiye to: ProjectDetailScreen(project: project),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      project.projectName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(project.displayStatus),
                                    backgroundColor: project.statusColor,
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                project.projectDescription ?? 'No description',
                                style: const TextStyle(fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Progress: ${project.progressString}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: project.progress / 100,
                                backgroundColor: Colors.grey[300],
                                color: project.statusColor,
                                minHeight: 10,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    'Days',
                                    project.formattedDaysLeft,
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error loading projects: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error loading user: $e')),
    );
  }

  Widget _ProjectStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
