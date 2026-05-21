import 'package:shared_preferences/shared_preferences.dart';

/// Persists signup funnel progress so cold start does not return to slide 1.
class AuthFlowPrefs {
  static const _onboardingSeen = 'auth_onboarding_seen';
  static const _signupStep = 'auth_signup_step';
  static const _signupEmail = 'auth_signup_email';
  static const _onboardingActive = 'auth_onboarding_flow_active';

  /// `verify` = awaiting email OTP; `login` = verified, needs password login + role.
  static const stepVerify = 'verify';
  static const stepLogin = 'login';

  static Future<bool> hasSeenOnboarding() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_onboardingSeen) ?? false;
  }

  static Future<void> markOnboardingSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_onboardingSeen, true);
  }

  static Future<void> setSignupStep({required String step, required String email}) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_signupStep, step);
    await p.setString(_signupEmail, email.trim());
    await markOnboardingSeen();
  }

  static Future<String?> signupStep() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_signupStep);
  }

  static Future<String?> signupEmail() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_signupEmail);
  }

  static Future<void> clearSignupProgress() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_signupStep);
    await p.remove(_signupEmail);
  }

  static Future<void> setOnboardingFlowActive(bool active) async {
    final p = await SharedPreferences.getInstance();
    if (active) {
      await p.setBool(_onboardingActive, true);
    } else {
      await p.remove(_onboardingActive);
    }
  }

  static Future<bool> isOnboardingFlowActive() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_onboardingActive) ?? false;
  }

  /// Route for an unauthenticated user resuming signup (or null → caller picks login/onboarding).
  static Future<String?> resumeSignupRoute() async {
    final step = await signupStep();
    final email = await signupEmail();
    if (email == null || email.isEmpty) return null;
    final enc = Uri.encodeComponent(email);
    if (step == stepVerify) return '/verify-phone?email=$enc';
    if (step == stepLogin) return '/login?email=$enc&onboarding=1';
    return null;
  }
}
