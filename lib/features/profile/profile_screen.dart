import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final kyc = user?.kycReviewStatus ?? 'none';
    final kycLabel = kyc == 'approved'
        ? 'Verified'
        : kyc == 'pending'
            ? 'Pending review'
            : kyc == 'rejected'
                ? 'Rejected'
                : 'Not submitted';

    return PageScaffold(
      title: 'Profile',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassPanel(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.accentGreen.withValues(alpha: 0.25),
                  child: const Icon(Icons.person_rounded, size: 36, color: AppColors.accentGreen),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.fullName ?? 'Your name', style: AppTextStyles.headingMedium),
                      if (user?.email != null) Text(user!.email, style: AppTextStyles.captionOnDark),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('KYC: $kycLabel', style: AppTextStyles.caption.copyWith(color: AppColors.accentGreen, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _tile(context, Icons.settings_outlined, 'Settings', () => context.push(RouteNames.settings)),
          _tile(context, Icons.badge_outlined, 'KYC documents', () => context.push(RouteNames.kyc)),
          _tile(context, Icons.language_rounded, 'Language', () => context.push(RouteNames.language)),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            borderRadius: 14,
            child: Row(
              children: [
                Icon(icon, color: AppColors.textOnDark),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: AppTextStyles.bodyMediumOnDark)),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedOnDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
