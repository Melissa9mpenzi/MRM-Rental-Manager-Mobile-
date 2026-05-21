import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/features/auth/forgot_password_screen.dart';

/// Deep link to step 2 of forgot-password (same flow as web step 2).
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return ForgotPasswordScreen(initialEmail: email, initialStep: 2);
  }
}
