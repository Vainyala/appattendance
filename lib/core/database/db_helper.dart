// lib/core/database/db_helper.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    // Create tables as per your latest schema (aligned with dummy_data.json)

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

    await db.execute('''
      CREATE TABLE user (
        id TEXT PRIMARY KEY,
        email_id TEXT UNIQUE NOT NULL,
        password TEXT,
        mpin TEXT,
        otp TEXT,
        otp_expiry_time TEXT,
        emp_status TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE employee_master (
        emp_id TEXT PRIMARY KEY,
        org_short_name TEXT,
        emp_name TEXT NOT NULL,
        emp_email TEXT UNIQUE,
        emp_role TEXT,
        emp_department TEXT,
        emp_phone TEXT,
        emp_status TEXT,
        emp_joining_date TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (org_short_name) REFERENCES organization_master(org_short_name)
      )
    ''');

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
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (org_short_name) REFERENCES organization_master(org_short_name)
      )
    ''');

    await db.execute('''
      CREATE TABLE project_site_mapping (
        project_site_id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        project_site_name TEXT,
        project_site_lat TEXT,
        project_site_long TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (project_id) REFERENCES project_master(project_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE employee_attendance (
        att_id TEXT PRIMARY KEY,
        emp_id TEXT NOT NULL,
        att_timestamp TEXT NOT NULL,
        att_latitude REAL,
        att_longitude REAL,
        att_geofence_name TEXT,
        project_id TEXT,
        att_notes TEXT,
        att_status TEXT CHECK(att_status IN ('checkIn', 'checkOut')),
        verification_type TEXT,
        is_verified INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (emp_id) REFERENCES user(emp_id),
        FOREIGN KEY (project_id) REFERENCES project_master(project_id)
      )
    ''');

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
        FOREIGN KEY (emp_id) REFERENCES user(emp_id),
        FOREIGN KEY (mgr_emp_id) REFERENCES user(emp_id)
      )
    ''');

    await db.execute('''
  CREATE TABLE employee_leaves (
    leave_id TEXT PRIMARY KEY,
    emp_id TEXT NOT NULL,
    mgr_emp_id TEXT,
    leave_from_date TEXT NOT NULL,
    leave_to_date TEXT NOT NULL,
    leave_type TEXT NOT NULL,
    leave_justification TEXT,
    leave_approval_status TEXT NOT NULL
      CHECK(leave_approval_status IN ('pending', 'approved', 'rejected', 'cancelled', 'query')),
    manager_comments TEXT,
    from_time TEXT,           -- e.g., '09:00' (HH:mm format)
    to_time TEXT,             -- e.g., '18:00'
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (emp_id) REFERENCES user(emp_id),
    FOREIGN KEY (mgr_emp_id) REFERENCES user(emp_id)
  )
''');

    await db.execute('''
      CREATE TABLE employee_mapped_projects (
        id INTEGER PRIMARY KEY,
        emp_id TEXT NOT NULL,
        project_id TEXT NOT NULL,
        mapping_status TEXT CHECK(mapping_status IN ('active', 'deactive')),
        created_at TEXT,
        updated_at TEXT,
        PRIMARY KEY (emp_id, project_id),
        FOREIGN KEY (emp_id) REFERENCES user(emp_id),
        FOREIGN KEY (project_id) REFERENCES project_master(project_id)
      )
    ''');

    // Current user session table
    await db.execute('''
      CREATE TABLE current_user (
        id INTEGER PRIMARY KEY,
        user_data TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // In DBHelper onCreate
    await db.execute('''
  CREATE TABLE geofence_master (
    geo_id TEXT PRIMARY KEY,
    goe_name TEXT NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    radius_meters REAL NOT NULL,
    is_active INTEGER DEFAULT 1,
    address TEXT,
    created_at TEXT,
    updated_at TEXT
  )
''');

    // Seed dummy data
    await _seedFromJson(db);
    // await seedGeofences(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future upgrade logic (add columns, migrate data)
    if (oldVersion < 2) {
      // Example: add new column
      await db.execute(
        'ALTER TABLE employee_regularization ADD COLUMN supporting_docs TEXT',
      );
    }
  }

  Future<void> _seedFromJson(Database db) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/dummy_data.json',
      );
      final Map<String, dynamic> data = jsonDecode(jsonString);

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
      await _insertTableData(
        db,
        'project_master',
        data['project_master'] ?? [],
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
      await _insertTableData(
        db,
        'running_serial_number',
        data['running_serial_number'] ?? [],
      );

      await _insertTableData(
        db,
        'geofence_master',
        data['geofence_master'] ?? [],
      );

      print("✅ All tables seeded successfully from dummy_data.json!");
    } catch (e) {
      print("❌ Error seeding data: $e");
    }
  }

  Future<void> _insertTableData(
    Database db,
    String tableName,
    List<dynamic> dataList,
  ) async {
    for (var item in dataList) {
      try {
        final Map<String, Object?> row = Map<String, Object?>.from(item);
        await db.insert(
          tableName,
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        print("Error inserting into $tableName: $e");
      }
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

  // Clear login session
  Future<void> clearCurrentUser() async {
    final db = await database;
    await db.delete('current_user');
  }
}
