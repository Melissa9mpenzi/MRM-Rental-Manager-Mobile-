import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/auth/onboarding_navigation.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_flow_stepper.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';

/// Spec: no dashboard until admin approves — user stays on this screen.
class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthPageScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AuthFlowStepper(step: 9),
                const SizedBox(height: 20),
                const Icon(Icons.hourglass_top_rounded, size: 56, color: AppColors.warning),
                const SizedBox(height: 20),
                Text('Under review', style: AppTextStyles.headingLarge),
                const SizedBox(height: 10),
                Text(
                  'Your verification is under review. An admin will check your documents for fraud and compliance. You cannot access your dashboard until approved.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.textMutedOnDark),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).refreshProfile();
                      final user = ref.read(authProvider).user;
                      if (user != null && context.mounted) {
                        if (user.trustedForCommerce || user.kycReviewStatus == 'approved') {
                          context.go(RouteNames.accountApproved);
                        }
                      }
                    },
                    child: const Text('Check approval status'),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go(RouteNames.authEntry);
                  },
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
