// lib/features/dashboard/presentation/screens/dashboard_screen.dart

import 'dart:async';

import 'package:appattendance/core/providers/bottom_nav_providers.dart';
import 'package:appattendance/core/providers/view_mode_provider.dart';
import 'package:appattendance/core/theme/app_gradients.dart';
import 'package:appattendance/core/theme/bottom_navigation.dart';
import 'package:appattendance/core/utils/app_colors.dart';
import 'package:appattendance/features/attendance/domain/models/attendance_model.dart';
import 'package:appattendance/features/auth/domain/models/user_model_import.dart';
import 'package:appattendance/features/auth/presentation/providers/auth_provider.dart';
import 'package:appattendance/features/dashboard/presentation/screens/dashboard_imports.dart';
import 'package:appattendance/features/leaves/presentation/screens/leave_screen.dart';
import 'package:appattendance/features/projects/presentation/widgets/projectwidgets/mapped_projects_widget.dart';
import 'package:appattendance/features/regularisation/presentation/screens/regularisation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _currentTime = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startClock();
  }

  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final viewMode = ref.watch(viewModeProvider);
    final userAsync = ref.watch(authProvider);
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: dashboardAsync.when(
          data: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome${state.user?.isManagerial == true ? '' : ' back'},",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                state.user?.name ?? 'User',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                state.user?.department ?? '',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          loading: () =>
              const Text('Loading...', style: TextStyle(color: Colors.white)),
          error: (_, __) =>
              const Text('Error', style: TextStyle(color: Colors.white)),
        ),
        actions: [
          dashboardAsync.when(
            data: (state) => state.user?.isManagerial == true
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Icon(
                      true
                          ? Icons.location_on
                          : Icons.location_off, // Replace with real geofence
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Toggle geofence if needed
                    },
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {},
              ),
              const Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    "3",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
          ),
        ],
      ),
      drawer: dashboardAsync.when(
        data: (state) => AppDrawer(user: state.user),
        loading: () =>
            const Drawer(child: Center(child: CircularProgressIndicator())),
        error: (_, __) =>
            const Drawer(child: Center(child: Text('Error loading user'))),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.dashboard(
            Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
            child: dashboardAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: $err'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(dashboardProvider.notifier).refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (state) {
                final user = state.user;
                if (user == null) {
                  return const Center(child: Text('User not found'));
                }

                final isManagerial = user.isManagerial;
                final effectiveIsManager =
                    isManagerial && viewMode == ViewMode.manager;

                final hasCheckedInToday = state.todayAttendance.any(
                  (a) => a.isCheckIn,
                );
                final isInGeofence =
                    true; // Replace with real geofence provider later

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Live Time & Date Card
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat(
                                    'EEEE, d MMMM yyyy',
                                  ).format(DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _currentTime,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.cyan.shade400.withOpacity(0.3),
                                    Colors.blue.shade400.withOpacity(0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                user.displayRole,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Employee: Check-in / Check-out
                      if (!effectiveIsManager)
                        CheckInOutWidget(
                          // hasCheckedInToday: hasCheckedInToday,
                          // isInGeofence: isInGeofence,
                        ),

                      // Common Sections
                      PresentDashboardCardSection(),
                      if (!effectiveIsManager)
                        const AttendanceBreakdownSection(),
                      // Manager-specific
                      if (effectiveIsManager) ...[
                        MetricsCounter(),

                        // ManagerDashboardContent(),
                      ],

                      // Projects (for both)
                      const MappedProjectsWidget(),

                      if (effectiveIsManager) ManagerQuickActions(user: user),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: currentIndex,
        onTabChanged: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;

          if (index != 0) {
            final screens = [
              null,
              RegularisationScreen(),
              LeaveScreen(),
              // TimesheetScreen(),
            ];
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screens[index]!),
            );
          }
        },
      ),
    );
  }
}
