// lib/features/regularisation/presentation/screens/regularisation_screen.dart
// FINAL UPGRADED & POLISHED VERSION - January 06, 2026
// Modern gradient UI, role-based content switch, viewMode toggle respected
// Null-safe, responsive, dark mode, safe navigation, no overflow
// FAB only for employee/employee view mode

import 'package:appattendance/core/constants/role_constants.dart';
import 'package:appattendance/core/providers/bottom_nav_providers.dart';
import 'package:appattendance/core/providers/view_mode_provider.dart';
import 'package:appattendance/core/theme/app_gradients.dart';
import 'package:appattendance/core/theme/bottom_navigation.dart';
import 'package:appattendance/core/utils/app_colors.dart';
import 'package:appattendance/features/auth/presentation/providers/auth_provider.dart';
import 'package:appattendance/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:appattendance/features/leaves/presentation/screens/leave_screen.dart';
import 'package:appattendance/features/regularisation/presentation/screens/apply_regularisation_screen.dart';
import 'package:appattendance/features/regularisation/presentation/screens/manager_regularisation_screen.dart';
import 'package:appattendance/features/regularisation/presentation/screens/employee_regularisation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegularisationScreen extends ConsumerWidget {
  const RegularisationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(authProvider);
    final viewMode = ref.watch(viewModeProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Regularisation'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.dashboard(
            Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        child: SafeArea(
          child: userAsync.when(
            data: (user) {
              if (user == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final roleName = user.role.name;
              final isManagerRole = RoleConstants.canViewTeamRequests(roleName);
              final isEmployeeViewMode = viewMode == ViewMode.employee;

              // Body content based on role + view mode
              final Widget bodyContent;
              if (RoleConstants.isEmployee(roleName) || isEmployeeViewMode) {
                // Employee view (or manager toggled to employee)
                bodyContent = EmployeeRegularisationScreen(user: user.toJson());
              } else if (isManagerRole) {
                // Manager view
                bodyContent = ManagerRegularisationScreen(
                  user: user.toJson(),
                  canApproveReject: RoleConstants.canApproveReject(roleName),
                );
              } else {
                bodyContent = Center(
                  child: Text(
                    "Access Denied",
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  ),
                );
              }

              final bool showFAB =
                  RoleConstants.isEmployee(roleName) || isEmployeeViewMode;

              return Stack(
                children: [
                  bodyContent,
                  if (showFAB)
                    Positioned(
                      bottom: 80,
                      right: 20,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ApplyRegularisationScreen(
                                user: user.toJson(),
                              ),
                            ),
                          );
                        },
                        label: const Text('Apply New'),
                        icon: const Icon(Icons.add),
                        backgroundColor: AppColors.primary,
                        elevation: 8,
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
                  'Error loading user: $err',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: BottomNavigation(
          currentIndex: 1, // Regularisation tab
          onTabChanged: (index) {
            ref.read(bottomNavIndexProvider.notifier).state = index;

            // Navigation logic: pushReplacement to avoid stack buildup
            final screens = [
              const DashboardScreen(), // Index 0
              null, // Index 1 (current - RegularisationScreen, no push needed)
              const LeaveScreen(), // Index 2
              // const TimesheetScreen(), // Index 3 (add when ready)
            ];

            if (index != 1 && screens[index] != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => screens[index]!),
              );
            }
          },
        ),
      ),
    );
  }
}

// // lib/features/regularisation/presentation/screens/regularisation_screen.dart

// import 'package:appattendance/core/constants/role_constants.dart';
// import 'package:appattendance/core/providers/bottom_nav_providers.dart';
// import 'package:appattendance/core/providers/view_mode_provider.dart'; // ViewMode.manager / employee
// import 'package:appattendance/core/theme/bottom_navigation.dart';
// import 'package:appattendance/core/utils/app_colors.dart';
// import 'package:appattendance/features/auth/presentation/providers/auth_notifier.dart';
// import 'package:appattendance/features/auth/presentation/providers/auth_provider.dart';
// import 'package:appattendance/features/regularisation/presentation/screens/apply_regularisation_screen.dart';
// import 'package:appattendance/features/regularisation/presentation/screens/manager_regularisation_screen.dart';
// import 'package:appattendance/features/regularisation/presentation/screens/employee_regularisation_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class RegularisationScreen extends ConsumerWidget {
//   const RegularisationScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(authProvider).value;
//     final viewMode = ref.watch(viewModeProvider); // manager ya employee view

