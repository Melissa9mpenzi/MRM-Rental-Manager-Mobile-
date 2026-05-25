import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/auth/auth_flow_prefs.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/models/app_user.dart';
import 'package:rental_mgr_mobile/core/auth/onboarding_navigation.dart';
import 'package:rental_mgr_mobile/core/constants/app_assets.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_hero_image.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/brand_logo.dart';

/// Step 1 — Splash
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goAuthenticated(WidgetRef ref, AppUser user) async {
    final dest = postLoginDestination(user);
    if (shouldClearOnboardingFlow(user, dest)) {
      await ref.read(authProvider.notifier).endOnboardingFlow();
    }
    if (!mounted) return;
    context.go(dest);
  }

  Future<void> _goNext() async {
    if (!ref.read(authProvider).bootstrapped) {
      await ref.read(authProvider.notifier).bootstrap();
    }
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final auth = ref.read(authProvider);
    if (auth.isAuthenticated && auth.user != null) {
      await _goAuthenticated(ref, auth.user!);
      return;
    }

    final resume = await AuthFlowPrefs.resumeSignupRoute();
    if (resume != null) {
      context.go(resume);
      return;
    }
    if (await AuthFlowPrefs.hasSeenOnboarding()) {
      context.go(RouteNames.login);
      return;
    }
    context.go(RouteNames.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthHeroImage(assetPath: AppAssets.heroVilla),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BrandLogo(height: 96, showTagline: true),
                const SizedBox(height: 40),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.accentGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
