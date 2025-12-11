// lib/features/auth/presentation/screens/login_screen.dart
import 'dart:convert';
import 'package:appattendance/core/utils/app_colors.dart';
import 'package:appattendance/features/auth/presentation/providers/auth_notifier.dart';
import 'package:appattendance/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.6)),
    );

    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animController.forward();

    // Pre-fill for testing (remove in production)
    _emailController.text = "rahul@company.com";
    _passwordController.text = "123456";
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // REAL API CALL TO MONGODB BACKEND
  Future<void> _loginWithAPI() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    ref.read(authProvider.notifier).setLoading(true);

    try {
      final response = await http
          .post(
            Uri.parse(
              "http://192.168.1.100:3000/api/login",
            ), // Apna IP daal dena (ya localhost:3000)
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final userData = data['user'];
        // Save user in Riverpod state
        ref.read(authProvider.notifier).setUser(userData);
      } else {
        ref
            .read(authProvider.notifier)
            .setError(data['message'] ?? "Login failed");
      }
    } catch (e) {
      ref.read(authProvider.notifier).setError("No internet or server down");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen for login success
    ref.listen<AsyncValue>(authProvider, (previous, next) {
      next.whenOrNull(
        data: (userMap) {
          if (userMap != null && mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          }
        },
        error: (err, stack) {
          if (mounted && err.toString().isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(err.toString()),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.primary.withOpacity(0.2), Colors.black]
                : [
                    AppColors.primary.withOpacity(0.08),
                    AppColors.backgroundLight,
                  ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _opacity,
                child: SlideTransition(
                  position: _slide,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        // Logo
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryLight,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/nutantek_logo.png',
                              width: 70,
                              height: 70,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.business,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        Text(
                          'Welcome Back',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                        ),
                        Text(
                          'Sign in to continue',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Form Card
                        Card(
                          elevation: 12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[50],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (v) => v?.isEmpty == true
                                        ? 'Email required'
                                        : null,
                                  ),
                                  const SizedBox(height: 20),

                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[50],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (v) => v?.isEmpty == true
                                        ? 'Password required'
                                        : null,
                                  ),
                                  const SizedBox(height: 32),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: authState.isLoading
                                          ? null
                                          : _loginWithAPI,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        elevation: 6,
                                      ),
                                      child: authState.isLoading
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              'LOGIN',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),

                        Text(
                          '© 2025 Nutantek • Enterprise Edition',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// // lib/features/auth/presentation/screens/login_screen.dart
// import 'package:appattendance/core/utils/app_colors.dart';
// import 'package:appattendance/features/auth/presentation/providers/auth_notifier.dart';
// import 'package:appattendance/features/dashboard/presentation/screens/dashboard_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends ConsumerState<LoginScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   late AnimationController _animController;
//   late Animation<double> _opacity;
//   late Animation<Offset> _slide;

//   bool _obscurePassword = true;

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );

//     _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.6)),
//     );

//     _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
//         .animate(
//           CurvedAnimation(
//             parent: _animController,
//             curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
//           ),
//         );

//     _animController.forward();
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _animController.dispose();
//     super.dispose();
//   }

//   void _login() {
//     if (_formKey.currentState!.validate()) {
//       ref
//           .read(authProvider.notifier)
//           .login(_emailController.text.trim(), _passwordController.text.trim());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authProvider);
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     ref.listen<AsyncValue>(authProvider, (previous, next) {
//       next.whenOrNull(
//         data: (user) {
//           if (user != null && mounted) {
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(builder: (_) => const DashboardScreen()),
//             );
//           }
//         },
//         error: (err, stack) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(err.toString()),
//                 backgroundColor: AppColors.error,
//               ),
//             );
//           }
//         },
//       );
//     });

//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: isDark
//                 ? [AppColors.primary.withOpacity(0.2), Colors.black]
//                 : [
//                     AppColors.primary.withOpacity(0.08),
//                     AppColors.backgroundLight,
//                   ],
//           ),
//         ),
//         child: SafeArea(
//           child: AnimatedBuilder(
//             animation: _animController,
//             builder: (context, child) {
//               return FadeTransition(
//                 opacity: _opacity,
//                 child: SlideTransition(
//                   position: _slide,
//                   child: Padding(
//                     padding: const EdgeInsets.all(24.0),
//                     child: Column(
//                       children: [
//                         const Spacer(flex: 2),

//                         // Logo
//                         Container(
//                           width: 110,
//                           height: 110,
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 AppColors.primary,
//                                 AppColors.primaryLight,
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(24),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: AppColors.primary.withOpacity(0.4),
//                                 blurRadius: 30,
//                                 offset: const Offset(0, 15),
//                               ),
//                             ],
//                           ),
//                           child: Center(
//                             child: Image.asset(
//                               'assets/images/nutantek_logo.png',
//                               width: 70,
//                               height: 70,
//                               errorBuilder: (_, __, ___) => const Icon(
//                                 Icons.business,
//                                 size: 60,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 32),

//                         Text(
//                           'Welcome Back',
//                           style: Theme.of(context).textTheme.headlineMedium
//                               ?.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           'Sign in to continue',
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                         const SizedBox(height: 48),

//                         // Form Card
//                         Card(
//                           elevation: 12,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(28.0),
//                             child: Form(
//                               key: _formKey,
//                               child: Column(
//                                 children: [
//                                   // Email Field
//                                   TextFormField(
//                                     controller: _emailController,
//                                     keyboardType: TextInputType.emailAddress,
//                                     decoration: InputDecoration(
//                                       labelText: 'Email',
//                                       prefixIcon: const Icon(
//                                         Icons.email_outlined,
//                                       ),
//                                       filled: true,
//                                       fillColor: isDark
//                                           ? Colors.grey[800]
//                                           : Colors.grey[50],
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                         borderSide: BorderSide.none,
//                                       ),
//                                     ),
//                                     validator: (v) => v?.isEmpty == true
//                                         ? 'Email required'
//                                         : null,
//                                   ),
//                                   const SizedBox(height: 20),

//                                   // Password Field
//                                   TextFormField(
//                                     controller: _passwordController,
//                                     obscureText: _obscurePassword,
//                                     decoration: InputDecoration(
//                                       labelText: 'Password',
//                                       prefixIcon: const Icon(
//                                         Icons.lock_outline,
//                                       ),
//                                       suffixIcon: IconButton(
//                                         icon: Icon(
//                                           _obscurePassword
//                                               ? Icons.visibility_off
//                                               : Icons.visibility,
//                                         ),
//                                         onPressed: () => setState(
//                                           () => _obscurePassword =
//                                               !_obscurePassword,
//                                         ),
//                                       ),
//                                       filled: true,
//                                       fillColor: isDark
//                                           ? Colors.grey[800]
//                                           : Colors.grey[50],
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                         borderSide: BorderSide.none,
//                                       ),
//                                     ),
//                                     validator: (v) => v?.isEmpty == true
//                                         ? 'Password required'
//                                         : null,
//                                   ),
//                                   const SizedBox(height: 32),

//                                   // Login Button
//                                   SizedBox(
//                                     width: double.infinity,
//                                     height: 56,
//                                     child: ElevatedButton(
//                                       onPressed: authState.isLoading
//                                           ? null
//                                           : _login,
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: AppColors.primary,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                             14,
//                                           ),
//                                         ),
//                                         elevation: 6,
//                                       ),
//                                       child: authState.isLoading
//                                           ? const SizedBox(
//                                               height: 24,
//                                               width: 24,
//                                               child: CircularProgressIndicator(
//                                                 color: Colors.white,
//                                                 strokeWidth: 2.5,
//                                               ),
//                                             )
//                                           : const Text(
//                                               'LOGIN',
//                                               style: TextStyle(
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 16),

//                                   TextButton(
//                                     onPressed: () {
//                                       // Forgot password screen
//                                     },
//                                     child: const Text(
//                                       'Forgot Password?',
//                                       style: TextStyle(
//                                         color: AppColors.primary,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),

//                         const Spacer(flex: 3),

//                         // Footer
//                         Text(
//                           '© 2025 Nutantek • Enterprise Edition',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
