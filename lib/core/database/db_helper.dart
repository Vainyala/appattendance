// lib/core/database/db_helper.dart
// Updated & Refined Version (2 Jan 2026)
// Enhanced: attendance_analytics table + queries for real analytics (no hardcoding)
// All tables aligned with dummy_data.dart + new seeding
// Future-proof for backend switch

import 'dart:convert';
import 'package:appattendance/core/database/dummy_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nutantek.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // organization_master
    await db.execute('''
      CREATE TABLE organization_master (
        org_id TEXT PRIMARY KEY,
        org_short_name TEXT UNIQUE,
        org_name TEXT NOT NULL,
        org_email TEXT,
        office_start_hrs TEXT,
        office_end_hrs TEXT,
        working_hrs_in_number INTEGER,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // user
    await db.execute('''
      CREATE TABLE user (
        emp_id TEXT PRIMARY KEY,
        email_id TEXT UNIQUE NOT NULL,
        password TEXT,
        mpin TEXT,
        otp TEXT,
        otp_expiry_time TEXT,
        emp_status TEXT,
        biometric_enabled INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // employee_master
    await db.execute('''
  CREATE TABLE employee_master (
    emp_id TEXT PRIMARY KEY,
    org_short_name TEXT,
    emp_name TEXT NOT NULL,
    emp_email TEXT UNIQUE NOT NULL,
    emp_role TEXT,
    emp_department TEXT,
    emp_phone TEXT,
    reporting_manager_id TEXT, 
    emp_joining_date TEXT,
    emp_status TEXT DEFAULT 'active',
    designation TEXT DEFAULT 'Employee',  
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (org_short_name) REFERENCES organization_master(org_short_name),
    FOREIGN KEY (reporting_manager_id) REFERENCES employee_master(emp_id)
  )
''');

    // project_master
    await db.execute('''
  CREATE TABLE project_master (
    project_id TEXT PRIMARY KEY,
    org_short_name TEXT,
    project_name TEXT NOT NULL,
    project_site TEXT,
    client_name TEXT,
    client_location TEXT,
    client_contact TEXT,
    mng_name TEXT,
    mng_email TEXT,
    mng_contact TEXT,
    project_description TEXT,
    project_techstack TEXT,
    project_assigned_date TEXT,
    estd_start_date TEXT,       -- ← Added
    estd_end_date TEXT,         -- ← Added
    estd_effort TEXT,           -- ← Added
    estd_cost TEXT,             -- ← Added
    project_status TEXT,
    project_priority TEXT,
    progress REAL DEFAULT 0.0,
    created_at TEXT,
    updated_at TEXT,
    FOREIGN KEY (org_short_name) REFERENCES organization_master(org_short_name)
  )
''');

    // project_site_mapping
    await db.execute('''
      CREATE TABLE project_site_mapping (
        project_site_id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        project_site_name TEXT,
        project_site_lat REAL,
        project_site_long REAL,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (project_id) REFERENCES project_master(project_id)
      )
    ''');

    // employee_attendance
    await db.execute('''
      CREATE TABLE employee_attendance (
        att_id TEXT PRIMARY KEY,
        emp_id TEXT NOT NULL,
        att_timestamp TEXT NOT NULL,
        att_date TEXT NOT NULL,
        att_latitude REAL,
        att_longitude REAL,
        att_geofence_name TEXT,
        project_id TEXT,
        att_notes TEXT,
        att_status TEXT CHECK(att_status IN ('checkIn', 'checkOut')),
        verification_type TEXT,
        is_verified INTEGER DEFAULT 0,
        photo_proof_path TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id),
        FOREIGN KEY (project_id) REFERENCES project_master(project_id)
      )
    ''');

    // employee_regularization
    await db.execute('''
      CREATE TABLE employee_regularization (
        reg_id TEXT PRIMARY KEY,
        emp_id TEXT NOT NULL,
        mgr_emp_id TEXT,
        reg_date_applied TEXT,
        reg_applied_for_date TEXT,
        reg_justification TEXT,
        reg_first_check_in TEXT,
        reg_last_check_out TEXT,
        shortfall_hrs TEXT,
        reg_approval_status TEXT CHECK(reg_approval_status IN ('pending', 'approved', 'rejected')),
        mgr_comments TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id),
        FOREIGN KEY (mgr_emp_id) REFERENCES employee_master(emp_id)
      )
    ''');

    // employee_leaves
    await db.execute('''
      CREATE TABLE employee_leaves (
        leave_id TEXT PRIMARY KEY,
        emp_id TEXT NOT NULL,
        mgr_emp_id TEXT,
        leave_from_date TEXT NOT NULL,
        leave_to_date TEXT NOT NULL,
        leave_type TEXT NOT NULL,
        leave_justification TEXT,
        leave_approval_status TEXT CHECK(leave_approval_status IN ('pending', 'approved', 'rejected', 'cancelled', 'query')),
        manager_comments TEXT,
        from_time TEXT,
        to_time TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id),
        FOREIGN KEY (mgr_emp_id) REFERENCES employee_master(emp_id)
      )
    ''');

    // employee_mapped_projects
    await db.execute('''
      CREATE TABLE employee_mapped_projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        emp_id TEXT NOT NULL,
        project_id TEXT NOT NULL,
        mapping_status TEXT CHECK(mapping_status IN ('active', 'deactive')),
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id),
        FOREIGN KEY (project_id) REFERENCES project_master(project_id)
      )
    ''');

    // current_user (session)
    await db.execute('''
      CREATE TABLE current_user (
        id INTEGER PRIMARY KEY,
        user_data TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // geofence_master
    await db.execute('''
      CREATE TABLE geofence_master (
        geo_id TEXT PRIMARY KEY,
        geo_name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        radius_meters REAL NOT NULL,
        is_active INTEGER DEFAULT 1,
        address TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // NEW: attendance_analytics (daily per-employee stats - no hardcoding)
    await db.execute('''
      CREATE TABLE attendance_analytics (
        analytics_id TEXT PRIMARY KEY,
        emp_id TEXT NOT NULL,
        att_date TEXT NOT NULL,
        att_type TEXT CHECK(att_type IN ('Present', 'Absent', 'Leave', 'Late', 'Holiday', 'Weekend')),
        first_checkin TEXT,
        last_checkout TEXT,
        worked_hrs REAL DEFAULT 0.0,
        shortfall_hrs REAL DEFAULT 0.0,
        on_time INTEGER DEFAULT 0,
        late INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id)
      )
    ''');

    // Seed dummy data from Dart file
    await _seedFromDartData(db);
    //   final users = await db.query('user');
    //   print("Total users seeded: ${users.length}");
    //   for (var user in users) {
    //     print("User: ${user['email_id']} | Password: ${user['password']}");
    //   }

    //   // Check employee table
    //   final emps = await db.query('employee_master');
    //   print("Total employees seeded: ${emps.length}");
    //   for (var emp in emps) {
    //     print("Employee: ${emp['emp_name']} | Email: ${emp['emp_email']}");
    //   }

    // Seed ke baad check (sirf development mein)
    if (kDebugMode) {
      final users = await db.query('user');
      if (users.isEmpty) {
        throw Exception('DB seeding failed - no users found!');
      }
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Run all upgrades in a transaction for safety
    await db.transaction((txn) async {
      // Upgrade from any old version to current
      if (oldVersion < 2) {
        // Add new columns only if they don't exist (SQLite doesn't have IF NOT EXISTS for ALTER, so check manually)
        final columns = await txn.rawQuery(
          'PRAGMA table_info(employee_attendance)',
        );

        final columnNames = columns.map((c) => c['name'] as String).toSet();

        if (!columnNames.contains('att_date')) {
          await txn.execute(
            'ALTER TABLE employee_attendance ADD COLUMN att_date TEXT;',
          );
        }
        if (!columnNames.contains('check_in_time')) {
          await txn.execute(
            'ALTER TABLE employee_attendance ADD COLUMN check_in_time TEXT;',
          );
        }
        if (!columnNames.contains('check_out_time')) {
          await txn.execute(
            'ALTER TABLE employee_attendance ADD COLUMN check_out_time TEXT;',
          );
        }
        if (!columnNames.contains('leave_type')) {
          await txn.execute(
            'ALTER TABLE employee_attendance ADD COLUMN leave_type TEXT;',
          );
        }
        if (!columnNames.contains('photo_proof_path')) {
          await txn.execute(
            'ALTER TABLE employee_attendance ADD COLUMN photo_proof_path TEXT;',
          );
        }
      }

      // Future upgrades (add more if blocks for higher versions)
      if (oldVersion < 3) {
        // Example: Add notes to attendance_analytics
        final analyticsColumns = await txn.rawQuery(
          'PRAGMA table_info(attendance_analytics)',
        );
        final analyticsNames = analyticsColumns
            .map((c) => c['name'] as String)
            .toSet();

        if (!analyticsNames.contains('notes')) {
          await txn.execute(
            'ALTER TABLE attendance_analytics ADD COLUMN notes TEXT;',
          );
        }
      }
    });
  }

  Future<void> _seedFromDartData(Database db) async {
    final Map<String, dynamic> data = dummyData;

    // Seed all tables (existing + new)
    await _insertTableData(
      db,
      'organization_master',
      data['organization_master'] ?? [],
    );
    await _insertTableData(db, 'user', data['user'] ?? []);
    await _insertTableData(
      db,
      'employee_master',
      data['employee_master'] ?? [],
    );
    await _insertTableData(db, 'project_master', data['project_master'] ?? []);
    await _insertTableData(
      db,
      'project_site_mapping',
      data['project_site_mapping'] ?? [],
    );
    await _insertTableData(
      db,
      'employee_attendance',
      data['employee_attendance'] ?? [],
    );
    await _insertTableData(
      db,
      'employee_regularization',
      data['employee_regularization'] ?? [],
    );
    await _insertTableData(
      db,
      'employee_leaves',
      data['employee_leaves'] ?? [],
    );
    await _insertTableData(
      db,
      'employee_mapped_projects',
      data['employee_mapped_projects'] ?? [],
    );
    // await _insertTableData(
    //   db,
    //   'running_serial_number',
    //   data['running_serial_number'] ?? [],
    // );
    await _insertTableData(
      db,
      'geofence_master',
      data['geofence_master'] ?? [],
    );

    // NEW: Seed attendance_analytics
    await _insertTableData(
      db,
      'attendance_analytics',
      data['attendance_analytics'] ?? [],
    );
  }

  Future<void> _insertTableData(
    Database db,
    String tableName,
    List<dynamic> dataList,
  ) async {
    for (var item in dataList) {
      final Map<String, Object?> row = Map<String, Object?>.from(item);

      // Auto-fill att_date if missing in employee_attendance
      if (tableName == 'employee_attendance') {
        if (!row.containsKey('att_date') || row['att_date'] == null) {
          final timestampStr = row['att_timestamp'] as String?;
          if (timestampStr != null) {
            try {
              final dateTime = DateTime.parse(timestampStr);
              row['att_date'] = DateFormat('yyyy-MM-dd').format(dateTime);
            } catch (_) {
              row['att_date'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
            }
          } else {
            row['att_date'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
          }
        }
      }

      await db.insert(
        tableName,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Save logged in user session
  Future<void> saveCurrentUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert('current_user', {
      'id': 1,
      'user_data': jsonEncode(user),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get logged in user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final db = await database;
    final result = await db.query(
      'current_user',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (result.isNotEmpty) {
      return jsonDecode(result.first['user_data'] as String);
    }
    return null;
  }

  // Enable/Disable biometrics
  Future<void> enableBiometricsForUser(String empId, bool enabled) async {
    final db = await database;
    await db.update(
      'user',
      {'biometric_enabled': enabled ? 1 : 0},
      where: 'emp_id = ?',
      whereArgs: [empId],
    );
  }

  Future<bool> isBiometricsEnabled(String empId) async {
    final db = await database;
    final result = await db.query(
      'user',
      columns: ['biometric_enabled'],
      where: 'emp_id = ?',
      whereArgs: [empId],
    );
    if (result.isNotEmpty) {
      return (result.first['biometric_enabled'] as int) == 1;
    }
    return false;
  }

  // Clear login session
  Future<void> clearCurrentUser() async {
    final db = await database;
    await db.delete('current_user');
  }

  // NEW: Queries for Attendance Analytics

  // Get analytics for a specific employee over a period
  Future<List<Map<String, dynamic>>> getAttendanceAnalyticsForPeriod({
    required String empId,
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await database;
    return await db.query(
      'attendance_analytics',
      where: 'emp_id = ? AND att_date BETWEEN ? AND ?',
      whereArgs: [
        empId,
        DateFormat('yyyy-MM-dd').format(start),
        DateFormat('yyyy-MM-dd').format(end),
      ],
      orderBy: 'att_date ASC',
    );
  }

  // Get aggregated team stats for manager over a period
  Future<Map<String, dynamic>> getTeamAnalyticsForPeriod({
    required String mgrEmpId,
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT
        COUNT(DISTINCT aa.emp_id) as team_size,
        SUM(CASE WHEN aa.att_type = 'Present' AND aa.on_time = 1 THEN 1 ELSE 0 END) as on_time,
        SUM(CASE WHEN aa.att_type = 'Present' AND aa.late = 1 THEN 1 ELSE 0 END) as late,
        SUM(CASE WHEN aa.att_type = 'Present' THEN 1 ELSE 0 END) as present,
        SUM(CASE WHEN aa.att_type = 'Leave' THEN 1 ELSE 0 END) as leave,
        SUM(CASE WHEN aa.att_type = 'Absent' THEN 1 ELSE 0 END) as absent
      FROM attendance_analytics aa
      JOIN employee_master em ON aa.emp_id = em.emp_id
      WHERE em.reporting_manager_id = ?
        AND aa.att_date BETWEEN ? AND ?
    ''',
      [
        mgrEmpId,
        DateFormat('yyyy-MM-dd').format(start),
        DateFormat('yyyy-MM-dd').format(end),
      ],
    );

    final row = result.isNotEmpty ? result.first : {};
    return {
      'team': row['team_size'] as int? ?? 0,
      'present': row['present'] as int? ?? 0,
      'leave': row['leave'] as int? ?? 0,
      'absent': row['absent'] as int? ?? 0,
      'onTime': row['on_time'] as int? ?? 0,
      'late': row['late'] as int? ?? 0,
    };
  }

  // Get pending counts for manager
  Future<int> getPendingLeavesCount(String mgrEmpId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM employee_leaves WHERE mgr_emp_id = ? AND leave_approval_status = ?',
      [mgrEmpId, 'pending'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getPendingRegularisationsCount(String mgrEmpId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM employee_regularization WHERE mgr_emp_id = ? AND reg_approval_status = ?',
      [mgrEmpId, 'pending'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

// // lib/core/database/db_helper.dart
// // Updated & Refined Version (2 Jan 2026)
// // Enhanced: attendance_analytics table + queries for real analytics (no hardcoding)
// // All tables aligned with dummy_data.dart + new seeding
// // Future-proof for backend switch

// import 'dart:convert';
// import 'package:appattendance/core/database/dummy_data.dart';
// import 'package:flutter/services.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:intl/intl.dart';

// class DBHelper {
//   static final DBHelper instance = DBHelper._init();
//   static Database? _database;

//   DBHelper._init();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('nutantek.db');
//     return _database!;
//   }

//   Future<Database> _initDB(String fileName) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, fileName);

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _createDB,
//       onUpgrade: _onUpgrade,
//     );
//   }

//   Future<void> _createDB(Database db, int version) async {
//     // organization_master
//     await db.execute('''
//       CREATE TABLE organization_master (
//         org_id TEXT PRIMARY KEY,
//         org_short_name TEXT UNIQUE,
//         org_name TEXT NOT NULL,
//         org_email TEXT,
//         office_start_hrs TEXT,
//         office_end_hrs TEXT,
//         working_hrs_in_number INTEGER,
//         created_at TEXT,
//         updated_at TEXT
//       )
//     ''');

//     // user
//     await db.execute('''
//       CREATE TABLE user (
//         emp_id TEXT PRIMARY KEY,
//         email_id TEXT UNIQUE NOT NULL,
//         password TEXT,
//         mpin TEXT,
//         otp TEXT,
//         otp_expiry_time TEXT,
//         emp_status TEXT,
//         biometric_enabled INTEGER DEFAULT 0,
//         created_at TEXT,
//         updated_at TEXT
//       )
//     ''');

//     // employee_master
//     await db.execute('''
//   CREATE TABLE employee_master (
//     emp_id TEXT PRIMARY KEY,
//     org_short_name TEXT,
//     emp_name TEXT NOT NULL,
//     emp_email TEXT UNIQUE NOT NULL,
//     emp_role TEXT,
//     emp_department TEXT,
//     emp_phone TEXT,
//     reporting_manager_id TEXT, 
//     emp_joining_date TEXT,
//     emp_status TEXT DEFAULT 'active',
//     designation TEXT DEFAULT 'Employee',  
//     created_at TEXT NOT NULL,
//     updated_at TEXT NOT NULL,
//     FOREIGN KEY (org_short_name) REFERENCES organization_master(org_short_name),
//     FOREIGN KEY (reporting_manager_id) REFERENCES employee_master(emp_id)
//   )
// ''');

//     // project_master
//     await db.execute('''
//       CREATE TABLE project_master (
//         project_id TEXT PRIMARY KEY,
//         org_short_name TEXT,
//         project_name TEXT NOT NULL,
//         project_site TEXT,
//         client_name TEXT,
//         client_location TEXT,
//         client_contact TEXT,
//         mng_name TEXT,
//         mng_email TEXT,
//         mng_contact TEXT,
//         project_description TEXT,
//         project_techstack TEXT,
//         project_assigned_date TEXT,
//         status TEXT DEFAULT 'active',
//         priority TEXT DEFAULT 'HIGH',
//         progress REAL DEFAULT 0.0,
//         created_at TEXT,
//         updated_at TEXT,
//         FOREIGN KEY (org_short_name) REFERENCES organization_master(org_short_name)
//       )
//     ''');

//     // project_site_mapping
//     await db.execute('''
//       CREATE TABLE project_site_mapping (
//         project_site_id TEXT PRIMARY KEY,
//         project_id TEXT NOT NULL,
//         project_site_name TEXT,
//         project_site_lat REAL,
//         project_site_long REAL,
//         created_at TEXT,
//         updated_at TEXT,
//         FOREIGN KEY (project_id) REFERENCES project_master(project_id)
//       )
//     ''');

//     // employee_attendance
//     await db.execute('''
//       CREATE TABLE employee_attendance (
//         att_id TEXT PRIMARY KEY,
//         emp_id TEXT NOT NULL,
//         att_timestamp TEXT NOT NULL,
//         att_date TEXT NOT NULL,
//         att_latitude REAL,
//         att_longitude REAL,
//         att_geofence_name TEXT,
//         project_id TEXT,
//         att_notes TEXT,
//         att_status TEXT CHECK(att_status IN ('checkIn', 'checkOut')),
//         verification_type TEXT,
//         is_verified INTEGER DEFAULT 0,
//         photo_proof_path TEXT,
//         created_at TEXT,
//         updated_at TEXT,
//         FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id),
//         FOREIGN KEY (project_id) REFERENCES project_master(project_id)
//       )
//     ''');

//     // employee_regularization
//     await db.execute('''
//       CREATE TABLE employee_regularization (
//         reg_id TEXT PRIMARY KEY,
//         emp_id TEXT NOT NULL,
//         mgr_emp_id TEXT,
//         reg_date_applied TEXT,
//         reg_applied_for_date TEXT,
//         reg_justification TEXT,
//         reg_first_check_in TEXT,
//         reg_last_check_out TEXT,
//         shortfall_hrs TEXT,
//         reg_approval_status TEXT CHECK(reg_approval_status IN ('pending', 'approved', 'rejected')),
//         mgr_comments TEXT,
//         created_at TEXT,
//         updated_at TEXT,
//         FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id),
//         FOREIGN KEY (mgr_emp_id) REFERENCES employee_master(emp_id)
//       )
//     ''');

//     // employee_leaves
//     await db.execute('''
//       CREATE TABLE employee_leaves (
//         leave_id TEXT PRIMARY KEY,
//         emp_id TEXT NOT NULL,
//         mgr_emp_id TEXT,
//         leave_from_date TEXT NOT NULL,
//         leave_to_date TEXT NOT NULL,
//         leave_type TEXT NOT NULL,
//         leave_justification TEXT,
//         leave_approval_status TEXT CHECK(leave_approval_status IN ('pending', 'approved', 'rejected', 'cancelled', 'query')),
//         manager_comments TEXT,
//         from_time TEXT,
//         to_time TEXT,
//         created_at TEXT NOT NULL,
//         updated_at TEXT NOT NULL,
//         FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id),
//         FOREIGN KEY (mgr_emp_id) REFERENCES employee_master(emp_id)
//       )
//     ''');

//     // employee_mapped_projects
//     await db.execute('''
//       CREATE TABLE employee_mapped_projects (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         emp_id TEXT NOT NULL,
//         project_id TEXT NOT NULL,
//         mapping_status TEXT CHECK(mapping_status IN ('active', 'deactive')),
//         created_at TEXT,
//         updated_at TEXT,
//         FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id),
//         FOREIGN KEY (project_id) REFERENCES project_master(project_id)
//       )
//     ''');

//     // current_user (session)
//     await db.execute('''
//       CREATE TABLE current_user (
//         id INTEGER PRIMARY KEY,
//         user_data TEXT,
//         created_at TEXT DEFAULT CURRENT_TIMESTAMP
//       )
//     ''');

//     // geofence_master
//     await db.execute('''
//       CREATE TABLE geofence_master (
//         geo_id TEXT PRIMARY KEY,
//         geo_name TEXT NOT NULL,
//         latitude REAL NOT NULL,
//         longitude REAL NOT NULL,
//         radius_meters REAL NOT NULL,
//         is_active INTEGER DEFAULT 1,
//         address TEXT,
//         created_at TEXT,
//         updated_at TEXT
//       )
//     ''');

//     // NEW: attendance_analytics (daily per-employee stats - no hardcoding)
//     await db.execute('''
//       CREATE TABLE attendance_analytics (
//         analytics_id TEXT PRIMARY KEY,
//         emp_id TEXT NOT NULL,
//         att_date TEXT NOT NULL,
//         att_type TEXT CHECK(att_type IN ('Present', 'Absent', 'Leave', 'Holiday', 'Weekend')),
//         first_checkin TEXT,
//         last_checkout TEXT,
//         worked_hrs REAL DEFAULT 0.0,
//         shortfall_hrs REAL DEFAULT 0.0,
//         on_time INTEGER DEFAULT 0,
//         late INTEGER DEFAULT 0,
//         created_at TEXT DEFAULT CURRENT_TIMESTAMP,
//         updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
//         FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id)
//       )
//     ''');

//     // Seed dummy data from Dart file
//     await _seedFromDartData(db);
//     // DEBUG: Check seeded data
//     print("✅=== DATABASE SEEDED ===");

//     // Check user table
//     final users = await db.query('user');
//     print("Total users seeded: ${users.length}");
//     for (var user in users) {
//       print("User: ${user['email_id']} | Password: ${user['password']}");
//     }

//     // Check employee table
//     final emps = await db.query('employee_master');
//     print("Total employees seeded: ${emps.length}");
//     for (var emp in emps) {
//       print("Employee: ${emp['emp_name']} | Email: ${emp['emp_email']}");
//     }

//     print("✅=== DATABASE READY ===");
//   }

//   Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
//     // Run all upgrades in a transaction for safety
//     await db.transaction((txn) async {
//       // Upgrade from any old version to current
//       if (oldVersion < 2) {
//         // Add new columns only if they don't exist (SQLite doesn't have IF NOT EXISTS for ALTER, so check manually)
//         final columns = await txn.rawQuery(
//           'PRAGMA table_info(employee_attendance)',
//         );

//         final columnNames = columns.map((c) => c['name'] as String).toSet();

//         if (!columnNames.contains('att_date')) {
//           await txn.execute(
//             'ALTER TABLE employee_attendance ADD COLUMN att_date TEXT;',
//           );
//         }
//         if (!columnNames.contains('check_in_time')) {
//           await txn.execute(
//             'ALTER TABLE employee_attendance ADD COLUMN check_in_time TEXT;',
//           );
//         }
//         if (!columnNames.contains('check_out_time')) {
//           await txn.execute(
//             'ALTER TABLE employee_attendance ADD COLUMN check_out_time TEXT;',
//           );
//         }
//         if (!columnNames.contains('leave_type')) {
//           await txn.execute(
//             'ALTER TABLE employee_attendance ADD COLUMN leave_type TEXT;',
//           );
//         }
//         if (!columnNames.contains('photo_proof_path')) {
//           await txn.execute(
//             'ALTER TABLE employee_attendance ADD COLUMN photo_proof_path TEXT;',
//           );
//         }
//       }

//       // Future upgrades (add more if blocks for higher versions)
//       if (oldVersion < 3) {
//         // Example: Add notes to attendance_analytics
//         final analyticsColumns = await txn.rawQuery(
//           'PRAGMA table_info(attendance_analytics)',
//         );
//         final analyticsNames = analyticsColumns
//             .map((c) => c['name'] as String)
//             .toSet();

//         if (!analyticsNames.contains('notes')) {
//           await txn.execute(
//             'ALTER TABLE attendance_analytics ADD COLUMN notes TEXT;',
//           );
//         }
//       }
//     });
//   }

//   Future<void> _seedFromDartData(Database db) async {
//     try {
//       // Use the dummyData constant directly from dummy_data.dart
//       final Map<String, dynamic> data = dummyData;

//       // Seed all tables (existing + new)
//       await _insertTableData(
//         db,
//         'organization_master',
//         data['organization_master'] ?? [],
//       );
//       await _insertTableData(db, 'user', data['user'] ?? []);
//       await _insertTableData(
//         db,
//         'employee_master',
//         data['employee_master'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'project_master',
//         data['project_master'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'project_site_mapping',
//         data['project_site_mapping'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'employee_attendance',
//         data['employee_attendance'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'employee_regularization',
//         data['employee_regularization'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'employee_leaves',
//         data['employee_leaves'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'employee_mapped_projects',
//         data['employee_mapped_projects'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'running_serial_number',
//         data['running_serial_number'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'geofence_master',
//         data['geofence_master'] ?? [],
//       );

//       // NEW: Seed attendance_analytics
//       await _insertTableData(
//         db,
//         'attendance_analytics',
//         data['attendance_analytics'] ?? [],
//       );

//       print("✅ All tables seeded successfully from dummy_data.dart!");
//     } catch (e) {
//       print("❌ Error seeding data: $e");
//     }
//   }

//   Future<void> _insertTableData(
//     Database db,
//     String tableName,
//     List<dynamic> dataList,
//   ) async {
//     for (var item in dataList) {
//       try {
//         final Map<String, Object?> row = Map<String, Object?>.from(item);
//         await db.insert(
//           tableName,
//           row,
//           conflictAlgorithm: ConflictAlgorithm.replace,
//         );
//       } catch (e) {
//         print("Error inserting into $tableName: $e");
//       }
//     }
//   }

//   // Save logged in user session
//   Future<void> saveCurrentUser(Map<String, dynamic> user) async {
//     final db = await database;
//     await db.insert('current_user', {
//       'id': 1,
//       'user_data': jsonEncode(user),
//     }, conflictAlgorithm: ConflictAlgorithm.replace);
//   }

//   // Get logged in user
//   Future<Map<String, dynamic>?> getCurrentUser() async {
//     final db = await database;
//     final result = await db.query(
//       'current_user',
//       where: 'id = ?',
//       whereArgs: [1],
//     );
//     if (result.isNotEmpty) {
//       return jsonDecode(result.first['user_data'] as String);
//     }
//     return null;
//   }

//   // Enable/Disable biometrics
//   Future<void> enableBiometricsForUser(String empId, bool enabled) async {
//     final db = await database;
//     await db.update(
//       'user',
//       {'biometric_enabled': enabled ? 1 : 0},
//       where: 'emp_id = ?',
//       whereArgs: [empId],
//     );
//   }

//   Future<bool> isBiometricsEnabled(String empId) async {
//     final db = await database;
//     final result = await db.query(
//       'user',
//       columns: ['biometric_enabled'],
//       where: 'emp_id = ?',
//       whereArgs: [empId],
//     );
//     if (result.isNotEmpty) {
//       return (result.first['biometric_enabled'] as int) == 1;
//     }
//     return false;
//   }

//   // Clear login session
//   Future<void> clearCurrentUser() async {
//     final db = await database;
//     await db.delete('current_user');
//   }

//   // NEW: Queries for Attendance Analytics

//   // Get analytics for a specific employee over a period
//   Future<List<Map<String, dynamic>>> getAttendanceAnalyticsForPeriod({
//     required String empId,
//     required DateTime start,
//     required DateTime end,
//   }) async {
//     final db = await database;
//     return await db.query(
//       'attendance_analytics',
//       where: 'emp_id = ? AND att_date BETWEEN ? AND ?',
//       whereArgs: [
//         empId,
//         DateFormat('yyyy-MM-dd').format(start),
//         DateFormat('yyyy-MM-dd').format(end),
//       ],
//       orderBy: 'att_date ASC',
//     );
//   }

//   // Get aggregated team stats for manager over a period
//   Future<Map<String, dynamic>> getTeamAnalyticsForPeriod({
//     required String mgrEmpId,
//     required DateTime start,
//     required DateTime end,
//   }) async {
//     final db = await database;
//     final result = await db.rawQuery(
//       '''
//       SELECT
//         COUNT(DISTINCT aa.emp_id) as team_size,
//         SUM(CASE WHEN aa.att_type = 'Present' AND aa.on_time = 1 THEN 1 ELSE 0 END) as on_time,
//         SUM(CASE WHEN aa.att_type = 'Present' AND aa.late = 1 THEN 1 ELSE 0 END) as late,
//         SUM(CASE WHEN aa.att_type = 'Present' THEN 1 ELSE 0 END) as present,
//         SUM(CASE WHEN aa.att_type = 'Leave' THEN 1 ELSE 0 END) as leave,
//         SUM(CASE WHEN aa.att_type = 'Absent' THEN 1 ELSE 0 END) as absent
//       FROM attendance_analytics aa
//       JOIN employee_master em ON aa.emp_id = em.emp_id
//       WHERE em.reporting_manager_id = ?
//         AND aa.att_date BETWEEN ? AND ?
//     ''',
//       [
//         mgrEmpId,
//         DateFormat('yyyy-MM-dd').format(start),
//         DateFormat('yyyy-MM-dd').format(end),
//       ],
//     );

//     final row = result.isNotEmpty ? result.first : {};
//     return {
//       'team': row['team_size'] as int? ?? 0,
//       'present': row['present'] as int? ?? 0,
//       'leave': row['leave'] as int? ?? 0,
//       'absent': row['absent'] as int? ?? 0,
//       'onTime': row['on_time'] as int? ?? 0,
//       'late': row['late'] as int? ?? 0,
//     };
//   }

//   // Get pending counts for manager
//   Future<int> getPendingLeavesCount(String mgrEmpId) async {
//     final db = await database;
//     final result = await db.rawQuery(
//       'SELECT COUNT(*) FROM employee_leaves WHERE mgr_emp_id = ? AND leave_approval_status = ?',
//       [mgrEmpId, 'pending'],
//     );
//     return Sqflite.firstIntValue(result) ?? 0;
//   }

//   Future<int> getPendingRegularisationsCount(String mgrEmpId) async {
//     final db = await database;
//     final result = await db.rawQuery(
//       'SELECT COUNT(*) FROM employee_regularization WHERE mgr_emp_id = ? AND reg_approval_status = ?',
//       [mgrEmpId, 'pending'],
//     );
//     return Sqflite.firstIntValue(result) ?? 0;
//   }
// }


//***********************************
//
//
//
//********************************* */ */

// lib/core/database/db_helper.dart
// Updated & Refined Version (2 Jan 2026)
// Enhanced: attendance_analytics table + queries for real analytics (no hardcoding)
// All tables aligned with dummy_data.dart + new seeding
// Future-proof for backend switch

// import 'dart:convert';
// import 'package:appattendance/core/database/dummy_data.dart';
// import 'package:flutter/services.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:intl/intl.dart';

// class DBHelper {
//   static final DBHelper instance = DBHelper._init();
//   static Database? _database;

//   DBHelper._init();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('nutantek.db');
//     return _database!;
//   }

//   Future<Database> _initDB(String fileName) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, fileName);

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _createDB,
//       onUpgrade: _onUpgrade,
//     );
//   }

//   Future<void> _createDB(Database db, int version) async {
//     // organization_master
//     await db.execute('''
//       CREATE TABLE organization_master (
//         org_id TEXT PRIMARY KEY,
//         org_short_name TEXT UNIQUE,
//         org_name TEXT NOT NULL,
//         org_email TEXT,
//         office_start_hrs TEXT,
//         office_end_hrs TEXT,
//         working_hrs_in_number INTEGER,
//         created_at TEXT,
//         updated_at TEXT
//       )
//     ''');

//     // user
//     await db.execute('''
//       CREATE TABLE user (
//         emp_id TEXT PRIMARY KEY,
//         email_id TEXT UNIQUE NOT NULL,
//         password TEXT,
//         mpin TEXT,
//         otp TEXT,
//         otp_expiry_time TEXT,
//         emp_status TEXT,
//         biometric_enabled INTEGER DEFAULT 0,
//         created_at TEXT,
//         updated_at TEXT
//       )
//     ''');

//     // employee_master
//     await db.execute('''
//   CREATE TABLE employee_master (
//     emp_id TEXT PRIMARY KEY,
//     org_short_name TEXT,
//     emp_name TEXT NOT NULL,
//     emp_email TEXT UNIQUE NOT NULL,
//     emp_role TEXT,
//     emp_department TEXT,
//     emp_phone TEXT,
//     reporting_manager_id TEXT, 
//     emp_joining_date TEXT,
//     emp_status TEXT DEFAULT 'active',
//     designation TEXT DEFAULT 'Employee',  
//     created_at TEXT NOT NULL,
//     updated_at TEXT NOT NULL,
//     FOREIGN KEY (org_short_name) REFERENCES organization_master(org_short_name),
//     FOREIGN KEY (reporting_manager_id) REFERENCES employee_master(emp_id)
//   )
// ''');

//     // project_master
//     await db.execute('''
//       CREATE TABLE project_master (
//         project_id TEXT PRIMARY KEY,
//         org_short_name TEXT,
//         project_name TEXT NOT NULL,
//         project_site TEXT,
//         client_name TEXT,
//         client_location TEXT,
//         client_contact TEXT,
//         mng_name TEXT,
//         mng_email TEXT,
//         mng_contact TEXT,
//         project_description TEXT,
//         project_techstack TEXT,
//         project_assigned_date TEXT,
//         status TEXT DEFAULT 'active',
//         priority TEXT DEFAULT 'HIGH',
//         progress REAL DEFAULT 0.0,
//         created_at TEXT,
//         updated_at TEXT,
//         FOREIGN KEY (org_short_name) REFERENCES organization_master(org_short_name)
//       )
//     ''');

//     // project_site_mapping
//     await db.execute('''
//       CREATE TABLE project_site_mapping (
//         project_site_id TEXT PRIMARY KEY,
//         project_id TEXT NOT NULL,
//         project_site_name TEXT,
//         project_site_lat REAL,
//         project_site_long REAL,
//         created_at TEXT,
//         updated_at TEXT,
//         FOREIGN KEY (project_id) REFERENCES project_master(project_id)
//       )
//     ''');

//     // employee_attendance
//     await db.execute('''
//       CREATE TABLE employee_attendance (
//         att_id TEXT PRIMARY KEY,
//         emp_id TEXT NOT NULL,
//         att_timestamp TEXT NOT NULL,
//         att_date TEXT NOT NULL,
//         att_latitude REAL,
//         att_longitude REAL,
//         att_geofence_name TEXT,
//         project_id TEXT,
//         att_notes TEXT,
//         att_status TEXT CHECK(att_status IN ('checkIn', 'checkOut')),
//         verification_type TEXT,
//         is_verified INTEGER DEFAULT 0,
//         photo_proof_path TEXT,
//         created_at TEXT,
//         updated_at TEXT,
//         FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id),
//         FOREIGN KEY (project_id) REFERENCES project_master(project_id)
//       )
//     ''');

//     // employee_regularization
//     await db.execute('''
//       CREATE TABLE employee_regularization (
//         reg_id TEXT PRIMARY KEY,
//         emp_id TEXT NOT NULL,
//         mgr_emp_id TEXT,
//         reg_date_applied TEXT,
//         reg_applied_for_date TEXT,
//         reg_justification TEXT,
//         reg_first_check_in TEXT,
//         reg_last_check_out TEXT,
//         shortfall_hrs TEXT,
//         reg_approval_status TEXT CHECK(reg_approval_status IN ('pending', 'approved', 'rejected')),
//         mgr_comments TEXT,
//         created_at TEXT,
//         updated_at TEXT,
//         FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id),
//         FOREIGN KEY (mgr_emp_id) REFERENCES employee_master(emp_id)
//       )
//     ''');

//     // employee_leaves
//     await db.execute('''
//       CREATE TABLE employee_leaves (
//         leave_id TEXT PRIMARY KEY,
//         emp_id TEXT NOT NULL,
//         mgr_emp_id TEXT,
//         leave_from_date TEXT NOT NULL,
//         leave_to_date TEXT NOT NULL,
//         leave_type TEXT NOT NULL,
//         leave_justification TEXT,
//         leave_approval_status TEXT CHECK(leave_approval_status IN ('pending', 'approved', 'rejected', 'cancelled', 'query')),
//         manager_comments TEXT,
//         from_time TEXT,
//         to_time TEXT,
//         created_at TEXT NOT NULL,
//         updated_at TEXT NOT NULL,
//         FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id),
//         FOREIGN KEY (mgr_emp_id) REFERENCES employee_master(emp_id)
//       )
//     ''');

//     // employee_mapped_projects
//     await db.execute('''
//       CREATE TABLE employee_mapped_projects (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         emp_id TEXT NOT NULL,
//         project_id TEXT NOT NULL,
//         mapping_status TEXT CHECK(mapping_status IN ('active', 'deactive')),
//         created_at TEXT,
//         updated_at TEXT,
//         FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id),
//         FOREIGN KEY (project_id) REFERENCES project_master(project_id)
//       )
//     ''');

//     // current_user (session)
//     await db.execute('''
//       CREATE TABLE current_user (
//         id INTEGER PRIMARY KEY,
//         user_data TEXT,
//         created_at TEXT DEFAULT CURRENT_TIMESTAMP
//       )
//     ''');

//     // geofence_master
//     await db.execute('''
//       CREATE TABLE geofence_master (
//         geo_id TEXT PRIMARY KEY,
//         geo_name TEXT NOT NULL,
//         latitude REAL NOT NULL,
//         longitude REAL NOT NULL,
//         radius_meters REAL NOT NULL,
//         is_active INTEGER DEFAULT 1,
//         address TEXT,
//         created_at TEXT,
//         updated_at TEXT
//       )
//     ''');

//     // NEW: attendance_analytics (daily per-employee stats - no hardcoding)
//     await db.execute('''
//       CREATE TABLE attendance_analytics (
//         analytics_id TEXT PRIMARY KEY,
//         emp_id TEXT NOT NULL,
//         att_date TEXT NOT NULL,
//         att_type TEXT CHECK(att_type IN ('Present', 'Absent', 'Leave', 'Holiday', 'Weekend')),
//         first_checkin TEXT,
//         last_checkout TEXT,
//         worked_hrs REAL DEFAULT 0.0,
//         shortfall_hrs REAL DEFAULT 0.0,
//         on_time INTEGER DEFAULT 0,
//         late INTEGER DEFAULT 0,
//         created_at TEXT DEFAULT CURRENT_TIMESTAMP,
//         updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
//         FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id)
//       )
//     ''');

//     // Seed dummy data from Dart file
//     await _seedFromDartData(db);
//   }

//   Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
//     // Run all upgrades in a transaction for safety
//     await db.transaction((txn) async {
//       // Upgrade from any old version to current
//       if (oldVersion < 2) {
//         // Add new columns only if they don't exist (SQLite doesn't have IF NOT EXISTS for ALTER, so check manually)
//         final columns = await txn.rawQuery(
//           'PRAGMA table_info(employee_attendance)',
//         );

//         final columnNames = columns.map((c) => c['name'] as String).toSet();

//         if (!columnNames.contains('att_date')) {
//           await txn.execute(
//             'ALTER TABLE employee_attendance ADD COLUMN att_date TEXT;',
//           );
//         }
//         if (!columnNames.contains('check_in_time')) {
//           await txn.execute(
//             'ALTER TABLE employee_attendance ADD COLUMN check_in_time TEXT;',
//           );
//         }
//         if (!columnNames.contains('check_out_time')) {
//           await txn.execute(
//             'ALTER TABLE employee_attendance ADD COLUMN check_out_time TEXT;',
//           );
//         }
//         if (!columnNames.contains('leave_type')) {
//           await txn.execute(
//             'ALTER TABLE employee_attendance ADD COLUMN leave_type TEXT;',
//           );
//         }
//         if (!columnNames.contains('photo_proof_path')) {
//           await txn.execute(
//             'ALTER TABLE employee_attendance ADD COLUMN photo_proof_path TEXT;',
//           );
//         }
//       }

//       // Future upgrades (add more if blocks for higher versions)
//       if (oldVersion < 3) {
//         // Example: Add notes to attendance_analytics
//         final analyticsColumns = await txn.rawQuery(
//           'PRAGMA table_info(attendance_analytics)',
//         );
//         final analyticsNames = analyticsColumns
//             .map((c) => c['name'] as String)
//             .toSet();

//         if (!analyticsNames.contains('notes')) {
//           await txn.execute(
//             'ALTER TABLE attendance_analytics ADD COLUMN notes TEXT;',
//           );
//         }
//       }
//     });
//   }

//   Future<void> _seedFromDartData(Database db) async {
//     try {
//       // Use the dummyData constant directly from dummy_data.dart
//       final Map<String, dynamic> data = dummyData;

//       // Seed all tables (existing + new)
//       await _insertTableData(
//         db,
//         'organization_master',
//         data['organization_master'] ?? [],
//       );
//       await _insertTableData(db, 'user', data['user'] ?? []);
//       await _insertTableData(
//         db,
//         'employee_master',
//         data['employee_master'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'project_master',
//         data['project_master'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'project_site_mapping',
//         data['project_site_mapping'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'employee_attendance',
//         data['employee_attendance'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'employee_regularization',
//         data['employee_regularization'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'employee_leaves',
//         data['employee_leaves'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'employee_mapped_projects',
//         data['employee_mapped_projects'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'running_serial_number',
//         data['running_serial_number'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'geofence_master',
//         data['geofence_master'] ?? [],
//       );

//       // NEW: Seed attendance_analytics
//       await _insertTableData(
//         db,
//         'attendance_analytics',
//         data['attendance_analytics'] ?? [],
//       );
//     } catch (e) {
//       // Silent fail or log without print
//     }
//   }

//   Future<void> _insertTableData(
//     Database db,
//     String tableName,
//     List<dynamic> dataList,
//   ) async {
//     for (var item in dataList) {
//       try {
//         final Map<String, Object?> row = Map<String, Object?>.from(item);
//         await db.insert(
//           tableName,
//           row,
//           conflictAlgorithm: ConflictAlgorithm.replace,
//         );
//       } catch (e) {
//         // Silent fail
//       }
//     }
//   }

//   // Save logged in user session
//   Future<void> saveCurrentUser(Map<String, dynamic> user) async {
//     final db = await database;
//     await db.insert('current_user', {
//       'id': 1,
//       'user_data': jsonEncode(user),
//     }, conflictAlgorithm: ConflictAlgorithm.replace);
//   }

//   // Get logged in user
//   Future<Map<String, dynamic>?> getCurrentUser() async {
//     final db = await database;
//     final result = await db.query(
//       'current_user',
//       where: 'id = ?',
//       whereArgs: [1],
//     );
//     if (result.isNotEmpty) {
//       return jsonDecode(result.first['user_data'] as String);
//     }
//     return null;
//   }

//   // Enable/Disable biometrics
//   Future<void> enableBiometricsForUser(String empId, bool enabled) async {
//     final db = await database;
//     await db.update(
//       'user',
//       {'biometric_enabled': enabled ? 1 : 0},
//       where: 'emp_id = ?',
//       whereArgs: [empId],
//     );
//   }

//   Future<bool> isBiometricsEnabled(String empId) async {
//     final db = await database;
//     final result = await db.query(
//       'user',
//       columns: ['biometric_enabled'],
//       where: 'emp_id = ?',
//       whereArgs: [empId],
//     );
//     if (result.isNotEmpty) {
//       return (result.first['biometric_enabled'] as int) == 1;
//     }
//     return false;
//   }

//   // Clear login session
//   Future<void> clearCurrentUser() async {
//     final db = await database;
//     await db.delete('current_user');
//   }

//   // NEW: Queries for Attendance Analytics

//   // Get analytics for a specific employee over a period
//   Future<List<Map<String, dynamic>>> getAttendanceAnalyticsForPeriod({
//     required String empId,
//     required DateTime start,
//     required DateTime end,
//   }) async {
//     final db = await database;
//     return await db.query(
//       'attendance_analytics',
//       where: 'emp_id = ? AND att_date BETWEEN ? AND ?',
//       whereArgs: [
//         empId,
//         DateFormat('yyyy-MM-dd').format(start),
//         DateFormat('yyyy-MM-dd').format(end),
//       ],
//       orderBy: 'att_date ASC',
//     );
//   }

//   // Get aggregated team stats for manager over a period
//   Future<Map<String, dynamic>> getTeamAnalyticsForPeriod({
//     required String mgrEmpId,
//     required DateTime start,
//     required DateTime end,
//   }) async {
//     final db = await database;
//     final result = await db.rawQuery(
//       '''
//       SELECT
//         COUNT(DISTINCT aa.emp_id) as team_size,
//         SUM(CASE WHEN aa.att_type = 'Present' AND aa.on_time = 1 THEN 1 ELSE 0 END) as on_time,
//         SUM(CASE WHEN aa.att_type = 'Present' AND aa.late = 1 THEN 1 ELSE 0 END) as late,
//         SUM(CASE WHEN aa.att_type = 'Present' THEN 1 ELSE 0 END) as present,
//         SUM(CASE WHEN aa.att_type = 'Leave' THEN 1 ELSE 0 END) as leave,
//         SUM(CASE WHEN aa.att_type = 'Absent' THEN 1 ELSE 0 END) as absent
//       FROM attendance_analytics aa
//       JOIN employee_master em ON aa.emp_id = em.emp_id
//       WHERE em.reporting_manager_id = ?
//         AND aa.att_date BETWEEN ? AND ?
//     ''',
//       [
//         mgrEmpId,
//         DateFormat('yyyy-MM-dd').format(start),
//         DateFormat('yyyy-MM-dd').format(end),
//       ],
//     );

//     final row = result.isNotEmpty ? result.first : {};
//     return {
//       'team': row['team_size'] as int? ?? 0,
//       'present': row['present'] as int? ?? 0,
//       'leave': row['leave'] as int? ?? 0,
//       'absent': row['absent'] as int? ?? 0,
//       'onTime': row['on_time'] as int? ?? 0,
//       'late': row['late'] as int? ?? 0,
//     };
//   }

//   // Get pending counts for manager
//   Future<int> getPendingLeavesCount(String mgrEmpId) async {
//     final db = await database;
//     final result = await db.rawQuery(
//       'SELECT COUNT(*) FROM employee_leaves WHERE mgr_emp_id = ? AND leave_approval_status = ?',
//       [mgrEmpId, 'pending'],
//     );
//     return Sqflite.firstIntValue(result) ?? 0;
//   }

//   Future<int> getPendingRegularisationsCount(String mgrEmpId) async {
//     final db = await database;
//     final result = await db.rawQuery(
//       'SELECT COUNT(*) FROM employee_regularization WHERE mgr_emp_id = ? AND reg_approval_status = ?',
//       [mgrEmpId, 'pending'],
//     );
//     return Sqflite.firstIntValue(result) ?? 0;
//   }
// }

// ye connect h json se

// class DBHelper {
//   static final DBHelper instance = DBHelper._init();
//   static Database? _database;

//   DBHelper._init();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('nutantek.db');
//     return _database!;
//   }

//   Future<Database> _initDB(String fileName) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, fileName);

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _createDB,
//       onUpgrade: _onUpgrade,
//     );
//   }

//   Future<void> _createDB(Database db, int version) async {
//     // organization_master
//     await db.execute('''
//       CREATE TABLE organization_master (
//         org_id TEXT PRIMARY KEY,
//         org_short_name TEXT UNIQUE,
//         org_name TEXT NOT NULL,
//         org_email TEXT,
//         office_start_hrs TEXT,
//         office_end_hrs TEXT,
//         working_hrs_in_number INTEGER,
//         created_at TEXT,
//         updated_at TEXT
//       )
//     ''');

//     // user
//     await db.execute('''
//       CREATE TABLE user (
//         id TEXT PRIMARY KEY,
//         email_id TEXT UNIQUE NOT NULL,
//         password TEXT,
//         mpin TEXT,
//         otp TEXT,
//         otp_expiry_time TEXT,
//         emp_status TEXT,
//         biometric_enabled INTEGER DEFAULT 0,
//         created_at TEXT,
//         updated_at TEXT
//       )
//     ''');

//     // employee_master
//     await db.execute('''
//       CREATE TABLE employee_master (
//         emp_id TEXT PRIMARY KEY,
//         org_short_name TEXT,
//         emp_name TEXT NOT NULL,
//         emp_email TEXT UNIQUE,
//         emp_role TEXT,
//         emp_department TEXT,
//         emp_phone TEXT,
//         emp_status TEXT,
//         emp_joining_date TEXT,
//         designation TEXT DEFAULT 'Employee',
//         created_at TEXT,
//         updated_at TEXT,
//         FOREIGN KEY (org_short_name) REFERENCES organization_master(org_short_name)
//       )
//     ''');

//     // project_master
//     await db.execute('''
//       CREATE TABLE project_master (
//         project_id TEXT PRIMARY KEY,
//         org_short_name TEXT,
//         project_name TEXT NOT NULL,
//         project_site TEXT,
//         client_name TEXT,
//         client_location TEXT,
//         client_contact TEXT,
//         mng_name TEXT,
//         mng_email TEXT,
//         mng_contact TEXT,
//         project_description TEXT,
//         project_techstack TEXT,
//         project_assigned_date TEXT,
//         status TEXT DEFAULT 'active',
//         priority TEXT DEFAULT 'HIGH',
//         progress REAL DEFAULT 0.0,
//         created_at TEXT,
//         updated_at TEXT,
//         FOREIGN KEY (org_short_name) REFERENCES organization_master(org_short_name)
//       )
//     ''');

//     // project_site_mapping
//     await db.execute('''
//       CREATE TABLE project_site_mapping (
//         project_site_id TEXT PRIMARY KEY,
//         project_id TEXT NOT NULL,
//         project_site_name TEXT,
//         project_site_lat REAL,
//         project_site_long REAL,
//         created_at TEXT,
//         updated_at TEXT,
//         FOREIGN KEY (project_id) REFERENCES project_master(project_id)
//       )
//     ''');

//     // employee_attendance
//     await db.execute('''
//       CREATE TABLE employee_attendance (
//         att_id TEXT PRIMARY KEY,
//         emp_id TEXT NOT NULL,
//         att_timestamp TEXT NOT NULL,
//         att_date TEXT NOT NULL,
//         att_latitude REAL,
//         att_longitude REAL,
//         att_geofence_name TEXT,
//         project_id TEXT,
//         att_notes TEXT,
//         att_status TEXT CHECK(att_status IN ('checkIn', 'checkOut')),
//         verification_type TEXT,
//         is_verified INTEGER DEFAULT 0,
//         photo_proof_path TEXT,
//         created_at TEXT,
//         updated_at TEXT,
//         FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id),
//         FOREIGN KEY (project_id) REFERENCES project_master(project_id)
//       )
//     ''');

//     // employee_regularization
//     await db.execute('''
//       CREATE TABLE employee_regularization (
//         reg_id TEXT PRIMARY KEY,
//         emp_id TEXT NOT NULL,
//         mgr_emp_id TEXT,
//         reg_date_applied TEXT,
//         reg_applied_for_date TEXT,
//         reg_justification TEXT,
//         reg_first_check_in TEXT,
//         reg_last_check_out TEXT,
//         shortfall_hrs TEXT,
//         reg_approval_status TEXT CHECK(reg_approval_status IN ('pending', 'approved', 'rejected')),
//         mgr_comments TEXT,
//         created_at TEXT,
//         updated_at TEXT,
//         FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id),
//         FOREIGN KEY (mgr_emp_id) REFERENCES employee_master(emp_id)
//       )
//     ''');

//     // employee_leaves
//     await db.execute('''
//       CREATE TABLE employee_leaves (
//         leave_id TEXT PRIMARY KEY,
//         emp_id TEXT NOT NULL,
//         mgr_emp_id TEXT,
//         leave_from_date TEXT NOT NULL,
//         leave_to_date TEXT NOT NULL,
//         leave_type TEXT NOT NULL,
//         leave_justification TEXT,
//         leave_approval_status TEXT CHECK(leave_approval_status IN ('pending', 'approved', 'rejected', 'cancelled', 'query')),
//         manager_comments TEXT,
//         from_time TEXT,
//         to_time TEXT,
//         created_at TEXT NOT NULL,
//         updated_at TEXT NOT NULL,
//         FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id),
//         FOREIGN KEY (mgr_emp_id) REFERENCES employee_master(emp_id)
//       )
//     ''');

//     // employee_mapped_projects
//     await db.execute('''
//       CREATE TABLE employee_mapped_projects (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         emp_id TEXT NOT NULL,
//         project_id TEXT NOT NULL,
//         mapping_status TEXT CHECK(mapping_status IN ('active', 'deactive')),
//         created_at TEXT,
//         updated_at TEXT,
//         FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id),
//         FOREIGN KEY (project_id) REFERENCES project_master(project_id)
//       )
//     ''');

//     // current_user (session)
//     await db.execute('''
//       CREATE TABLE current_user (
//         id INTEGER PRIMARY KEY,
//         user_data TEXT,
//         created_at TEXT DEFAULT CURRENT_TIMESTAMP
//       )
//     ''');

//     // geofence_master
//     await db.execute('''
//       CREATE TABLE geofence_master (
//         geo_id TEXT PRIMARY KEY,
//         geo_name TEXT NOT NULL,
//         latitude REAL NOT NULL,
//         longitude REAL NOT NULL,
//         radius_meters REAL NOT NULL,
//         is_active INTEGER DEFAULT 1,
//         address TEXT,
//         created_at TEXT,
//         updated_at TEXT
//       )
//     ''');

//     // NEW: attendance_analytics (daily per-employee stats - no hardcoding)
//     await db.execute('''
//       CREATE TABLE attendance_analytics (
//         analytics_id TEXT PRIMARY KEY,
//         emp_id TEXT NOT NULL,
//         att_date TEXT NOT NULL,
//         att_type TEXT CHECK(att_type IN ('Present', 'Absent', 'Leave', 'Holiday', 'Weekend')),
//         first_checkin TEXT,
//         last_checkout TEXT,
//         worked_hrs REAL DEFAULT 0.0,
//         shortfall_hrs REAL DEFAULT 0.0,
//         on_time INTEGER DEFAULT 0,
//         late INTEGER DEFAULT 0,
//         created_at TEXT DEFAULT CURRENT_TIMESTAMP,
//         updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
//         FOREIGN KEY (emp_id) REFERENCES employee_master(emp_id)
//       )
//     ''');

//     // Seed dummy data
//     await _seedFromJson(db);
//   }

//   Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
//     // Run all upgrades in a transaction for safety
//     await db.transaction((txn) async {
//       // Upgrade from any old version to current
//       if (oldVersion < 2) {
//         // Add new columns only if they don't exist (SQLite doesn't have IF NOT EXISTS for ALTER, so check manually)
//         final columns = await txn.rawQuery(
//           'PRAGMA table_info(employee_attendance)',
//         );

//         final columnNames = columns.map((c) => c['name'] as String).toSet();

//         if (!columnNames.contains('att_date')) {
//           await txn.execute(
//             'ALTER TABLE employee_attendance ADD COLUMN att_date TEXT;',
//           );
//         }
//         if (!columnNames.contains('check_in_time')) {
//           await txn.execute(
//             'ALTER TABLE employee_attendance ADD COLUMN check_in_time TEXT;',
//           );
//         }
//         if (!columnNames.contains('check_out_time')) {
//           await txn.execute(
//             'ALTER TABLE employee_attendance ADD COLUMN check_out_time TEXT;',
//           );
//         }
//         if (!columnNames.contains('leave_type')) {
//           await txn.execute(
//             'ALTER TABLE employee_attendance ADD COLUMN leave_type TEXT;',
//           );
//         }
//         if (!columnNames.contains('photo_proof_path')) {
//           await txn.execute(
//             'ALTER TABLE employee_attendance ADD COLUMN photo_proof_path TEXT;',
//           );
//         }
//       }

//       // Future upgrades (add more if blocks for higher versions)
//       if (oldVersion < 3) {
//         // Example: Add notes to attendance_analytics
//         final analyticsColumns = await txn.rawQuery(
//           'PRAGMA table_info(attendance_analytics)',
//         );
//         final analyticsNames = analyticsColumns
//             .map((c) => c['name'] as String)
//             .toSet();

//         if (!analyticsNames.contains('notes')) {
//           await txn.execute(
//             'ALTER TABLE attendance_analytics ADD COLUMN notes TEXT;',
//           );
//         }
//       }
//     });
//   }

//   Future<void> _seedFromJson(Database db) async {
//     try {
//       final String jsonString = await rootBundle.loadString(
//         'assets/data/dummy_data.json',
//       );
//       final Map<String, dynamic> data = jsonDecode(jsonString);

//       // Seed all tables (existing + new)
//       await _insertTableData(
//         db,
//         'organization_master',
//         data['organization_master'] ?? [],
//       );
//       await _insertTableData(db, 'user', data['user'] ?? []);
//       await _insertTableData(
//         db,
//         'employee_master',
//         data['employee_master'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'project_master',
//         data['project_master'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'project_site_mapping',
//         data['project_site_mapping'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'employee_attendance',
//         data['employee_attendance'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'employee_regularization',
//         data['employee_regularization'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'employee_leaves',
//         data['employee_leaves'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'employee_mapped_projects',
//         data['employee_mapped_projects'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'running_serial_number',
//         data['running_serial_number'] ?? [],
//       );
//       await _insertTableData(
//         db,
//         'geofence_master',
//         data['geofence_master'] ?? [],
//       );

//       // NEW: Seed attendance_analytics
//       await _insertTableData(
//         db,
//         'attendance_analytics',
//         data['attendance_analytics'] ?? [],
//       );

//       print("✅ All tables seeded successfully from dummy_data.json!");
//     } catch (e) {
//       print("❌ Error seeding data: $e");
//     }
//   }

//   Future<void> _insertTableData(
//     Database db,
//     String tableName,
//     List<dynamic> dataList,
//   ) async {
//     for (var item in dataList) {
//       try {
//         final Map<String, Object?> row = Map<String, Object?>.from(item);
//         await db.insert(
//           tableName,
//           row,
//           conflictAlgorithm: ConflictAlgorithm.replace,
//         );
//       } catch (e) {
//         print("Error inserting into $tableName: $e");
//       }
//     }
//   }

//   // Save logged in user session
//   Future<void> saveCurrentUser(Map<String, dynamic> user) async {
//     final db = await database;
//     await db.insert('current_user', {
//       'id': 1,
//       'user_data': jsonEncode(user),
//     }, conflictAlgorithm: ConflictAlgorithm.replace);
//   }

//   // Get logged in user
//   Future<Map<String, dynamic>?> getCurrentUser() async {
//     final db = await database;
//     final result = await db.query(
//       'current_user',
//       where: 'id = ?',
//       whereArgs: [1],
//     );
//     if (result.isNotEmpty) {
//       return jsonDecode(result.first['user_data'] as String);
//     }
//     return null;
//   }

//   // Enable/Disable biometrics
//   Future<void> enableBiometricsForUser(String empId, bool enabled) async {
//     final db = await database;
//     await db.update(
//       'user',
//       {'biometric_enabled': enabled ? 1 : 0},
//       where: 'emp_id = ?',
//       whereArgs: [empId],
//     );
//   }

//   Future<bool> isBiometricsEnabled(String empId) async {
//     final db = await database;
//     final result = await db.query(
//       'user',
//       columns: ['biometric_enabled'],
//       where: 'emp_id = ?',
//       whereArgs: [empId],
//     );
//     if (result.isNotEmpty) {
//       return (result.first['biometric_enabled'] as int) == 1;
//     }
//     return false;
//   }

//   // Clear login session
//   Future<void> clearCurrentUser() async {
//     final db = await database;
//     await db.delete('current_user');
//   }

//   // NEW: Queries for Attendance Analytics

//   // Get analytics for a specific employee over a period
//   Future<List<Map<String, dynamic>>> getAttendanceAnalyticsForPeriod({
//     required String empId,
//     required DateTime start,
//     required DateTime end,
//   }) async {
//     final db = await database;
//     return await db.query(
//       'attendance_analytics',
//       where: 'emp_id = ? AND att_date BETWEEN ? AND ?',
//       whereArgs: [
//         empId,
//         DateFormat('yyyy-MM-dd').format(start),
//         DateFormat('yyyy-MM-dd').format(end),
//       ],
//       orderBy: 'att_date ASC',
//     );
//   }

//   // Get aggregated team stats for manager over a period
//   Future<Map<String, dynamic>> getTeamAnalyticsForPeriod({
//     required String mgrEmpId,
//     required DateTime start,
//     required DateTime end,
//   }) async {
//     final db = await database;
//     final result = await db.rawQuery(
//       '''
//       SELECT
//         COUNT(DISTINCT aa.emp_id) as team_size,
//         SUM(CASE WHEN aa.att_type = 'Present' AND aa.on_time = 1 THEN 1 ELSE 0 END) as on_time,
//         SUM(CASE WHEN aa.att_type = 'Present' AND aa.late = 1 THEN 1 ELSE 0 END) as late,
//         SUM(CASE WHEN aa.att_type = 'Present' THEN 1 ELSE 0 END) as present,
//         SUM(CASE WHEN aa.att_type = 'Leave' THEN 1 ELSE 0 END) as leave,
//         SUM(CASE WHEN aa.att_type = 'Absent' THEN 1 ELSE 0 END) as absent
//       FROM attendance_analytics aa
//       JOIN employee_master em ON aa.emp_id = em.emp_id
//       WHERE em.reporting_manager_id = ?
//         AND aa.att_date BETWEEN ? AND ?
//     ''',
//       [
//         mgrEmpId,
//         DateFormat('yyyy-MM-dd').format(start),
//         DateFormat('yyyy-MM-dd').format(end),
//       ],
//     );

//     final row = result.isNotEmpty ? result.first : {};
//     return {
//       'team': row['team_size'] as int? ?? 0,
//       'present': row['present'] as int? ?? 0,
//       'leave': row['leave'] as int? ?? 0,
//       'absent': row['absent'] as int? ?? 0,
//       'onTime': row['on_time'] as int? ?? 0,
//       'late': row['late'] as int? ?? 0,
//     };
//   }

//   // Get pending counts for manager
//   Future<int> getPendingLeavesCount(String mgrEmpId) async {
//     final db = await database;
//     final result = await db.rawQuery(
//       'SELECT COUNT(*) FROM employee_leaves WHERE mgr_emp_id = ? AND leave_approval_status = ?',
//       [mgrEmpId, 'pending'],
//     );
//     return Sqflite.firstIntValue(result) ?? 0;
//   }

//   Future<int> getPendingRegularisationsCount(String mgrEmpId) async {
//     final db = await database;
//     final result = await db.rawQuery(
//       'SELECT COUNT(*) FROM employee_regularization WHERE mgr_emp_id = ? AND reg_approval_status = ?',
//       [mgrEmpId, 'pending'],
//     );
//     return Sqflite.firstIntValue(result) ?? 0;
//   }
// }