//     if (user == null) {
//       return Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final roleName = (user['emp_role'] ?? '') as String;
//     final isManagerRole = RoleConstants.canViewTeamRequests(roleName);
//     final isEmployeeViewMode = viewMode == ViewMode.employee;

//     // Body content decide
//     final Widget bodyContent;
//     if (RoleConstants.isEmployee(roleName)) {
//       // R02 Employee — always own data
//       bodyContent = EmployeeRegularisationScreen(user: user);
//     } else if (isManagerRole) {
//       // Manager role
//       bodyContent = ManagerRegularisationScreen(
//         user: user,
//         canApproveReject: RoleConstants.canApproveReject(roleName),
//         isEmployeeViewMode: isEmployeeViewMode,
//         // viewingEmpId not needed — ManagerRegularisationScreen khud handle karega
//       );
//     } else {
//       bodyContent = Center(
//         child: Text(
//           "Access Denied",
//           style: TextStyle(fontSize: 20, color: Colors.red),
//         ),
//       );
//     }

//     final bool showFAB =
//         RoleConstants.isEmployee(roleName) ||
//         (isManagerRole && isEmployeeViewMode);

//     return Scaffold(
//       body: bodyContent,
//       floatingActionButton: showFAB
//           ? FloatingActionButton(
//               onPressed: () {
//                 // Navigate to Apply Form
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => ApplyRegularisationScreen(user: user),
//                   ),
//                 );
//               },
//               backgroundColor: AppColors.primary,
//               child: Icon(Icons.add, color: Colors.white),
//               tooltip: 'Apply Regularisation',
//             )
//           : null,
//       bottomNavigationBar: SafeArea(
//         child: BottomNavigation(
//           currentIndex: 1, // Regularisation tab
//           onTabChanged: (index) {
//             ref.read(bottomNavIndexProvider.notifier).state = index;
//             if (index == 0) {
//               Navigator.popUntil(context, (route) => route.isFirst);
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

// // lib/features/regularisation/presentation/screens/regularisation_screen.dart

// import 'package:appattendance/core/constants/role_constants.dart';
// import 'package:appattendance/core/providers/bottom_nav_providers.dart';
// import 'package:appattendance/core/providers/view_mode_provider.dart'; // ← Yeh provider
// import 'package:appattendance/core/theme/bottom_navigation.dart';
// import 'package:appattendance/features/auth/presentation/providers/auth_notifier.dart';
// import 'package:appattendance/features/regularisation/presentation/providers/view_mode_provider.dart';
// import 'package:appattendance/features/regularisation/presentation/screens/manager_regularisation_screen.dart';
// import 'package:appattendance/features/regularisation/presentation/screens/employee_regularisation_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class RegularisationScreen extends ConsumerWidget {
//   const RegularisationScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(authProvider).value;
//     final viewMode = ref.watch(viewModeProvider); // ← Employee ya Manager view

//     if (user == null) {
//       return Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final roleName = (user['emp_role'] ?? '') as String;
//     final isManagerRole = RoleConstants.canViewTeamRequests(roleName);

//     // Determine which employee's data to show
//     final bool isEmployeeViewMode = viewMode == ViewMode.employee;
//     final String viewingEmpId = isEmployeeViewMode && isManagerRole
//         ? ref.watch(selectedEmployeeIdProvider) ?? user['emp_id'] // Manager ne switch kiya
//         : user['emp_id']; // Normal case (own data)

//     // Role-based body content
//     final Widget bodyContent;
//     if (RoleConstants.isEmployee(roleName)) {
//       // R02 Employee — always own data
//       bodyContent = EmployeeRegularisationScreen(
//         user: user,
//         viewingEmpId: user['emp_id'],
//       );
//     } else if (isManagerRole) {
//       // Manager role — team data if manager view, selected employee if employee view
//       bodyContent = ManagerRegularisationScreen(
//         user: user,
//         canApproveReject: RoleConstants.canApproveReject(roleName),
//         viewingEmpId: viewingEmpId, // ← Yeh pass kar denge
//         isEmployeeViewMode: isEmployeeViewMode,
//       );
//     } else {
//       bodyContent = Center(child: Text("Access Denied"));
//     }

