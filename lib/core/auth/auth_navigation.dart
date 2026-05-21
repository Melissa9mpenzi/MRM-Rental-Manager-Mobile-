import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/auth/onboarding_navigation.dart';
import 'package:rental_mgr_mobile/core/models/app_user.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';

/// Navigate after successful sign-in (explicit go + router redirect backup).
Future<void> navigateAfterLogin(
  WidgetRef ref,
  BuildContext context, {
  required AppUser user,
  required bool onboardingLogin,
}) async {
  final inSignupFlow =
      onboardingLogin || ref.read(authProvider).onboardingFlowActive;

  if (inSignupFlow) {
    await ref.read(authProvider.notifier).beginOnboardingFlow();
    if (context.mounted) context.go(RouteNames.selectRole);
    return;
  }

  final dest = postLoginDestination(user);
  if (shouldClearOnboardingFlow(user, dest)) {
    await ref.read(authProvider.notifier).endOnboardingFlow();
  }
  if (context.mounted) context.go(dest);
}
