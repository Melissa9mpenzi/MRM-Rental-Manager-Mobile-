import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';

/// Government and global admin accounts are web-only.
class GovernmentWebOnlyScreen extends ConsumerWidget {
  const GovernmentWebOnlyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final roleLabel = user?.role == 'system_admin'
        ? 'SYSTEM ADMINISTRATOR'
        : (user?.role.replaceAll('_', ' ').toUpperCase() ?? 'GOVERNMENT');

    return AuthPageScaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: GlassPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language, size: 48, color: Colors.white.withValues(alpha: 0.85)),
                const SizedBox(height: 16),
                Text('Use the web portal', style: AppTextStyles.titleOnDark),
                const SizedBox(height: 12),
                Text(
                  'Your $roleLabel account is managed on the RentDirect web console in a desktop browser. '
                  'The mobile app is for tenants, landlords, and agents only.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMediumOnDark,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go(RouteNames.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: AppColors.canvasDark,
                    ),
                    child: const Text('Sign out'),
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