//     return Scaffold(
//       body: bodyContent,
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: BottomNavigation(
//             currentIndex: 1,
//             onTabChanged: (index) {
//               ref.read(bottomNavIndexProvider.notifier).state = index;
//               if (index == 0) {
//                 Navigator.popUntil(context, (route) => route.isFirst);
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// // lib/features/regularisation/presentation/screens/regularisation_screen.dart

// import 'package:appattendance/core/constants/role_constants.dart';
// import 'package:appattendance/core/providers/bottom_nav_providers.dart';
// import 'package:appattendance/core/theme/bottom_navigation.dart'; // Custom BottomNavigation
// import 'package:appattendance/features/auth/presentation/providers/auth_notifier.dart';
// import 'package:appattendance/features/regularisation/presentation/providers/current_viewing_employee_provider.dart';
// import 'package:appattendance/features/regularisation/presentation/screens/manager_regularisation_screen.dart';
// import 'package:appattendance/features/regularisation/presentation/screens/employee_regularisation_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class RegularisationScreen extends ConsumerWidget {
//   const RegularisationScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(authProvider).value;

//     if (user == null) {
//       return Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final roleName = (user['emp_role'] ?? '') as String;
//     // regularisation_screen.dart mein

//     final viewingEmpId =
//         ref.watch(currentViewingEmployeeProvider) ?? user['emp_id'];

//     final displayedRequests = regState.requests
//         .where((r) => r.empId == viewingEmpId)
//         .toList();

//     // Stats calculate from displayedRequests

//     // Role-based body content
//     final Widget bodyContent;
//     if (RoleConstants.isEmployee(roleName)) {
//       bodyContent = EmployeeRegularisationScreen(user: user);
//     } else if (RoleConstants.canViewTeamRequests(roleName)) {
//       bodyContent = ManagerRegularisationScreen(
//         user: user,
//         canApproveReject: RoleConstants.canApproveReject(roleName),
//       );
//     } else {
//       bodyContent = Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.block, size: 80, color: Colors.red),
//             SizedBox(height: 20),
//             Text(
//               "Access Denied",
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red,
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "You don't have permission to view Regularisation Requests",
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       );
//     }

//     return Scaffold(
//       body: bodyContent,
//       bottomNavigationBar: SafeArea(
//         child: BottomNavigation(
//           currentIndex: 1, // Regularisation tab
//           onTabChanged: (index) {
//             // Update global state
//             ref.read(bottomNavIndexProvider.notifier).state = index;

//             // Navigation logic
//             if (index == 0) {
//               // Back to Dashboard
//               Navigator.popUntil(context, (route) => route.isFirst);
//             }
//             // Other tabs (Leave, Timesheet) will be handled by main navigator or push
//           },
//         ),
//       ),
//     );
//   }
// }

// // lib/features/regularisation/presentation/screens/regularisation_screen.dart

// import 'package:appattendance/core/constants/role_constants.dart';
// import 'package:appattendance/core/providers/bottom_nav_providers.dart';
// import 'package:appattendance/core/theme/bottom_navigation.dart'; // ← Tera custom BottomNavigation
// import 'package:appattendance/features/auth/presentation/providers/auth_notifier.dart';
// import 'package:appattendance/features/regularisation/presentation/screens/manager_regularisation_screen.dart';
// import 'package:appattendance/features/regularisation/presentation/screens/employee_regularisation_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class RegularisationScreen extends ConsumerWidget {
//   const RegularisationScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(authProvider).value;

//     if (user == null) {
//       return Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final roleName = (user['emp_role'] ?? '') as String;

//     // Role-based widget
//     final Widget bodyContent;
//     if (RoleConstants.isEmployee(roleName)) {
//       bodyContent = EmployeeRegularisationScreen(user: user);
//     } else if (RoleConstants.canViewTeamRequests(roleName)) {
//       bodyContent = ManagerRegularisationScreen(
//         user: user,
//         canApproveReject: RoleConstants.canApproveReject(roleName),
//       );
//     } else {
//       bodyContent = Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.block, size: 80, color: Colors.red),
//             SizedBox(height: 20),
//             Text(
//               "Access Denied",
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red,
//               ),
//             ),
//             Text("You don't have permission to view Regularisation Requests"),
//           ],
//         ),
//       );
//     }

//     return Scaffold(
//       body: bodyContent,
//       bottomNavigationBar: BottomNavigation(
//         currentIndex: 1, // Regularisation tab = index 1
//         onTabChanged: (index) {
//           // Update global bottom nav state
//           ref.read(bottomNavIndexProvider.notifier).state = index;

