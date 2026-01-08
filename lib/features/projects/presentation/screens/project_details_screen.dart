// lib/features/projects/presentation/screens/project_detail_screen.dart
// FINAL UPGRADED VERSION - January 07, 2026
// Full team members with designation, email, phone (call/mail actions)
// Progress bar enabled + color-coded
// Professional, clean, dark/light mode sync with ThemeColors & AppGradients

import 'package:appattendance/core/providers/app_state_provider.dart';
import 'package:appattendance/core/providers/view_mode_provider.dart';
import 'package:appattendance/core/theme/app_gradients.dart';
import 'package:appattendance/core/theme/theme_color.dart';
import 'package:appattendance/features/auth/domain/models/user_model_import.dart';
import 'package:appattendance/features/auth/presentation/providers/auth_provider.dart';
import 'package:appattendance/features/projects/domain/models/project_model.dart';
import 'package:appattendance/features/projects/presentation/providers/project_provider.dart';
import 'package:appattendance/features/team/domain/models/team_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColors = ThemeColors(context);
    final isDark = themeColors.isDark;

    final userAsync = ref.watch(authProvider);
    final viewMode = ref.watch(viewModeProvider);
    final appState = ref.watch(appStateProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
            size: 26,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppGradients.dashboard(isDark)),
        child: Stack(
          children: [
            SafeArea(
              child: userAsync.when(
                data: (user) {
                  if (user == null) {
                    return const Center(child: Text('User not found'));
                  }

                  final isManagerial = user.isManagerial;
                  final showManagerView =
                      isManagerial && viewMode != ViewMode.employee;

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref
                          .read(appStateProvider.notifier)
                          .showLoading('Refreshing project details...');
                      try {
                        await ref.refresh(
                          projectByIdProvider(project.projectId).future,
                        );
                      } catch (e) {
                        ref
                            .read(appStateProvider.notifier)
                            .showSnackBar(
                              context,
                              'Failed to refresh: ${e.toString().split('\n').first}',
                            );
                      } finally {
                        ref.read(appStateProvider.notifier).hideLoading();
                      }
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                      children: showManagerView
                          ? _buildManagerSections(context, themeColors)
                          : _buildEmployeeSections(context, themeColors),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Error loading user: $err',
                      style: TextStyle(color: themeColors.error, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),

            // Global Loading Overlay
            if (appState.isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: themeColors.primary),
                      const SizedBox(height: 16),
                      Text(
                        appState.message ?? 'Loading...',
                        style: TextStyle(
                          color: themeColors.onPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Manager View ─────────────────────────────────────────────────────────────
  List<Widget> _buildManagerSections(BuildContext context, ThemeColors colors) {
    final startDate = project.estdStartDate != null
        ? DateFormat(
            'dd MMM yyyy',
          ).format(DateTime.parse(project.estdStartDate!))
        : 'N/A';
    final endDate = project.estdEndDate != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(project.estdEndDate!))
        : 'N/A';

    return [
      _buildHeaderInfo(
        title: project.projectName,
        subtitle: 'Project ID: ${project.projectId}',
        chips: [
          _StatusChip(project.displayStatus, project.statusColor),
          const SizedBox(width: 8),
          _StatusChip(project.displayPriority, project.priorityColor),
        ],
        colors: colors,
      ),

      const SizedBox(height: 12),

      // Progress Section (uncommented & enhanced)
      _buildCard(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress', style: _sectionTitleStyle(context, colors)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: project.progress / 100,
                minHeight: 12,
                backgroundColor: colors.surfaceVariant,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${project.progress.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  project.formattedDaysLeft,
                  style: TextStyle(
                    color: project.daysLeft > 0 ? colors.success : colors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
        colors: colors,
      ),

      const SizedBox(height: 12),

      _buildSection(context, 'Project Information', [
        _InfoTile(Icons.business, 'Client', project.clientName ?? '-', colors),
        _InfoTile(
          Icons.description_outlined,
          'Description',
          project.projectDescription ?? '-',
          colors,
        ),
        _InfoTile(Icons.calendar_month, 'Start Date', startDate, colors),
        _InfoTile(Icons.calendar_month, 'End Date', endDate, colors),
        _InfoTile(
          Icons.timer_outlined,
          'Est. Effort',
          project.estdEffort ?? '-',
          colors,
        ),
        _InfoTile(
          Icons.currency_rupee,
          'Est. Cost',
          project.estdCost ?? '-',
          colors,
        ),
      ], colors),

      const SizedBox(height: 12),

      _buildSection(
        context,
        'Team Members (${project.teamMembers.length})',
        project.teamMembers.isEmpty
            ? [
                Center(
                  child: Text(
                    'No members assigned yet',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              ]
            : project.teamMembers.map((member) {
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: colors.primary.withOpacity(0.15),
                    child: Text(
                      member.name.isNotEmpty ? member.name[0] : '?',
                      style: TextStyle(color: colors.primary),
                    ),
                  ),
                  title: Text(
                    member.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.designation ?? 'Employee',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (member.email != null && member.email!.isNotEmpty)
                            GestureDetector(
                              onTap: () => launchUrl(
                                Uri.parse('mailto:${member.email}'),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Icon(
                                  Icons.email_outlined,
                                  size: 20,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          if (member.phone != null && member.phone!.isNotEmpty)
                            GestureDetector(
                              onTap: () =>
                                  launchUrl(Uri.parse('tel:${member.phone}')),
                              child: Icon(
                                Icons.phone_outlined,
                                size: 20,
                                color: colors.primary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colors.iconSecondary,
                  ),
                  onTap: () {
                    // Optional bottom sheet for full details
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              member.designation ?? 'Employee',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            if (member.email != null)
                              ListTile(
                                leading: const Icon(Icons.email),
                                title: Text(member.email!),
                                onTap: () => launchUrl(
                                  Uri.parse('mailto:${member.email}'),
                                ),
                              ),
                            if (member.phone != null)
                              ListTile(
                                leading: const Icon(Icons.phone),
                                title: Text(member.phone!),
                                onTap: () =>
                                    launchUrl(Uri.parse('tel:${member.phone}')),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
        colors,
      ),
    ];
  }

  // ── Employee View ────────────────────────────────────────────────────────────
  List<Widget> _buildEmployeeSections(
    BuildContext context,
    ThemeColors colors,
  ) {
    final assignedDate = project.projectAssignedDate != null
        ? DateFormat(
            'dd MMM yyyy',
          ).format(DateTime.parse(project.projectAssignedDate!))
        : '-';

    return [
      _buildHeaderInfo(
        title: project.projectName,
        subtitle: 'Project ID: ${project.projectId} • Assigned: $assignedDate',
        chips: [],
        colors: colors,
      ),

      const SizedBox(height: 12),

      _buildSection(context, 'Project Information', [
        _InfoTile(
          Icons.location_on_outlined,
          'Site',
          project.projectSite ?? '-',
          colors,
        ),
        if (project.projectTechstack?.isNotEmpty ?? false)
          _InfoTile(
            Icons.code,
            'Tech Stack',
            project.projectTechstack!
                .split(',')
                .map((e) => e.trim())
                .join(' • '),
            colors,
          ),
      ], colors),

      const SizedBox(height: 12),

      _buildSection(context, 'Client Details', [
        _InfoTile(Icons.business, 'Name', project.clientName ?? '-', colors),
        _InfoTile(
          Icons.phone_outlined,
          'Contact',
          project.clientContact ?? '-',
          colors,
        ),
      ], colors),

      const SizedBox(height: 12),

      _buildSection(context, 'Management', [
        _InfoTile(
          Icons.person_outline,
          'Manager',
          project.mngName ?? '-',
          colors,
        ),
        _InfoTile(
          Icons.email_outlined,
          'Email',
          project.mngEmail ?? '-',
          colors,
        ),
        _InfoTile(
          Icons.phone_outlined,
          'Contact',
          project.mngContact ?? '-',
          colors,
        ),
      ], colors),

      const SizedBox(height: 12),

      _buildSection(context, 'Summary', [
        Text(
          project.projectDescription ?? 'No project description available.',
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: colors.textPrimary,
          ),
        ),
      ], colors),
    ];
  }

  // ── Reusable Components ──────────────────────────────────────────────────────
  Widget _buildHeaderInfo({
    required String title,
    required String subtitle,
    required List<Widget> chips,
    required ThemeColors colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(fontSize: 15, color: colors.textSecondary),
        ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(children: chips),
        ],
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required Widget child,
    required ThemeColors colors,
  }) {
    return Card(
      elevation: 0,
      color: colors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
    ThemeColors colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _sectionTitleStyle(context, colors)),
        const SizedBox(height: 6),
        _buildCard(
          context,
          child: Column(children: children),
          colors: colors,
        ),
      ],
    );
  }

  TextStyle _sectionTitleStyle(BuildContext context, ThemeColors colors) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: colors.textPrimary,
    );
  }

  Widget _InfoTile(
    IconData icon,
    String label,
    String value,
    ThemeColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _StatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
