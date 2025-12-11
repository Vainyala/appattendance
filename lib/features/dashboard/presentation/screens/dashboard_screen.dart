// lib/features/dashboard/presentation/screens/dashboard_screen.dart

import 'package:appattendance/features/auth/presentation/providers/auth_notifier.dart';
import 'package:appattendance/features/dashboard/presentation/widgets/employeewidgets/employee_dashboard_content.dart';
import 'package:appattendance/features/dashboard/presentation/widgets/managerwidgets/manager_dashboard_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData(); // ← Yeh line add kar dena
  }

  // ← YEH PURA FUNCTION ADD KAR DENA
  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        error = "Please login again";
        setState(() => isLoading = false);
        return;
      }

      final response = await http
          .get(
            Uri.parse(
              "http://192.168.1.100:3000/api/dashboard",
            ), // ← Apna IP daal dena
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token", // ← YEH HEADER ZAROORI HAI
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            dashboardData = data;
            isLoading = false;
          });
        } else {
          error = data['message'] ?? "Failed to load data";
          setState(() => isLoading = false);
        }
      } else {
        error = "Server error: ${response.statusCode}";
        setState(() => isLoading = false);
      }
    } catch (e) {
      error = "No internet or server down";
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value; // Current logged in user

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not found")));
    }

    final bool isManager = user['role'] == 'manager';

    return Scaffold(
      appBar: AppBar(title: Text("Welcome ${user['name']}")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(error, style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: _loadDashboardData,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            )
          : isManager
          ? ManagerDashboardContent(data: dashboardData!)
          : EmployeeDashboardContent(data: dashboardData!),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadDashboardData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// // dashboard_screen.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:fl_chart/fl_chart.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   // Dummy user — baad mein real user aayega
//   final Map<String, dynamic> currentUser = {
//     "name": "Rahul Sharma",
//     "role": "Manager", // Ya "Employee"
//     "department": "Engineering",
//     "avatar": "R",
//   };

//   // Dummy data
//   final bool isManager = true; // false kar dena employee ke liye test karne
//   final Duration remainingTime = Duration(hours: 7, minutes: 23, seconds: 45);

//   @override
//   Widget build(BuildContext context) {
//     final bool isManager = currentUser["role"] == "Manager";

//     return Scaffold(
//       backgroundColor: const Color(0xFF1E3A8A), // Deep blue background
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.menu, color: Colors.white),
//           onPressed: () {},
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.sync, color: Colors.white),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined, color: Colors.white),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Profile Header
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundColor: Colors.white,
//                     child: Text(
//                       currentUser["avatar"],
//                       style: const TextStyle(
//                         fontSize: 48,
//                         color: Color(0xFF1E3A8A),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     currentUser["name"],
//                     style: const TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     "${currentUser["role"]} • ${currentUser["department"]}",
//                     style: const TextStyle(fontSize: 16, color: Colors.white70),
//                   ),
//                 ],
//               ),
//             ),

//             // Main Content
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
//                 ),
//                 child: isManager
//                     ? const ManagerDashboardContent()
//                     : const EmployeeDashboardContent(),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: const Color(0xFF1E3A8A),
//         unselectedItemColor: Colors.grey,
//         currentIndex: 0,
//         items: isManager
//             ? const [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.dashboard),
//                   label: "Dashboard",
//                 ),
//                 BottomNavigationBarItem(icon: Icon(Icons.group), label: "Team"),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.analytics),
//                   label: "Reports",
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.settings),
//                   label: "Settings",
//                 ),
//               ]
//             : const [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.dashboard),
//                   label: "Dashboard",
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.calendar_today),
//                   label: "Regularisation",
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.beach_access),
//                   label: "Leave",
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.timer),
//                   label: "Timesheet",
//                 ),
//               ],
//         onTap: (i) {},
//       ),
//     );
//   }
// }

// // ==================== EMPLOYEE DASHBOARD ====================
// class EmployeeDashboardContent extends StatelessWidget {
//   const EmployeeDashboardContent({super.key});

//   String formatTime(Duration d) {
//     return '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Date & Time
//           Text(
//             DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
//             style: const TextStyle(color: Colors.grey),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "09:23:45 AM",
//             style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),

