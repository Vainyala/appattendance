// lib/features/projects/presentation/widgets/projectwidgets/mapped_projects_widget.dart
// FINAL UPGRADED & POLISHED VERSION - January 07, 2026
// Null-safe, role-based, toggle respected
// Manager team projects + employee mapped projects
// Responsive horizontal cards, dark mode, no overflow
// Clean production code (no debug prints)
// Navigation to ProjectDetailScreen on tap (manager/employee both)
// Uses latest ProjectModel with all fields
// FIXED: Removed unnecessary ProjectAnalytics conversion; pass ProjectModel directly

import 'package:appattendance/core/providers/view_mode_provider.dart';
import 'package:appattendance/core/utils/app_colors.dart';
import 'package:appattendance/features/attendance/presentation/screens/project_analytics_screen.dart';
import 'package:appattendance/features/auth/domain/models/user_model_import.dart';
import 'package:appattendance/features/auth/presentation/providers/auth_provider.dart';
import 'package:appattendance/features/projects/domain/models/project_model.dart';
import 'package:appattendance/features/projects/presentation/providers/project_provider.dart';
import 'package:appattendance/features/projects/presentation/screens/project_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MappedProjectsWidget extends ConsumerWidget {
  const MappedProjectsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(authProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        final isManagerial = user.isManagerial;

        // View mode toggle
        final viewMode = ref.watch(viewModeProvider);
        final effectiveManagerial =
            viewMode == ViewMode.manager && isManagerial;

        // Projects provider (manager team vs employee mapped)
        final projectsAsync = effectiveManagerial
            ? ref.watch(teamProjectProvider)
            : ref.watch(mappedProjectProvider);

        return projectsAsync.when(
          data: (projects) {
            // Adapt data safely
            List<ProjectModel> projectList = [];
            if (effectiveManagerial) {
              projectList = projects as List<ProjectModel>;
            } else {
              final mappedList = projects as List<MappedProject>;
              projectList = mappedList.map((m) => m.project).toList();
            }

            if (projectList.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "No projects assigned yet",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  effectiveManagerial ? "Team Projects" : "My Projects",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: projectList.length,
                    itemBuilder: (context, index) {
                      final project = projectList[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProjectDetailScreen(project: project),
                            ),
                          );
                        },
                        child: Container(
                          width: 260,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade800.withOpacity(0.7)
                                : Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDark ? 0.4 : 0.1,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          isDark ? 0.3 : 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.work_outline_rounded,
                                        size: 24,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        project.projectName ??
                                            'Unnamed Project',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Site: ${project.projectSite ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Client: ${project.clientName ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: project.statusColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Status: ${project.displayStatus}',
                                    style: TextStyle(
                                      color: project.statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error loading projects: $err',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error loading user: $err',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
