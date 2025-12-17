// lib/features/dashboard/presentation/screens/dashboard_screen.dart

import 'dart:async';

import 'package:appattendance/core/database/db_helper.dart';
import 'package:appattendance/core/utils/app_colors.dart';
import 'package:appattendance/features/auth/presentation/providers/auth_notifier.dart';
import 'package:appattendance/features/dashboard/presentation/widgets/common/app_drawer.dart';
import 'package:appattendance/features/dashboard/presentation/widgets/managerwidgets/metrics_counter.dart';
import 'package:appattendance/features/dashboard/presentation/widgets/managerwidgets/manager_dashboard_content.dart';
import 'package:appattendance/features/dashboard/presentation/widgets/employeewidgets/employee_dashboard_content.dart';
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
    final user = ref.watch(authProvider).value;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isManager = (user['emp_role'] ?? '').toLowerCase() == 'manager';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back,",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              user['emp_name'],
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Text(
            //   user['emp_email'],
            //   style: TextStyle(color: Colors.white70, fontSize: 12),
            // ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "3",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {},
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[800]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: AppDrawer(
        user: user,
        onLogout: () async {
          await DBHelper.instance.clearCurrentUser();
          ref.read(authProvider.notifier).logout();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.purple[50]!],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 140, 20, 20),
          child: Column(
            children: [
              // Live Time Card
              // Card(
              //   elevation: 8,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: Padding(
              //     padding: EdgeInsets.all(20),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               DateFormat(
              //                 'EEEE, d MMMM yyyy',
              //               ).format(DateTime.now()),
              //               style: TextStyle(
              //                 fontSize: 18,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //             Text(
              //               _currentTime,
              //               style: TextStyle(
              //                 fontSize: 32,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //           ],
              //         ),
              //         Container(
              //           padding: EdgeInsets.symmetric(
              //             horizontal: 16,
              //             vertical: 8,
              //           ),
              //           decoration: BoxDecoration(
              //             color: Colors.green[100],
              //             borderRadius: BorderRadius.circular(20),
              //           ),
              //           child: Text(
              //             "LIVE",
              //             style: TextStyle(
              //               color: Colors.green[800],
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              // SizedBox(height: 30),

              // Role-based Content
              isManager
                  ? ManagerDashboardContent(
                      data: {'user': user},
                    ) // MetricsCounter yahan call hoga
                  : EmployeeDashboardContent(
                      data: {'user': user},
                    ), // Simple employee view

              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar),
            label: "Regularization",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.beach_access),
            label: "Leave",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: "Timesheet",
          ),
        ],
      ),
    );
  }
}

// // lib/features/dashboard/presentation/screens/dashboard_screen.dart

// import 'dart:async';

// import 'package:appattendance/core/database/db_helper.dart';
// import 'package:appattendance/core/utils/app_colors.dart';
// import 'package:appattendance/features/auth/presentation/providers/auth_notifier.dart';
// import 'package:appattendance/features/dashboard/presentation/widgets/common/app_drawer.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';

// class DashboardScreen extends ConsumerStatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends ConsumerState<DashboardScreen> {
//   String _currentTime = '';
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _startClock();
//   }

//   void _startClock() {
//     _updateTime();
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
//   }

//   void _updateTime() {
//     final now = DateTime.now();
//     setState(() {
//       _currentTime = DateFormat('HH:mm:ss').format(now);
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = ref.watch(authProvider).value;

//     if (user == null) {
//       return Scaffold(body: Center(child: Text("Logging out...")));
//     }

