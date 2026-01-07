// lib/features/auth/presentation/screens/settings_screen.dart
import 'package:appattendance/core/providers/theme_notifier.dart';
import 'package:appattendance/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final isBiometricEnabled = user?.biometricEnabled ?? false;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Theme Switch
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref
                  .read(themeProvider.notifier)
                  .setTheme(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),

          // Biometric Toggle
          SwitchListTile(
            title: const Text('Enable Face ID / Biometric Login'),
            subtitle: const Text('Use Face ID after entering password'),
            value: isBiometricEnabled,
            onChanged: (bool value) async {
              if (value) {
                // Enable karne se pehle biometric verify karo
                // (tumhara BiometricService use karo)
                // Example:
                // final authenticated = await biometricService.authenticate(...);
                // if (!authenticated) return;
              }

              // Update user in DB and state
              // await DBHelper.instance.enableBiometricsForUser(user!.empId, value);
              // ref.read(authProvider.notifier).updateUser(user.copyWith(biometricEnabled: value));

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Biometric ${value ? "enabled" : "disabled"}'),
                ),
              );
            },
          ),

          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
