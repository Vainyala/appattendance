// // core/router/app_router.dart
// import 'package:appattendance/features/auth/presentation/providers/auth_provider.dart';
// import 'package:appattendance/features/auth/presentation/screens/login_screen.dart';
// import 'package:appattendance/features/dashboard/presentation/screens/dashboard_screen.dart';
// import 'package:appattendance/features/dashboard/presentation/screens/splash_screen.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final goRouterProvider = Provider<GoRouter>((ref) {
//   return GoRouter(
//     initialLocation: '/',
//     routes: [
//       GoRoute(
//         path: '/',
//         builder: (context, state) => const SplashScreen(),
//         routes: [
//           GoRoute(
//             path: 'login',
//             builder: (context, state) => const LoginScreen(),
//           ),
//           GoRoute(
//             path: 'dashboard',
//             builder: (context, state) => const DashboardScreen(),
//           ),
//         ],
//       ),
//     ],
//     redirect: (context, state) {
//       final isLoggedIn = ref.read(authProvider).value != null;
//       if (!isLoggedIn && state.uri.toString() != '/login') {
//         return '/login';
//       }
//       if (isLoggedIn && state.uri.toString() == '/login') {
//         return '/dashboard';
//       }
//       return null;
//     },
//   );
// });