//     final isManager = (user['emp_role'] ?? '').toLowerCase() == 'manager';

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: Icon(Icons.menu, color: Colors.white),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Welcome back,",
//               style: TextStyle(color: Colors.white70, fontSize: 14),
//             ),
//             Text(
//               user['emp_name'],
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               user['emp_email'],
//               style: TextStyle(color: Colors.white70, fontSize: 12),
//             ),
//           ],
//         ),
//         actions: [
//           Stack(
//             children: [
//               IconButton(
//                 icon: Icon(Icons.notifications, color: Colors.white),
//                 onPressed: () {},
//               ),
//               Positioned(
//                 right: 8,
//                 top: 8,
//                 child: Container(
//                   padding: EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Text(
//                     "3",
//                     style: TextStyle(color: Colors.white, fontSize: 10),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           IconButton(
//             icon: Icon(Icons.refresh, color: Colors.white),
//             onPressed: () {},
//           ),
//         ],
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.blue[800]!, Colors.blue[600]!],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       drawer: AppDrawer(
//         user: user,
//         onLogout: () async {
//           await DBHelper.instance.clearCurrentUser();
//           ref.read(authProvider.notifier).logout();
//           Navigator.pushReplacementNamed(context, '/login');
//         },
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.blue[50]!, Colors.purple[50]!],
//           ),
//         ),
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             children: [
//               // Live Date & Time
//               Card(
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             DateFormat(
//                               'EEEE, d MMMM yyyy',
//                             ).format(DateTime.now()),
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             _currentTime,
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.green[100],
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           "LIVE",
//                           style: TextStyle(
//                             color: Colors.green[800],
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               SizedBox(height: 20),

//               // Stats Row
//               Row(
//                 children: [
//                   Expanded(child: _statCard("Team", "5", Icons.people)),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: _statCard("Present", "0", Icons.check_circle),
//                   ),
//                   SizedBox(width: 10),
//                   Expanded(child: _statCard("Leaves", "0", Icons.beach_access)),
//                   SizedBox(width: 10),
//                   Expanded(child: _statCard("Absent", "5", Icons.cancel)),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: _statCard(
//                       "Overall Present",
//                       "100%",
//                       Icons.trending_up,
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: 30),

//               // Big Cards
//               GridView.count(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 crossAxisCount: 2,
//                 childAspectRatio: 1.2,
//                 mainAxisSpacing: 20,
//                 crossAxisSpacing: 20,
//                 children: [
//                   _bigCard("7", "PROJECTS", Icons.folder, Colors.orange[100]!),
//                   _bigCard("12", "TEAM", Icons.group, Colors.blue[100]!),
//                   _bigCard(
//                     "75%",
//                     "ATTENDANCE",
//                     Icons.bar_chart,
//                     Colors.green[100]!,
//                   ),
//                   _bigCard(
//                     "Q4 2025",
//                     "TIMESHEET",
//                     Icons.calendar_today,
//                     Colors.purple[100]!,
//                   ),
//                 ],
//               ),

//               SizedBox(height: 30),

//               // Mapped Projects
//               Text(
//                 "Mapped Project",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 15),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _projectCard(
//                       "E-Commerce Platform",
//                       "Fashion Store Inc.",
//                       "3 members",
//                       Colors.green,
//                     ),
//                   ),
//                   SizedBox(width: 15),
//                   Expanded(
//                     child: _projectCard(
//                       "Mobile App Red",
//                       "Tech Solutions Ltd",
//                       "3 members",
//                       Colors.green,
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: 20),

