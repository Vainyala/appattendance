// lib/features/auth/data/repositories/auth_repository_impl.dart
// FINAL DIO-BASED VERSION - January 06, 2026
// Supports both local SQLite (dummy) and real Dio API
// Dio null = local mode, Dio provided = API mode
// Full null-safety, error handling, session save

import 'package:appattendance/core/database/db_helper.dart';
import 'package:appattendance/features/auth/data/repositories/auth_repository.dart';
import 'package:appattendance/features/auth/domain/models/user_db_mapper.dart';
import 'package:appattendance/features/auth/domain/models/user_model.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio? dio; // Null = local mode, provided = real API

  AuthRepositoryImpl({this.dio});

  @override
  Future<UserModel> login(String email, String password) async {
    // If Dio is provided, use real API (future)
    if (dio != null) {
      try {
        final response = await dio!.post(
          '/api/login',
          data: {'email': email.trim().toLowerCase(), 'password': password},
        );

        if (response.statusCode != 200) {
          throw Exception('Login failed: ${response.data['message']}');
        }

        final userJson = response.data['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userJson);

        // Save session locally
        await DBHelper.instance.saveCurrentUser(user.toJson());
        return user;
      } catch (e) {
        throw Exception('API login error: $e');
      }
    }

    // Local mode (dummy + SQLite) - current setup
    final db = await DBHelper.instance.database;

    // Step 1: user table se check
    final userRows = await db.query(
      'user',
      where: 'email_id = ? AND password = ?',
      whereArgs: [email.trim().toLowerCase(), password],
    );

    if (userRows.isEmpty) {
      throw Exception('Invalid email or password');
    }

    final userRow = userRows.first;

    // Get emp_id safely
    final empId = userRow['emp_id'] ?? userRow['id'];
    if (empId == null) {
      throw Exception('Employee ID not found');
    }

    // Step 2: employee_master details
    final empRows = await db.query(
      'employee_master',
      where: 'emp_id = ?',
      whereArgs: [empId],
    );

    if (empRows.isEmpty) {
      throw Exception('Employee details not found');
    }

    final empRow = empRows.first;

    // Step 3: Build UserModel
    final user = userFromDB(userRow, empRow);

    // Step 4: Save session (current user)
    await DBHelper.instance.saveCurrentUser(user.toJson());

    return user;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final savedUserJson = await DBHelper.instance.getCurrentUser();
    if (savedUserJson == null) return null;
    return UserModel.fromJson(savedUserJson);
  }

  @override
  Future<void> logout() async {
    await DBHelper.instance.clearCurrentUser();
  }
}

// // lib/features/auth/data/repositories/auth_repository_impl.dart
// // Fixed: Dio ko optional bana diya (abhi local DB mode ke liye null)
// // Future mein API ke liye Dio pass kar denge
// // Full SQLite login + session save + privileges mapping

// import 'package:appattendance/core/database/db_helper.dart';
// import 'package:appattendance/features/auth/data/repositories/auth_repository.dart';
// import 'package:appattendance/features/auth/domain/models/user_model.dart';
// import 'package:dio/dio.dart'; // Future API ke liye

// class AuthRepositoryImpl implements AuthRepository {
//   final Dio? dio; // Optional - abhi null (local mode)

//   AuthRepositoryImpl({this.dio});

//   @override
//   Future<UserModel> login(String email, String password) async {
//     try {
//       final db = await DBHelper.instance.database;

//       // Step 1: user table se check
//       final userRows = await db.query(
//         'user',
//         where: 'email_id = ? AND password = ?',
//         whereArgs: [email.trim().toLowerCase(), password],
//       );

//       if (userRows.isEmpty) {
//         throw Exception('Invalid email or password');
//       }

//       final userRow = userRows.first;

//       // Get emp_id - handle both 'id' and 'emp_id' columns
//       final empId = userRow['emp_id'] ?? userRow['id'];
//       if (empId == null) {
//         throw Exception('Employee ID not found in user record');
//       }

//       // Step 2: employee_master details
//       final empRows = await db.query(
//         'employee_master',
//         where: 'emp_id = ?',
//         whereArgs: [empId],
//       );

//       if (empRows.isEmpty) {
//         throw Exception('Employee details not found');
//       }

//       final empRow = empRows.first;

//       // Step 3: UserModel banao
//       final user = userFromDB(userRow, empRow);

//       // Step 4: Session save (current_user table mein)
//       await DBHelper.instance.saveCurrentUser(user.toJson());

//       return user;
//     } catch (e) {
//       throw Exception('Login failed: $e');
//     }
//   }

//   @override
//   Future<UserModel?> getCurrentUser() async {
//     try {
//       final savedUserJson = await DBHelper.instance.getCurrentUser();
//       if (savedUserJson == null) return null;
//       return UserModel.fromJson(savedUserJson);
//     } catch (e) {
//       return null;
//     }
//   }

//   @override
//   Future<void> logout() async {
//     await DBHelper.instance.clearCurrentUser();
//   }
// }

// // lib/features/auth/data/repositories/auth_repository_impl.dart
// // Fixed: Dio ko optional bana diya (abhi local DB mode ke liye null)
// // Future mein API ke liye Dio pass kar denge
// // Full SQLite login + session save + privileges mapping