//           // Handle navigation
//           if (index == 0) {
//             Navigator.popUntil(context, (route) => route.isFirst);
//           }
//           // Other tabs will be handled in main navigation
//         },
//       ),
//     );
//   }
// }

// // lib/features/regularisation/presentation/screens/regularisation_screen.dart

// import 'package:appattendance/core/constants/role_constants.dart';
// import 'package:appattendance/features/auth/presentation/providers/auth_notifier.dart';
// import 'package:appattendance/features/regularisation/presentation/screens/manager_regularisation_screen.dart';
// import 'package:appattendance/features/regularisation/presentation/screens/employee_regularisation_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class RegularisationScreen extends ConsumerWidget {
//   const RegularisationScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(authProvider).value;

//     if (user == null) {
//       return Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final roleName = (user['emp_role'] ?? '') as String;

//     // Role-based routing using constants
//     if (RoleConstants.isEmployee(roleName)) {
//       // R02 Employee → Personal view with Apply button
//       return EmployeeRegularisationScreen(user: user);
//     }

//     if (RoleConstants.canViewTeamRequests(roleName)) {
//       // R03, R04, R05, R06, R01 → Team view
//       return ManagerRegularisationScreen(
//         user: user,
//         canApproveReject: RoleConstants.canApproveReject(
//           roleName,
//         ), // R03, R04, R01 → true
//       );
//     }

//     // Fallback
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.block, size: 80, color: Colors.red),
//             SizedBox(height: 20),
//             Text(
//               "Access Denied",
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red,
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "You don't have permission to view Regularisation Requests",
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // lib/features/regularisation/presentation/screens/regularisation_screen.dart

// import 'package:appattendance/core/constants/role_constants.dart';
// import 'package:appattendance/features/auth/presentation/providers/auth_notifier.dart';
// import 'package:appattendance/features/regularisation/presentation/screens/manager_regularisation_screen.dart';
// import 'package:appattendance/features/regularisation/presentation/screens/employee_regularisation_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class RegularisationScreen extends ConsumerWidget {
//   const RegularisationScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(authProvider).value;

//     if (user == null) {
//       return Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final roleName = (user['emp_role'] ?? '') as String;

//     // Professional role check using constants
//     if (RoleConstants.isEmployee(roleName)) {
//       // R02 Employee → Personal view
//       return EmployeeRegularisationScreen(user: user);
//     }

//     if (RoleConstants.canViewTeamRequests(roleName)) {
//       // R03, R04, R05, R06, R01 → Team view
//       return ManagerRegularisationScreen(
//         user: user,
//         canApproveReject: RoleConstants.canApproveReject(
//           roleName,
//         ), // R03, R04, R01 → true
//       );
//     }

//     // Fallback
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.block, size: 80, color: Colors.red),
//             SizedBox(height: 20),
//             Text(
//               "Access Denied",
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red,
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "You don't have permission to view Regularisation Requests",
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // lib/features/regularisation/presentation/screens/regularisation_screen.dart

// import 'package:appattendance/features/auth/presentation/providers/auth_notifier.dart';
// import 'package:appattendance/features/regularisation/presentation/screens/manager_regularisation_screen.dart';
// import 'package:appattendance/features/regularisation/presentation/screens/employee_regularisation_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class RegularisationScreen extends ConsumerWidget {
//   const RegularisationScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(authProvider).value;

//     if (user == null) {
//       return Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final roleName = (user['emp_role'] ?? '').toLowerCase();

//     // Role check according to privileges table
//     final bool isEmployee = roleName == 'employee'; // R02
//     final bool isManagerOrAbove =
//         roleName.contains('manager') ||
//         roleName.contains('admin') ||
//         roleName.contains('hr') ||
//         roleName.contains('operations'); // R03, R04, R05, R06, R01

//     // Employee → Own requests only
//     if (isEmployee) {
//       return EmployeeRegularisationScreen(user: user);
//     }

//     // Manager, Sr. Manager, Operations, HR, Admin → Team requests + Approve/Reject
//     if (isManagerOrAbove) {
//       return ManagerRegularisationScreen(user: user);
//     }

//     // Fallback (should not reach here)
//     return Scaffold(body: Center(child: Text("Access Denied")));
//   }
// }
