// lib/features/auth/presentation/screens/forgot_password_screen.dart
import 'package:appattendance/core/utils/app_colors.dart';
import 'package:appattendance/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _empIdController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

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
  }

  @override
  void dispose() {
    _empIdController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_empIdController.text.trim().isEmpty) {
      _showSnackBar("Please enter Employee ID");
      return;
    }

    setState(() => _isLoading = true);

    // Fake delay — real API mein yahan call jayega
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _isOtpSent = true;
    });

    _showSnackBar("OTP sent to registered email/phone (Fake: 123456)");
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim() != "123456") {
      _showSnackBar("Invalid OTP");
      return;
    }

    setState(() {
      _isOtpVerified = true;
    });

    _showSnackBar("OTP Verified Successfully!");
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar("Passwords do not match");
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showSnackBar("Password must be at least 6 characters");
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    _showSnackBar("Password updated successfully!", isSuccess: true);

    // Back to login
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.primary.withOpacity(0.3), Colors.black]
                : [
                    AppColors.primary.withOpacity(0.1),
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
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // Logo
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryLight,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/nutantek_logo.png',
                              width: 60,
                              height: 60,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.lock_reset,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        Text(
                          'Forgot Password?',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                        ),
                        Text(
                          'Don\'t worry! It happens. Please enter your Employee ID',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 48),

                        Card(
                          elevation: 12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: Column(
                              children: [
                                // Employee ID Field
                                TextFormField(
                                  controller: _empIdController,
                                  enabled: !_isOtpSent,
                                  keyboardType: TextInputType.text,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  decoration: InputDecoration(
                                    labelText: 'Employee ID',
                                    prefixIcon: const Icon(Icons.badge),
                                    filled: true,
                                    fillColor: isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // OTP Field (only after send)
                                if (_isOtpSent) ...[
                                  TextFormField(
                                    controller: _otpController,
                                    enabled: !_isOtpVerified,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Enter OTP',
                                      hintText: 'Fake OTP: 123456',
                                      prefixIcon: const Icon(Icons.sms),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[50],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],

                                // New Password Fields (after verify)
                                if (_isOtpVerified) ...[
                                  TextFormField(
                                    controller: _newPasswordController,
                                    obscureText: _obscureNewPassword,
                                    decoration: InputDecoration(
                                      labelText: 'New Password',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureNewPassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscureNewPassword =
                                              !_obscureNewPassword,
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
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    decoration: InputDecoration(
                                      labelText: 'Confirm Password',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscureConfirmPassword =
                                              !_obscureConfirmPassword,
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
                                  ),
                                  const SizedBox(height: 32),
                                ],

                                // Action Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            if (!_isOtpSent) {
                                              _sendOtp();
                                            } else if (_isOtpSent &&
                                                !_isOtpVerified) {
                                              _verifyOtp();
                                            } else if (_isOtpVerified) {
                                              _resetPassword();
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 6,
                                    ),
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            _isOtpVerified
                                                ? 'RESET PASSWORD'
                                                : _isOtpSent
                                                ? 'VERIFY OTP'
                                                : 'SEND OTP',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Back to Login',
                            style: TextStyle(color: AppColors.primary),
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

// // lib/features/auth/presentation/screens/forgot_password_screen.dart

// import 'package:appattendance/core/utils/app_colors.dart';
// import 'package:appattendance/core/database/db_helper.dart';
// import 'package:flutter/material.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
//     with SingleTickerProviderStateMixin {
//   final _emailController = TextEditingController();
//   bool _isLoading = false;

//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // Simple animation for smooth entry
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 1000),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     );
//     _slideAnimation = Tween<Offset>(
//       begin: Offset(0, 0.2),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

//     _controller.forward();

//     // For quick testing
//     _emailController.text = "samal@nutantek.com";
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _sendResetLink() async {
//     final email = _emailController.text.trim();

//     if (email.isEmpty) {
//       _showMessage("Please enter your company email", isError: true);
//       return;
//     }

//     if (!email.contains('@') || !email.endsWith('.com')) {
//       _showMessage("Enter a valid email address", isError: true);
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final db = await DBHelper.instance.database;

//       // Check if email exists in employee_master
//       final List<Map<String, dynamic>> result = await db.query(
//         'employee_master',
//         where: 'emp_email = ?',
//         whereArgs: [email],
//       );

//       await Future.delayed(const Duration(seconds: 2)); // Fake delay

//       if (result.isNotEmpty) {
//         // Success - in real app, send email/OTP here
//         _showMessage("Password reset link sent to $email", isSuccess: true);

//         // After 2 seconds, go back to login
//         Future.delayed(const Duration(seconds: 2), () {
//           if (mounted) {
//             Navigator.pop(context);
//           }
//         });
//       } else {
//         _showMessage("This email is not registered with us", isError: true);
//       }
//     } catch (e) {
//       _showMessage("Something went wrong. Try again.", isError: true);
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _showMessage(
//     String message, {
//     bool isError = false,
//     bool isSuccess = false,
//   }) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isSuccess
//             ? Colors.green
//             : isError
//             ? Colors.red
//             : Colors.blue,
//         behavior: SnackBarBehavior.floating,
//         duration: Duration(seconds: isSuccess ? 3 : 4),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: isDark ? Colors.white : Colors.black87,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: isDark
//                 ? [Colors.black, Colors.grey[900]!]
//                 : [AppColors.primary.withOpacity(0.08), Colors.white],
//           ),
//         ),
//         child: SafeArea(
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: SlideTransition(
//               position: _slideAnimation,
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.only(
//                   left: 24,
//                   right: 24,
//                   top: 20,
//                   bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: 40),

//                     // Icon
//                     Center(
//                       child: Container(
//                         padding: EdgeInsets.all(24),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [AppColors.primary, AppColors.primaryLight],
//                           ),
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: AppColors.primary.withOpacity(0.3),
//                               blurRadius: 20,
//                             ),
//                           ],
//                         ),
//                         child: Icon(
//                           Icons.lock_reset,
//                           size: 60,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: 50),

//                     Text(
//                       "Forgot Password?",
//                       style: Theme.of(context).textTheme.headlineMedium
//                           ?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: isDark ? Colors.white : Colors.black87,
//                           ),
//                     ),

//                     SizedBox(height: 16),

//                     Text(
//                       "No worries! Enter your company email and we'll send you a password reset link.",
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: isDark ? Colors.white70 : Colors.grey[700],
//                         height: 1.5,
//                       ),
//                     ),

//                     SizedBox(height: 50),

//                     // Email Field
//                     TextField(
//                       controller: _emailController,
//                       keyboardType: TextInputType.emailAddress,
//                       decoration: InputDecoration(
//                         labelText: "Company Email",
//                         hintText: "e.g. name@nutantek.com",
//                         prefixIcon: Icon(Icons.email_outlined),
//                         filled: true,
//                         fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(16),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: 40),

//                     // Send Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _sendResetLink,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primary,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           elevation: 6,
//                         ),
//                         child: _isLoading
//                             ? SizedBox(
//                                 height: 24,
//                                 width: 24,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2.5,
//                                 ),
//                               )
//                             : Text(
//                                 "SEND RESET LINK",
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                       ),
//                     ),

//                     SizedBox(height: 40),

//                     Center(
//                       child: Text(
//                         "Make sure to check your spam folder if you don't see the email.",
//                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // lib/features/auth/presentation/screens/forgot_password_screen.dart
// import 'package:appattendance/core/utils/app_colors.dart';
// import 'package:appattendance/features/auth/presentation/screens/login_screen.dart';
// import 'package:flutter/material.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
//     with SingleTickerProviderStateMixin {
//   final _empIdController = TextEditingController();
//   final _otpController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   late AnimationController _animController;
//   late Animation<double> _opacity;
//   late Animation<Offset> _slide;

//   bool _isOtpSent = false;
//   bool _isOtpVerified = false;
//   bool _isLoading = false;
//   bool _obscureNewPassword = true;
//   bool _obscureConfirmPassword = true;

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
//     _empIdController.dispose();
//     _otpController.dispose();
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     _animController.dispose();
//     super.dispose();
//   }

//   Future<void> _sendOtp() async {
//     if (_empIdController.text.trim().isEmpty) {
//       _showSnackBar("Please enter Employee ID");
//       return;
//     }

//     setState(() => _isLoading = true);

//     // Fake delay — real API mein yahan call jayega
//     await Future.delayed(const Duration(seconds: 2));

//     setState(() {
//       _isLoading = false;
//       _isOtpSent = true;
//     });

//     _showSnackBar("OTP sent to registered email/phone (Fake: 123456)");
//   }

//   Future<void> _verifyOtp() async {
//     if (_otpController.text.trim() != "123456") {
//       _showSnackBar("Invalid OTP");
//       return;
//     }

//     setState(() {
//       _isOtpVerified = true;
//     });

//     _showSnackBar("OTP Verified Successfully!");
//   }

//   Future<void> _resetPassword() async {
//     if (_newPasswordController.text != _confirmPasswordController.text) {
//       _showSnackBar("Passwords do not match");
//       return;
//     }

//     if (_newPasswordController.text.length < 6) {
//       _showSnackBar("Password must be at least 6 characters");
//       return;
//     }

//     setState(() => _isLoading = true);

//     await Future.delayed(const Duration(seconds: 2));

//     setState(() => _isLoading = false);

//     _showSnackBar("Password updated successfully!", isSuccess: true);

//     // Back to login
//     Navigator.of(
//       context,
//     ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
//   }

//   void _showSnackBar(String message, {bool isSuccess = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isSuccess ? Colors.green : Colors.red,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       extendBodyBehindAppBar: true,
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: isDark
//                 ? [AppColors.primary.withOpacity(0.3), Colors.black]
//                 : [
//                     AppColors.primary.withOpacity(0.1),
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
//                   child: SingleChildScrollView(
//                     padding: EdgeInsets.only(
//                       left: 24,
//                       right: 24,
//                       top: 20,
//                       bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//                     ),
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 40),

//                         // Logo
//                         Container(
//                           width: 100,
//                           height: 100,
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [
//                                 AppColors.primary,
//                                 AppColors.primaryLight,
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: AppColors.primary.withOpacity(0.4),
//                                 blurRadius: 20,
//                               ),
//                             ],
//                           ),
//                           child: Center(
//                             child: Image.asset(
//                               'assets/images/nutantek_logo.png',
//                               width: 60,
//                               height: 60,
//                               errorBuilder: (_, __, ___) => const Icon(
//                                 Icons.lock_reset,
//                                 size: 50,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 32),

//                         Text(
//                           'Forgot Password?',
//                           style: Theme.of(context).textTheme.headlineMedium
//                               ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: isDark ? Colors.white : Colors.black87,
//                               ),
//                         ),
//                         Text(
//                           'Don\'t worry! It happens. Please enter your Employee ID',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: isDark ? Colors.white70 : Colors.grey[600],
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 48),

//                         Card(
//                           elevation: 12,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(28.0),
//                             child: Column(
//                               children: [
//                                 // Employee ID Field
//                                 TextFormField(
//                                   controller: _empIdController,
//                                   enabled: !_isOtpSent,
//                                   keyboardType: TextInputType.text,
//                                   textCapitalization:
//                                       TextCapitalization.characters,
//                                   decoration: InputDecoration(
//                                     labelText: 'Employee ID',
//                                     prefixIcon: const Icon(Icons.badge),
//                                     filled: true,
//                                     fillColor: isDark
//                                         ? Colors.grey[800]
//                                         : Colors.grey[50],
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 20),

//                                 // OTP Field (only after send)
//                                 if (_isOtpSent) ...[
//                                   TextFormField(
//                                     controller: _otpController,
//                                     enabled: !_isOtpVerified,
//                                     keyboardType: TextInputType.number,
//                                     decoration: InputDecoration(
//                                       labelText: 'Enter OTP',
//                                       hintText: 'Fake OTP: 123456',
//                                       prefixIcon: const Icon(Icons.sms),
//                                       filled: true,
//                                       fillColor: isDark
//                                           ? Colors.grey[800]
//                                           : Colors.grey[50],
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                         borderSide: BorderSide.none,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 20),
//                                 ],

//                                 // New Password Fields (after verify)
//                                 if (_isOtpVerified) ...[
//                                   TextFormField(
//                                     controller: _newPasswordController,
//                                     obscureText: _obscureNewPassword,
//                                     decoration: InputDecoration(
//                                       labelText: 'New Password',
//                                       prefixIcon: const Icon(
//                                         Icons.lock_outline,
//                                       ),
//                                       suffixIcon: IconButton(
//                                         icon: Icon(
//                                           _obscureNewPassword
//                                               ? Icons.visibility_off
//                                               : Icons.visibility,
//                                         ),
//                                         onPressed: () => setState(
//                                           () => _obscureNewPassword =
//                                               !_obscureNewPassword,
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
//                                   ),
//                                   const SizedBox(height: 20),
//                                   TextFormField(
//                                     controller: _confirmPasswordController,
//                                     obscureText: _obscureConfirmPassword,
//                                     decoration: InputDecoration(
//                                       labelText: 'Confirm Password',
//                                       prefixIcon: const Icon(
//                                         Icons.lock_outline,
//                                       ),
//                                       suffixIcon: IconButton(
//                                         icon: Icon(
//                                           _obscureConfirmPassword
//                                               ? Icons.visibility_off
//                                               : Icons.visibility,
//                                         ),
//                                         onPressed: () => setState(
//                                           () => _obscureConfirmPassword =
//                                               !_obscureConfirmPassword,
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
//                                   ),
//                                   const SizedBox(height: 32),
//                                 ],

//                                 // Action Button
//                                 SizedBox(
//                                   width: double.infinity,
//                                   height: 56,
//                                   child: ElevatedButton(
//                                     onPressed: _isLoading
//                                         ? null
//                                         : () {
//                                             if (!_isOtpSent) {
//                                               _sendOtp();
//                                             } else if (_isOtpSent &&
//                                                 !_isOtpVerified) {
//                                               _verifyOtp();
//                                             } else if (_isOtpVerified) {
//                                               _resetPassword();
//                                             }
//                                           },
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: AppColors.primary,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(14),
//                                       ),
//                                       elevation: 6,
//                                     ),
//                                     child: _isLoading
//                                         ? const CircularProgressIndicator(
//                                             color: Colors.white,
//                                           )
//                                         : Text(
//                                             _isOtpVerified
//                                                 ? 'RESET PASSWORD'
//                                                 : _isOtpSent
//                                                 ? 'VERIFY OTP'
//                                                 : 'SEND OTP',
//                                             style: const TextStyle(
//                                               fontSize: 18,
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 40),

//                         TextButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text(
//                             'Back to Login',
//                             style: TextStyle(color: AppColors.primary),
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
