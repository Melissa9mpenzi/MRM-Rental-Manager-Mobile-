import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSendOtp() {
    // Navigation to OTP verification screen
    context.push(RouteNames.otpVerification);
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      showAppBar: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome Back 👋",
              style: AppTextStyles.headingMedium.copyWith(
                fontSize: 28,
                color: AppColors.brandDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter your phone number to continue",
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.mid),
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    "+256",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: AppColors.brandDark),
                    decoration: InputDecoration(
                      hintText: "700 000 000",
                      hintStyle: const TextStyle(color: AppColors.mid),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _handleSendOtp,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: AppColors.accentGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("SEND OTP",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
