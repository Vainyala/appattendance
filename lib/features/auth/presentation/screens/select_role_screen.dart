// lib/features/auth/presentation/screens/select_role_screen.dart
// FINAL MODERN & PREMIUM VERSION - January 05, 2026
// Beautiful gradient UI, animated buttons, role cards
// View mode toggle same - dashboard mein already handle ho raha

import 'package:appattendance/core/providers/view_mode_provider.dart';
import 'package:appattendance/core/utils/app_colors.dart';
import 'package:appattendance/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectRoleScreen extends ConsumerWidget {
  const SelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.blueGrey.shade900, Colors.black87]
                : [AppColors.primary.withOpacity(0.2), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Title with animation
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 800),
                    child: Column(
                      children: [
                        Icon(
                          Icons.business_center_rounded,
                          size: 80,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Choose Your View Mode',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select how you want to experience the app',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Role Cards (Manager & Employee)
                  _RoleCard(
                    title: 'Manager View',
                    subtitle: 'Team overview, approvals, analytics',
                    icon: Icons.group_work_rounded,
                    color: Colors.green.shade600,
                    onTap: () {
                      ref.read(viewModeProvider.notifier).state =
                          ViewMode.manager;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  _RoleCard(
                    title: 'Employee View',
                    subtitle: 'Personal attendance, projects, tasks',
                    icon: Icons.person_rounded,
                    color: Colors.blue.shade600,
                    onTap: () {
                      ref.read(viewModeProvider.notifier).state =
                          ViewMode.employee;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Footer
                  Text(
                    '© 2025 Nutantek • Enterprise Edition',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Beautiful Role Card Widget
class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.5)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
// // lib/features/auth/presentation/screens/select_role_screen.dart
// import 'package:appattendance/core/providers/view_mode_provider.dart';
// import 'package:appattendance/core/utils/app_colors.dart';
// import 'package:appattendance/features/dashboard/presentation/screens/dashboard_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class SelectRoleScreen extends ConsumerWidget {
//   const SelectRoleScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Select View Mode',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 40),
//             ElevatedButton(
//               onPressed: () {
//                 ref.read(viewModeProvider.notifier).state = ViewMode.manager;
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => const DashboardScreen()),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 minimumSize: const Size(200, 50),
//               ),
//               child: const Text('Manager View'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 ref.read(viewModeProvider.notifier).state = ViewMode.employee;
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => const DashboardScreen()),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.secondary,
//                 minimumSize: const Size(200, 50),
//               ),
//               child: const Text('Employee View'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // lib/features/auth/presentation/screens/select_role_screen.dart
// import 'package:appattendance/core/providers/view_mode_provider.dart';
// import 'package:appattendance/core/utils/app_colors.dart';
// import 'package:appattendance/features/dashboard/presentation/screens/dashboard_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class SelectRoleScreen extends ConsumerWidget {
//   const SelectRoleScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Select Your Role',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 40),
//             ElevatedButton(
//               onPressed: () {
//                 ref.read(viewModeProvider.notifier).state = ViewMode.employee;
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => const DashboardScreen()),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 minimumSize: const Size(200, 56),
//               ),
//               child: const Text('Employee Mode'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 ref.read(viewModeProvider.notifier).state = ViewMode.manager;
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => const DashboardScreen()),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.secondary,
//                 minimumSize: const Size(200, 56),
//               ),
//               child: const Text('Manager Mode'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
