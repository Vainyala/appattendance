// lib/main.dart
import 'package:appattendance/app.dart';
import 'package:appattendance/core/providers/theme_notifier.dart';
import 'package:appattendance/core/utils/app_colors.dart';
import 'package:appattendance/features/attendance/data/services/offline_attendance_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kDebugMode ke liye
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

// Top-level Workmanager callback (app.dart se move kiya gaya yahan)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "syncOfflineAttendance") {
      await OfflineAttendanceService.backgroundSyncCallback();
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Workmanager initialize
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Nutantek Attendance Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary.withOpacity(0.9),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      themeMode: themeMode,
      home: const App(), // ← App.dart ko sirf routing ke liye use kar rahe
    );
  }
}

// // lib/main.dart
// import 'package:appattendance/app.dart';
// import 'package:appattendance/core/providers/theme_notifier.dart';
// import 'package:appattendance/core/services/local_db_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// void main() async {
//   // Yeh zaroori hai DB, SharedPrefs, FCM ke liye
//   WidgetsFlutterBinding.ensureInitialized();
//   await LocalDB.init();
//   // Optional: Agar baad mein FCM ya notifications chahiye toh yahan init kar dena
//   // await Firebase.initializeApp();
//   // await NotificationService.init();

//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Theme live watch kar — dark/light toggle ke liye
//     final themeMode = ref.watch(themeProvider);

//     return MaterialApp(
//       title: 'Nutantek Attendance',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         brightness: Brightness.light,
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0066FF)),
//         fontFamily: 'Poppins',
//       ),
//       darkTheme: ThemeData(
//         useMaterial3: true,
//         brightness: Brightness.dark,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF0066FF),
//           brightness: Brightness.dark,
//         ),
//         fontFamily: 'Poppins',
//       ),
//       themeMode: themeMode, // ← YEH LIVE SWITCH HOGA!
//       home:
//           const App(), // ← app.dart mein sab routing (Splash → Login → Dashboard)
//     );
//   }
// }
