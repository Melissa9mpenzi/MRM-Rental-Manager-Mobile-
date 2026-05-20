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

class AccountApprovedScreen extends ConsumerWidget {
  const AccountApprovedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final home = user != null ? roleDashboardPath(user.role) : RouteNames.tenantDashboard;

    return AuthPageScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AuthFlowStepper(step: 10),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0x3322C55E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded, size: 48, color: AppColors.accentGreen),
                ),
                const SizedBox(height: 20),
                Text('Account approved', style: AppTextStyles.headingLarge),
                const SizedBox(height: 10),
                Text(
                  'Your dashboard is unlocked. Welcome to RentDirect UG.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.textMutedOnDark),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go(home),
                    child: const Text('Go to dashboard'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
