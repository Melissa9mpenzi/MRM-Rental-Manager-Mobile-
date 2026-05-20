import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';

/// Explains how Google / Apple map to the existing FastAPI `POST /auth/firebase` flow.
Future<void> showSocialSignInHelpDialog(BuildContext context, {required String provider}) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      title: Text('$provider sign-in', style: AppTextStyles.headingSmallOnDark),
      content: SingleChildScrollView(
        child: Text(
          'The API exchanges a Firebase ID token for your RentDirect JWT (see POST /api/v1/auth/firebase).\n\n'
          'To enable $provider in this app:\n'
          '1) Create a Firebase project and add Android/iOS/Web apps.\n'
          '2) Run: dart pub global activate flutterfire_cli && flutterfire configure\n'
          '3) Add firebase_core + firebase_auth + google_sign_in to pubspec, initialize Firebase in main(),\n'
          '   sign in with GoogleProvider, read idToken, then call AuthApi.firebaseSignIn(idToken).\n'
          '4) The email on the Google account must already exist in RentDirect (register with email first).\n\n'
          'Until then, use email + password — the same account as the web app.',
          style: AppTextStyles.bodySmallOnDark.copyWith(height: 1.45),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('OK', style: AppTextStyles.bodySmallOnDark.copyWith(color: AppColors.accentGreen)),
        ),
      ],
    ),
  );
}
