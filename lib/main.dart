// lib/main.dart
import 'package:appattendance/app.dart';
import 'package:appattendance/core/providers/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // Yeh line sabse pehle — SharedPreferences, DB, FCM sab ke liye zaroori
  WidgetsFlutterBinding.ensureInitialized();

  // Agar tere paas LocalDB.init() hai aur use kar raha hai toh rakh sakta hai
  // Warna comment kar de (abhi hum MongoDB use kar rahe hain)
  // await LocalDB.init();

  // Future mein agar Firebase FCM chahiye toh yahan uncomment kar dena
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Live theme mode (dark/light toggle)
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Nutantek Attendance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066FF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      themeMode: themeMode, // ← Dark/Light auto switch
      home:
          const App(), // ← Yahan se routing handle hota hai (Splash → Login → Dashboard)
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
