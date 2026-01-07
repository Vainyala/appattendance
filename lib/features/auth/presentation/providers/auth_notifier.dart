// lib/features/auth/presentation/providers/auth_notifier.dart
import 'dart:async';

import 'package:appattendance/core/database/db_helper.dart';
import 'package:appattendance/core/services/biometric_service.dart';
import 'package:appattendance/features/auth/data/repositories/auth_repository.dart';
import 'package:appattendance/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:appattendance/features/auth/domain/models/user_model.dart';
import 'package:appattendance/features/auth/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(); // Abhi Dio nahi chahiye, toh null pass
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref ref;
  final AuthRepository repository;
  final BiometricService _biometricService = BiometricService();
  Timer? _logoutTimer;

  AuthNotifier(this.ref, this.repository) : super(const AsyncData(null)) {
    _checkCurrentUser();
  }

  /// App start pe check karta hai ki user already logged in hai ya nahi
  Future<void> _checkCurrentUser() async {
    if (!mounted) return;
    state = const AsyncLoading();
    try {
      final user = await repository.getCurrentUser();
      state = AsyncData(user);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  // Login method - password se login, biometric UI se handle
  Future<void> login(String email, String password) async {
    if (!mounted) return;
    state = const AsyncLoading();

    try {
      final user = await repository.login(email.trim(), password);
      state = AsyncData(user);

      // Start 20-minute auto-logout timer after successful login
      _startLogoutTimer();
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  void _startLogoutTimer() {
    _logoutTimer?.cancel();
    _logoutTimer = Timer(const Duration(minutes: 20), () {
      if (mounted) {
        logout();
      }
    });
  }

  Future<void> logout() async {
    _logoutTimer?.cancel();
    await repository.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email'); // Remember me clear
    await prefs.remove('bound_device_id'); // Device binding clear
    await prefs.remove('is_device_verified'); // Optional: First time reset
    state = const AsyncData(null);
  }

  void updateUser(UserModel updated) {
    if (mounted) {
      state = AsyncData(updated);
    }
  }

  @override
  void dispose() {
    _logoutTimer?.cancel();
    super.dispose();
  }
}
