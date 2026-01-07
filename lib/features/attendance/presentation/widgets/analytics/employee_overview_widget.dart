// lib/features/attendance/presentation/widgets/employee_overview.dart
// Employee Overview Widget for Manager View (Toggle State 2)
// Shows list of team members with cards (name, photo/avatar, designation, status, projects)
// Card tap → EmployeeIndividualDetailsScreen (selected period data)
// Period-based data (selected period se filter)

import 'package:appattendance/core/utils/app_colors.dart';
import 'package:appattendance/features/attendance/domain/models/analytics_model.dart';
import 'package:appattendance/features/attendance/presentation/providers/analytics_provider.dart';
import 'package:appattendance/features/attendance/presentation/screens/employee_individual_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmployeeOverview extends ConsumerWidget {
  const EmployeeOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return analyticsAsync.when(
      data: (analytics) {
        final employees = analytics.employeeBreakdown;

        if (employees.isEmpty) {
          return Center(child: Text('No team members found'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee Overview (${employees.length} Employees)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final emp = employees[index];
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
                          builder: (_) =>
                              EmployeeIndividualDetailsScreen(employee: emp),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Avatar / Photo
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                              'https://ui-avatars.com/api/?name=${emp.name}&background=random',
                            ),
                            child: emp.status == 'Present'
                                ? null
                                : Icon(Icons.error, color: Colors.red),
                          ),
                          SizedBox(width: 16),

                          // Employee Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  emp.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  emp.designation,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Projects: ${emp.projectCount}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Status Chip
                          Chip(
                            label: Text(
                              emp.status,
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: emp.status == 'Present'
                                ? Colors.green
                                : Colors.red,
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
      error: (e, s) => Center(child: Text('Error loading employees')),
    );
  }
}
