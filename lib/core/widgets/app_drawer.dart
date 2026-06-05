import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/navigation/drawer_menu.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final role = user?.role ?? 'tenant';
    final items = drawerItemsForRole(role);

    return Drawer(
      backgroundColor: AppColors.surfaceDark,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [AppColors.accentGreen, Color(0xFF059669)],
                          ),
                        ),
                        child: const Icon(Icons.home_work_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('RentDirect UG', style: AppTextStyles.headingSmallOnDark),
                            Text(
                              user?.fullName ?? 'Guest',
                              style: AppTextStyles.captionOnDark,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.glassBorder, height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  final current = GoRouterState.of(context).uri.path == item.route;
                  return ListTile(
                    leading: Icon(
                      item.icon,
                      color: current ? AppColors.accentGreen : AppColors.textMutedOnDark,
                    ),
                    title: Text(
                      item.label,
                      style: AppTextStyles.bodyMediumOnDark.copyWith(
                        color: current ? AppColors.accentGreen : AppColors.textOnDark,
                        fontWeight: current ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.go(item.route);
                    },
                  );
                },
              ),
            ),
            const Divider(color: AppColors.glassBorder, height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: Text('Sign out', style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go(RouteNames.authEntry);
              },
            ),
          ],
        ),
      ),
    );
  }
}