// import 'package:appattendance/core/database/db_helper.dart';
// import 'package:appattendance/features/auth/data/repositories/auth_repository.dart';
// import 'package:appattendance/features/auth/domain/models/user_model.dart';
// import 'package:dio/dio.dart'; // Future API ke liye

// class AuthRepositoryImpl implements AuthRepository {
//   final Dio? dio; // Optional - abhi null (local mode)

//   AuthRepositoryImpl({this.dio});

//   @override
//   Future<UserModel> login(String email, String password) async {
//     try {
//       final db = await DBHelper.instance.database;

//       // DEBUG: Print schema info
//       print("=== LOGIN DEBUG ===");
//       print("Email: $email");

//       // Check what columns exist in user table
//       final tableInfo = await db.rawQuery("PRAGMA table_info(user)");
//       final columns = tableInfo.map((c) => c['name'] as String).toList();
//       print("User table columns: $columns");

//       // Step 1: user table se check
//       final userRows = await db.query(
//         'user',
//         where: 'email_id = ? AND password = ?',
//         whereArgs: [email.trim().toLowerCase(), password],
//       );

//       if (userRows.isEmpty) {
//         throw Exception('Invalid email or password');
//       }

//       final userRow = userRows.first;
//       print("User row found: $userRow");

//       // Get emp_id - handle both 'id' and 'emp_id' columns
//       final empId = userRow['emp_id'] ?? userRow['id'];
//       if (empId == null) {
//         throw Exception('Employee ID not found in user record');
//       }

//       print("Employee ID: $empId");

//       // Step 2: employee_master details
//       final empRows = await db.query(
//         'employee_master',
//         where: 'emp_id = ?',
//         // whereArgs: [userRow['emp_id']],
//         whereArgs: [empId],
//       );

//       if (empRows.isEmpty) {
//         throw Exception('Employee details not found');
//       }

//       // final empRow = empRows.isNotEmpty ? empRows.first : <String, dynamic>{};
//       final empRow = empRows.first;
//       print("Employee row found: $empRow");

//       // Step 3: UserModel banao
//       final user = userFromDB(userRow, empRow);
//       print("Created user model: ${user.toJson()}");

//       // Step 4: Session save (current_user table mein)
//       await DBHelper.instance.saveCurrentUser(user.toJson());

//       //   return user;
//       // } catch (e) {
//       //   throw Exception('Login failed: $e');
//       // }

//       return user;
//     } catch (e, stackTrace) {
//       print("Login error: $e");
//       print("Stack trace: $stackTrace");
//       throw Exception('Login failed: $e');
//     }

//     // Future real API mode (uncomment jab backend ready ho)
//     /*
//     if (dio == null) throw Exception('Dio not initialized');
//     final response = await dio!.post(
//       '/auth/login',
//       data: {'email': email.trim().toLowerCase(), 'password': password},
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Login failed: ${response.data['message']}');
//     }
//     final userJson = response.data['user'] as Map<String, dynamic>;
//     final token = response.data['token'] as String?;
//     final user = UserModel.fromJson(userJson);
//     await DBHelper.instance.saveCurrentUser(user.toJson()); // Token bhi save kar sakte ho
//     return user;
//     */
//   }

//   @override
//   Future<UserModel?> getCurrentUser() async {
//     try {
//       final savedUserJson = await DBHelper.instance.getCurrentUser();
//       if (savedUserJson == null) return null;
//       return UserModel.fromJson(savedUserJson);
//     } catch (e) {
//       print("Get current user error: $e");
//       return null;
//     }
//   }

//   @override
//   Future<void> logout() async {
//     await DBHelper.instance.clearCurrentUser();
//     // Future: dio?.options.headers.remove('Authorization');
//   }
// }

// // lib/features/auth/data/repositories/auth_repository_impl.dart
// import 'package:appattendance/features/auth/data/repositories/auth_repository.dart';
// import 'package:appattendance/features/auth/domain/models/user_model.dart';
// import 'package:dio/dio.dart';

// class AuthRepositoryImpl implements AuthRepository {
//   final Dio dio;

//   AuthRepositoryImpl(this.dio);

//   @override
//   Future<UserModel> login(String email, String password) async {
//     final response = await dio.post(
//       '/auth/login',
//       data: {'email': email, 'password': password},
//     );
//     return UserModel.fromJson(response.data['user']);
//   }

//   @override
//   Future<void> logout() async {
//     // Clear token, etc.
//   }

//   @override
//   Future<UserModel?> getCurrentUser() async {
//     return null; // ya shared prefs se
//   }
// }

// // lib/features/auth/data/repositories/auth_repository_impl.dart
// import 'package:appattendance/features/auth/domain/models/user_model.dart';
// import 'package:dio/dio.dart';

// class AuthRepositoryImpl implements AuthRepository {
//   final Dio dio;

//   AuthRepositoryImpl(this.dio);

//   @override
//   Future<UserModel> login(String email, String password) async {
//     final response = await dio.post(
//       '/auth/login',
//       data: {'email': email, 'password': password},
//     );

//     return UserModel.fromJson(response.data['data']);
//   }
// }