//               Row(
//                 children: [
//                   Expanded(
//                     child: _actionCard(
//                       "Attendance",
//                       Icons.how_to_reg,
//                       Colors.blue,
//                     ),
//                   ),
//                   SizedBox(width: 15),
//                   Expanded(
//                     child: _actionCard(
//                       "Employees",
//                       Icons.people_alt,
//                       Colors.orange,
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: 100),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.dashboard),
//             label: "Dashboard",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.edit_calendar),
//             label: "Regularization",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.beach_access),
//             label: "Leave",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.pie_chart),
//             label: "Timesheet",
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _statCard(String title, String value, IconData icon) {
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(12),
//         child: Column(
//           children: [
//             Icon(icon, size: 30, color: Colors.blue),
//             SizedBox(height: 8),
//             Text(
//               value,
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _bigCard(String value, String title, IconData icon, Color color) {
//     return Card(
//       color: color,
//       child: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: Colors.black54),
//             SizedBox(height: 10),
//             Text(
//               value,
//               style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//             ),
//             Text(title, style: TextStyle(fontSize: 14)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _projectCard(String name, String client, String members, Color color) {
//     return Card(
//       color: color,
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.folder, color: Colors.white),
//                 SizedBox(width: 10),
//                 Text(
//                   "ACT",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//             Text(
//               name,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             Text(client, style: TextStyle(color: Colors.white70)),
//             Text(members, style: TextStyle(color: Colors.white70)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _actionCard(String title, IconData icon, Color color) {
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(20),
//         child: Row(
//           children: [
//             Icon(icon, size: 40, color: color),
//             SizedBox(width: 15),
//             Text(
//               title,
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Drawer _buildDrawer(Map<String, dynamic> user, bool isManager) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           DrawerHeader(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(radius: 40, backgroundColor: Colors.white),
//                 SizedBox(height: 10),
//                 Text(
//                   user['emp_name'],
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   user['emp_email'],
//                   style: TextStyle(color: Colors.white70),
//                 ),
//                 Text(
//                   "MANAGER",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ListTile(leading: Icon(Icons.dashboard), title: Text("Dashboard")),
//           ListTile(
//             leading: Icon(Icons.calendar_today),
//             title: Text("Attendance"),
//           ),
//           if (isManager)
//             ListTile(leading: Icon(Icons.group), title: Text("Team Members")),
//           ListTile(leading: Icon(Icons.settings), title: Text("App Setting")),
//           Divider(),
//           ListTile(
//             leading: Icon(Icons.logout, color: Colors.red),
//             title: Text("Logout", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // lib/features/dashboard/presentation/screens/dashboard_screen.dart

// import 'package:appattendance/core/database/db_helper.dart';
// import 'package:appattendance/core/utils/app_colors.dart';
// import 'package:appattendance/features/auth/presentation/providers/auth_notifier.dart';
// import 'package:appattendance/features/dashboard/presentation/widgets/employeewidgets/employee_dashboard_content.dart';
// import 'package:appattendance/features/dashboard/presentation/widgets/managerwidgets/manager_dashboard_content.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sqflite/sqflite.dart';

// class DashboardScreen extends ConsumerStatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends ConsumerState<DashboardScreen> {
//   Map<String, dynamic>? dashboardData;
//   bool isLoading = true;
//   String error = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadDashboardData();
//   }

//   Future<void> _loadDashboardData() async {
//     if (!mounted) return;

//     setState(() {
//       isLoading = true;
//       error = '';
//     });

//     try {
//       // Current logged in user (full data from employee_master)
//       final userMap = ref.read(authProvider).value;

//       if (userMap == null) {
//         error = "Please login again";
//         setState(() => isLoading = false);
//         return;
//       }

//       final db = await DBHelper.instance.database;

//       // Attendance
//       final attendanceList = await db.query(
//         'employee_attendance',
//         where: 'emp_id = ?',
//         whereArgs: [userMap['emp_id']],
//         orderBy: 'att_date DESC',
//       );

//       // Projects
//       final mapped = await db.query(
//         'employee_mapped_projects',
//         where: 'emp_id = ? AND mapping_status = ?',
//         whereArgs: [userMap['emp_id'], 'active'],
//       );

//       List<Map<String, dynamic>> projects = [];
//       if (mapped.isNotEmpty) {
//         final ids = mapped.map((e) => e['project_id'] as String).toList();
//         projects = await db.query(
//           'project_master',
//           where: 'project_id IN (${ids.map((_) => '?').join(',')})',
//           whereArgs: ids,
//         );
//       }

//       // Pending counts (manager ke liye useful)
//       final pendingLeaves =
//           Sqflite.firstIntValue(
//             await db.rawQuery(
//               'SELECT COUNT(*) FROM employee_leaves WHERE leave_approval_status = ?',
//               ['pending'],
//             ),
//           ) ??
//           0;

//       final pendingReg =
//           Sqflite.firstIntValue(
//             await db.rawQuery(
//               'SELECT COUNT(*) FROM employee_regularization WHERE reg_approval_status = ?',
//               ['pending'],
//             ),
//           ) ??
//           0;

//       // Today's check-in
//       final today = '2025-12-16'; // Current date from system
//       final checkedInToday = attendanceList.any((a) => a['att_date'] == today);

//       dashboardData = {
//         'user': userMap,
//         'attendance': attendanceList,
//         'projects': projects,
//         'has_checked_in_today': checkedInToday,
//         'pending_leaves': pendingLeaves,
//         'pending_regularization': pendingReg,
//       };

//       setState(() => isLoading = false);
//     } catch (e) {
//       error = "Failed to load data";
//       debugPrint("Dashboard error: $e");
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = ref.watch(authProvider).value;

//     if (user == null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacementNamed(context, '/login');
//       });
//       return Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final isManager = (user['emp_role'] ?? '').toLowerCase() == 'manager';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Welcome"),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(icon: Icon(Icons.refresh), onPressed: _loadDashboardData),
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () async {
//               await DBHelper.instance.clearCurrentUser();
//               ref.read(authProvider.notifier).logout();
//               Navigator.pushReplacementNamed(context, '/login');
//             },
//           ),
//         ],
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : error.isNotEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error, size: 80, color: Colors.red),
//                   SizedBox(height: 20),
//                   Text(error, style: TextStyle(fontSize: 18)),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _loadDashboardData,
//                     child: Text("Retry"),
//                   ),
//                 ],
//               ),
//             )
//           : RefreshIndicator(
//               onRefresh: _loadDashboardData,
//               child: SingleChildScrollView(
//                 physics: AlwaysScrollableScrollPhysics(),
//                 child: isManager
//                     ? ManagerDashboardContent(data: dashboardData!)
//                     : EmployeeDashboardContent(data: dashboardData!),
//               ),
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _loadDashboardData,
//         child: Icon(Icons.refresh),
//       ),
//     );
//   }
// }

// // lib/features/dashboard/presentation/screens/dashboard_screen.dart

// import 'package:appattendance/core/database/db_helper.dart';
// import 'package:appattendance/core/utils/app_colors.dart';
// import 'package:appattendance/features/auth/presentation/providers/auth_notifier.dart';
// import 'package:appattendance/features/dashboard/presentation/widgets/employeewidgets/employee_dashboard_content.dart';
// import 'package:appattendance/features/dashboard/presentation/widgets/managerwidgets/manager_dashboard_content.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sqflite/sqflite.dart'; // ← Ye import zaroori tha!

// class DashboardScreen extends ConsumerStatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends ConsumerState<DashboardScreen> {
//   Map<String, dynamic>? dashboardData;
//   bool isLoading = true;
//   String error = '';

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadLocalDashboardData(); // Safe way - build ke baad call
//     });
//   }

//   Future<void> _loadLocalDashboardData() async {
//     if (!mounted) return;

//     setState(() {
//       isLoading = true;
//       error = '';
//     });

//     try {
//       // Auth state se current user le rahe hain
//       final userMap = ref.read(authProvider).value;

//       if (userMap == null) {
//         error = "User not found. Please login again.";
//         setState(() => isLoading = false);
//         return;
//       }

//       final db = await DBHelper.instance.database;

//       // Attendance history
//       final attendanceList = await db.query(
//         'employee_attendance',
//         where: 'emp_id = ?',
//         whereArgs: [userMap['emp_id']],
//         orderBy: 'att_date DESC',
//       );

//       // Assigned projects
//       final mappedProjects = await db.query(
//         'employee_mapped_projects',
//         where: 'emp_id = ? AND mapping_status = ?',
//         whereArgs: [userMap['emp_id'], 'active'],
//       );

//       List<Map<String, dynamic>> projects = [];
//       if (mappedProjects.isNotEmpty) {
//         final projectIds = mappedProjects
//             .map((m) => m['project_id'] as String)
//             .toList();
//         projects = await db.query(
//           'project_master',
//           where:
//               'project_id IN (${List.filled(projectIds.length, '?').join(', ')})',
//           whereArgs: projectIds,
//         );
//       }

//       // Pending leaves count
//       final leavesCount =
//           Sqflite.firstIntValue(
//             await db.rawQuery(
//               'SELECT COUNT(*) FROM employee_leaves WHERE emp_id = ? AND leave_approval_status = ?',
//               [userMap['emp_id'], 'pending'],
//             ),
//           ) ??
//           0;

//       // Pending regularization count
//       final regCount =
//           Sqflite.firstIntValue(
//             await db.rawQuery(
//               'SELECT COUNT(*) FROM employee_regularization WHERE emp_id = ? AND reg_approval_status = ?',
//               [userMap['emp_id'], 'pending'],
//             ),
//           ) ??
//           0;

//       // Today's check-in status
//       final todayDate = DateTime.now().toIso8601String().substring(0, 10);
//       final hasCheckedInToday =
//           attendanceList.isNotEmpty &&
//           attendanceList.any(
//             (a) => a['att_date'] == todayDate && a['att_status'] == 'checkin',
//           );

//       // Final data pack
//       dashboardData = {
//         'user': userMap,
//         'attendance': attendanceList,
//         'projects': projects,
//         'pending_leaves': leavesCount,
//         'pending_regularization': regCount,
//         'has_checked_in_today': hasCheckedInToday,
//       };

//       if (mounted) {
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       error = "Failed to load dashboard data";
//       debugPrint("Dashboard load error: $e");
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authProvider);

//     return authState.when(
//       loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
//       error: (err, stack) => Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text("Session expired", style: TextStyle(color: Colors.red)),
//               ElevatedButton(
//                 onPressed: () {
//                   ref.read(authProvider.notifier).logout();
//                   Navigator.pushReplacementNamed(context, '/login');
//                 },
//                 child: Text("Login Again"),
//               ),
//             ],
//           ),
//         ),
//       ),
//       data: (userMap) {
//         if (userMap == null) {
//           // No user - go to login
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             Navigator.pushReplacementNamed(context, '/login');
//           });
//           return Scaffold(body: Center(child: CircularProgressIndicator()));
//         }

//         // Role determine karo
//         final String role =
//             (userMap['emp_role'] ?? userMap['role'] ?? 'Employee')
//                 .toString()
//                 .toLowerCase();
//         final bool isManager = role == 'manager';

//         return Scaffold(
//           appBar: AppBar(
//             title: Text(
//               "Welcome, ${userMap['emp_name'] ?? userMap['name'] ?? 'User'}",
//             ),
//             centerTitle: true,
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             actions: [
//               IconButton(
//                 icon: Icon(Icons.refresh),
//                 onPressed: _loadLocalDashboardData,
//               ),
//               IconButton(
//                 icon: Icon(Icons.logout),
//                 onPressed: () async {
//                   await DBHelper.instance.clearCurrentUser();
//                   ref.read(authProvider.notifier).logout();
//                   Navigator.pushReplacementNamed(context, '/login');
//                 },
//               ),
//             ],
//           ),
//           body: isLoading
//               ? Center(child: CircularProgressIndicator())
//               : error.isNotEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         error,
//                         style: TextStyle(color: Colors.red, fontSize: 16),
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: _loadLocalDashboardData,
//                         child: Text("Retry"),
//                       ),
//                     ],
//                   ),
//                 )
//               : RefreshIndicator(
//                   onRefresh: _loadLocalDashboardData,
//                   child: SingleChildScrollView(
//                     physics: AlwaysScrollableScrollPhysics(),
//                     child: Padding(
//                       padding: EdgeInsets.all(16),
//                       child: isManager
//                           ? ManagerDashboardContent(data: dashboardData!)
//                           : EmployeeDashboardContent(data: dashboardData!),
//                     ),
//                   ),
//                 ),
//           floatingActionButton: FloatingActionButton(
//             onPressed: _loadLocalDashboardData,
//             child: Icon(Icons.refresh),
//             tooltip: 'Refresh Dashboard',
//           ),
//         );
//       },
//     );
//   }
// }

// // lib/features/dashboard/presentation/screens/dashboard_screen.dart
// import 'package:appattendance/core/database/db_helper.dart';
// import 'package:appattendance/core/utils/app_colors.dart';
// import 'package:appattendance/features/auth/presentation/providers/auth_notifier.dart';
// import 'package:appattendance/features/dashboard/presentation/widgets/employeewidgets/employee_dashboard_content.dart';
// import 'package:appattendance/features/dashboard/presentation/widgets/managerwidgets/manager_dashboard_content.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sqflite/sqflite.dart';

// class DashboardScreen extends ConsumerStatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends ConsumerState<DashboardScreen> {
//   Map<String, dynamic>? dashboardData;
//   bool isLoading = true;
//   String error = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadLocalDashboardData(); // Local SQLite se data load
//   }

//   // LOCAL DATA LOAD (SQLite se)
//   Future<void> _loadLocalDashboardData() async {
//     setState(() {
//       isLoading = true;
//       error = '';
//     });

//     try {
//       final userMap = ref.read(authProvider).value;
//       if (userMap == null) {
//         error = "User not found. Please login again.";
//         setState(() => isLoading = false);
//         return;
//       }

//       final db = await DBHelper.instance.database;

//       // Attendance data
//       final attendanceList = await db.query(
//         'employee_attendance',
//         where: 'emp_id = ?',
//         whereArgs: [userMap['emp_id']],
//         orderBy: 'att_date DESC',
//       );

//       // Mapped projects
//       final mappedProjects = await db.query(
//         'employee_mapped_projects',
//         where: 'emp_id = ? AND mapping_status = ?',
//         whereArgs: [userMap['emp_id'], 'active'],
//       );

//       List<Map<String, dynamic>> projects = [];
//       if (mappedProjects.isNotEmpty) {
//         final projectIds = mappedProjects.map((m) => m['project_id']).toList();
//         projects = await db.query(
//           'project_master',
//           where: 'project_id IN (${projectIds.map((_) => '?').join(',')})',
//           whereArgs: projectIds,
//         );
//       }

//       // Leaves & Regularization count
//       final leavesCount =
//           Sqflite.firstIntValue(
//             await db.rawQuery(
//               'SELECT COUNT(*) FROM employee_leaves WHERE emp_id = ? AND leave_approval_status = ?',
//               [userMap['emp_id'], 'pending'],
//             ),
//           ) ??
//           0;

//       final regCount =
//           Sqflite.firstIntValue(
//             await db.rawQuery(
//               'SELECT COUNT(*) FROM employee_regularization WHERE emp_id = ? AND reg_approval_status = ?',
//               [userMap['emp_id'], 'pending'],
//             ),
//           ) ??
//           0;

//       // Pack all data
//       dashboardData = {
//         'user': userMap,
//         'attendance': attendanceList,
//         'projects': projects,
//         'pending_leaves': leavesCount,
//         'pending_regularization': regCount,
//         'today_checkin':
//             attendanceList.isNotEmpty &&
//             attendanceList.first['att_date'] ==
//                 DateTime.now().toIso8601String().substring(0, 10),
//       };

//       setState(() => isLoading = false);
//     } catch (e) {
//       error = "Failed to load data: $e";
//       setState(() => isLoading = false);
//     }
//   }

//   // FUTURE MEIN API AAYEGA TOH YE FUNCTION USE KARNA
//   // Future<void> _loadFromApi() async { ... tera original API code ... }

//   @override
//   Widget build(BuildContext context) {
//     final user = ref.watch(authProvider).value;

//     if (user == null) {
//       return const Scaffold(
//         body: Center(child: Text("User not found. Please login again.")),
//       );
//     }

//     // Role check — document ke hisaab se 'emp_role' ya 'role' field
//     final String role = (user['emp_role'] ?? user['role'] ?? 'Employee')
//         .toString()
//         .toLowerCase();
//     final bool isManager = role == 'manager';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Welcome, ${user['emp_name'] ?? user['name'] ?? 'User'}"),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadLocalDashboardData,
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await DBHelper.instance.clearCurrentUser();
//               ref.read(authProvider.notifier).logout();
//               Navigator.pushReplacementNamed(context, '/login');
//             },
//           ),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : error.isNotEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     error,
//                     style: const TextStyle(color: Colors.red, fontSize: 16),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _loadLocalDashboardData,
//                     child: const Text("Retry"),
//                   ),
//                 ],
//               ),
//             )
//           : RefreshIndicator(
//               onRefresh: _loadLocalDashboardData,
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 child: isManager
//                     ? ManagerDashboardContent(data: dashboardData!)
//                     : EmployeeDashboardContent(data: dashboardData!),
//               ),
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _loadLocalDashboardData,
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }
// }

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