//           // Remaining Time
//           Center(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               decoration: BoxDecoration(
//                 color: Colors.red.shade50,
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: Text(
//                 "Remaining: 07:23:45",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red.shade700,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 30),

//           // Check In / Out
//           Row(
//             children: [
//               Expanded(
//                 child: _actionButton("Check In", Colors.green, Icons.login),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _actionButton("Check Out", Colors.red, Icons.logout),
//               ),
//             ],
//           ),
//           const SizedBox(height: 30),

//           // Attendance Pie Chart
//           const Text(
//             "My Attendance",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 200,
//             child: PieChart(
//               PieChartData(
//                 sections: [
//                   PieChartSectionData(
//                     value: 88,
//                     color: Colors.green,
//                     title: "88%",
//                     radius: 60,
//                   ),
//                   PieChartSectionData(
//                     value: 7,
//                     color: Colors.orange,
//                     title: "7%",
//                     radius: 50,
//                   ),
//                   PieChartSectionData(
//                     value: 5,
//                     color: Colors.red,
//                     title: "5%",
//                     radius: 50,
//                   ),
//                 ],
//                 centerSpaceRadius: 40,
//               ),
//             ),
//           ),
//           const SizedBox(height: 30),

//           // Stats
//           _statCard("Today's Hours", "08:15 hrs", "Monthly Avg: 08:30 hrs"),
//           const SizedBox(height: 20),

//           // Projects
//           const Text(
//             "Mapped Projects",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           _projectTile("Project Phoenix", "In Progress", Colors.orange),
//           _projectTile("Mobile App Redesign", "On Track", Colors.green),
//           _projectTile("API Integration", "Delayed", Colors.red),
//         ],
//       ),
//     );
//   }

//   Widget _actionButton(String text, Color color, IconData icon) {
//     return ElevatedButton.icon(
//       onPressed: () {},
//       icon: Icon(icon, color: Colors.white),
//       label: Text(
//         text,
//         style: const TextStyle(fontSize: 18, color: Colors.white),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         padding: const EdgeInsets.symmetric(vertical: 18),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       ),
//     );
//   }

//   Widget _statCard(String title, String value, String subtitle) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Row(
//           children: [
//             const Icon(Icons.access_time, size: 40, color: Color(0xFF1E3A8A)),
//             const SizedBox(width: 16),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(subtitle, style: const TextStyle(color: Colors.grey)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _projectTile(String name, String status, Color color) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: color,
//           child: const Icon(Icons.work, color: Colors.white),
//         ),
//         title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text(status),
//         trailing: const Icon(Icons.arrow_forward_ios),
//       ),
//     );
//   }
// }

// // ==================== MANAGER DASHBOARD ====================
// class ManagerDashboardContent extends StatelessWidget {
//   const ManagerDashboardContent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         children: [
//           // Date & Time
//           Text(
//             DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
//             style: const TextStyle(color: Colors.grey),
//           ),
//           const Text(
//             "09:23:45 AM",
//             style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 30),

//           // Present / Absent
//           Row(
//             children: [
//               Expanded(child: _bigStatCard("Present", "42", Colors.green)),
//               const SizedBox(width: 16),
//               Expanded(child: _bigStatCard("Absent", "6", Colors.red)),
//             ],
//           ),
//           const SizedBox(height: 24),

//           // Metrics Grid
//           GridView.count(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: 2,
//             childAspectRatio: 2.2,
//             mainAxisSpacing: 16,
//             crossAxisSpacing: 16,
//             children: [
//               _metricCard("Total Employees", "48", Icons.people),
//               _metricCard("On Leave", "3", Icons.beach_access),
//               _metricCard("WFH", "3", Icons.home),
//               _metricCard("Late Today", "5", Icons.access_time),
//             ],
//           ),
//           const SizedBox(height: 30),

//           // Team Overview
//           const Text(
//             "Team Overview",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   _teamRow("Total Projects", "15", Icons.folder_open),
//                   _teamRow("Active Tasks", "89", Icons.task_alt),
//                   _teamRow("Pending Approvals", "12", Icons.pending_actions),
//                   _teamRow("Overdue Tasks", "4", Icons.warning_amber),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _bigStatCard(String label, String count, Color color) {
//     return Card(
//       color: color.withOpacity(0.1),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           children: [
//             Text(
//               count,
//               style: TextStyle(
//                 fontSize: 48,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             Text(label, style: TextStyle(fontSize: 18, color: color)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _metricCard(String title, String value, IconData icon) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Icon(icon, size: 36, color: const Color(0xFF1E3A8A)),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _teamRow(String label, String value, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         children: [
//           Icon(icon, color: const Color(0xFF1E3A8A)),
//           const SizedBox(width: 16),
//           Text(label, style: const TextStyle(fontSize: 16)),
//           const Spacer(),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
// }
