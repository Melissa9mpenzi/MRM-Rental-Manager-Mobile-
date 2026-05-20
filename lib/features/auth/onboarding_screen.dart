import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/constants/app_assets.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_flow_stepper.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_hero_image.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/value_props_strip.dart';

/// Step 2 — Onboarding slides (same photos as web).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _page = PageController();
  int _index = 0;

  static const _pages = [
    _OnboardPage(
      step: 2,
      imageAsset: AppAssets.heroVilla,
      title: 'Find verified rentals in Uganda',
      subtitle: 'Browse trusted listings with smart filters and AI recommendations.',
    ),
    _OnboardPage(
      step: 2,
      imageAsset: AppAssets.listingLuxury,
      title: 'Secure payments',
      subtitle: 'Pay rent, top up your wallet, and track transactions in one place.',
    ),
    _OnboardPage(
      step: 2,
      imageAsset: AppAssets.listingInterior,
      title: 'Contracts & trust',
      subtitle: 'Digital leases, blockchain-backed records, and messaging built in.',
    ),
  ];

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _pages.length - 1) {
      _page.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    } else {
      context.go(RouteNames.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(child: AuthFlowStepper(step: 2)),
                TextButton(
                  onPressed: () => context.go(RouteNames.login),
                  child: Text('Skip', style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.textMutedOnDark)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _index ? AppColors.accentGreen : AppColors.textMutedOnDark.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const ValuePropsStrip(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                child: Text(_index == _pages.length - 1 ? 'Create account' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({
    required this.step,
    required this.imageAsset,
    required this.title,
    required this.subtitle,
  });

  final int step;
  final String imageAsset;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: AuthHeroImage(assetPath: imageAsset),
        ),
        const SizedBox(height: 28),
        Text(title, style: AppTextStyles.headingLarge),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.textMutedOnDark, height: 1.45),
        ),
      ],
    );
  }
}
