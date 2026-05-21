import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/auth/onboarding_navigation.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/app_drawer.dart';

final shellScaffoldKeyProvider = Provider<GlobalKey<ScaffoldState>>((ref) => GlobalKey<ScaffoldState>());

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shellKey = ref.watch(shellScaffoldKeyProvider);
    final user = ref.watch(authProvider).user;
    final role = user?.role ?? 'tenant';
    final home = user != null ? roleDashboardPath(user.role) : RouteNames.tenantDashboard;

    final path = GoRouterState.of(context).uri.path;
    final bottomRoutes = [
      home,
      RouteNames.messages,
      RouteNames.notifications,
      RouteNames.wallet,
      RouteNames.profile,
    ];
    final labels = ['Home', 'Messages', 'Alerts', 'Wallet', 'Profile'];
    final icons = [
      Icons.dashboard_outlined,
      Icons.chat_bubble_outline_rounded,
      Icons.notifications_none_rounded,
      Icons.account_balance_wallet_outlined,
      Icons.person_outline_rounded,
    ];
    final activeIcons = [
      Icons.dashboard_rounded,
      Icons.chat_bubble_rounded,
      Icons.notifications_rounded,
      Icons.account_balance_wallet_rounded,
      Icons.person_rounded,
    ];

    final current = _bottomNavIndex(path, role, home);

    final showBottomNav = bottomRoutes.contains(path) ||
        path == RouteNames.search ||
        path == RouteNames.saved ||
        path == RouteNames.contracts ||
        path == RouteNames.payRent ||
        path == RouteNames.landlordProperties ||
        path == RouteNames.maintenance ||
        path == RouteNames.submitMaintenance ||
        ((role == 'tenant' || role == 'staff') && path.startsWith('/listings/')) ||
        (path.startsWith('/messages/') && path != RouteNames.messages);

    return Scaffold(
      key: shellKey,
      backgroundColor: AppColors.canvasDark,
      drawer: const AppDrawer(),
      body: child,
      bottomNavigationBar: showBottomNav
          ? Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                border: Border(top: BorderSide(color: AppColors.glassBorder.withOpacity(0.6))),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(5, (i) {
                      final active = i == current;
                      return InkWell(
                        onTap: () => context.go(bottomRoutes[i]),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                active ? activeIcons[i] : icons[i],
                                size: 22,
                                color: active ? AppColors.accentGreen : AppColors.textMutedOnDark,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                labels[i],
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10,
                                  color: active ? AppColors.accentGreen : AppColors.textMutedOnDark,
                                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

/// Opens the shell drawer from nested scaffolds.
void openAppDrawer(BuildContext context, WidgetRef ref) {
  ref.read(shellScaffoldKeyProvider).currentState?.openDrawer();
}

int _bottomNavIndex(String path, String role, String home) {
  if (path == RouteNames.messages) return 1;
  if (path == RouteNames.notifications) return 2;
  if (path == RouteNames.wallet) return 3;
  if (path == RouteNames.profile) return 4;
  if (path == home) return 0;
  if (role == 'tenant') {
    if (path == RouteNames.search ||
        path == RouteNames.saved ||
        path == RouteNames.contracts ||
        path == RouteNames.payRent ||
        path.startsWith('/listings/')) {
      return 0;
    }
  }
  if (role == 'landlord') {
    if (path == RouteNames.landlordProperties ||
        path == RouteNames.maintenance ||
        path == RouteNames.submitMaintenance) {
      return 0;
    }
  }
  if (role == 'staff' && (path == RouteNames.search || path.startsWith('/listings/'))) {
    return 0;
  }
  return 0;
}
