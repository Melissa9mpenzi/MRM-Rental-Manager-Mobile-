import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/auth/onboarding_navigation.dart';
import 'package:rental_mgr_mobile/core/config/sui_config.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';

class SuiShell extends ConsumerWidget {
  const SuiShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    const tabs = [
      RouteNames.suiDashboard,
      RouteNames.suiTransactions,
      RouteNames.suiEscrow,
      RouteNames.suiWallet,
    ];
    const labels = ['Dashboard', 'Transactions', 'Contracts', 'Wallet'];
    const icons = [
      Icons.dashboard_outlined,
      Icons.swap_horiz_rounded,
      Icons.shield_outlined,
      Icons.account_balance_wallet_outlined,
    ];
    const activeIcons = [
      Icons.dashboard_rounded,
      Icons.swap_horiz,
      Icons.shield,
      Icons.account_balance_wallet,
    ];
    final idx = path.startsWith('/sui/receipts/')
        ? 0
        : tabs.indexOf(path).clamp(0, tabs.length - 1);
    final role = ref.watch(authProvider).user?.role ?? 'tenant';
    final home = roleDashboardPath(role);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1423),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to app',
          onPressed: () => context.go(home),
        ),
        title: Text('Sui Portal', style: AppTextStyles.titleOnDark),
        actions: [
          TextButton(
            onPressed: () => context.go(home),
            child: const Text('Main app', style: TextStyle(color: Color(0xFF67E8F9), fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF22D3EE).withValues(alpha: 0.4)),
              color: const Color(0xFF22D3EE).withValues(alpha: 0.08),
            ),
            child: Text(
              SuiConfig.label,
              style: AppTextStyles.caption.copyWith(color: const Color(0xFF67E8F9), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1423),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (i) {
              final active = i == idx;
              return InkWell(
                onTap: () => context.go(tabs[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? activeIcons[i] : icons[i],
                        size: 22,
                        color: active ? const Color(0xFF8B5CF6) : AppColors.textMutedOnDark,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        labels[i],
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: active ? const Color(0xFF8B5CF6) : AppColors.textMutedOnDark,
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
    );
  }
}
