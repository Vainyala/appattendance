// lib/core/utils/role_preferences.dart
import 'package:shared_preferences/shared_preferences.dart';

class RolePreferences {
  static const String _roleSelectedKey = 'role_selected';
  static const String _userDesignationKey = 'user_designation';

  static Future<bool> hasSelectedRole(String empId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_roleSelectedKey}_$empId') ?? false;
  }

  static Future<void> saveRoleSelection(
    String empId,
    String designation,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_roleSelectedKey}_$empId', true);
    await prefs.setString('${_userDesignationKey}_$empId', designation);
  }

  static Future<String?> getSavedDesignation(String empId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${_userDesignationKey}_$empId');
  }
}
