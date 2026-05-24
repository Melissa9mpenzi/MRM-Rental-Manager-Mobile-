import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';

class SuiShell extends StatelessWidget {
  const SuiShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    const tabs = [
      RouteNames.suiDashboard,
      RouteNames.suiTransactions,
      RouteNames.suiEscrow,
      RouteNames.suiWallet,
    ];
    final labels = ['Dashboard', 'Transactions', 'Contracts', 'Wallet'];
    final icons = [
      Icons.dashboard_outlined,
      Icons.swap_horiz_rounded,
      Icons.shield_outlined,
      Icons.account_balance_wallet_outlined,
    ];
    final activeIcons = [
      Icons.dashboard_rounded,
      Icons.swap_horiz,
      Icons.shield,
      Icons.account_balance_wallet,
    ];
    final idx = tabs.indexOf(path).clamp(0, tabs.length - 1);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1423),
        elevation: 0,
        title: Text('Sui Portal', style: AppTextStyles.titleOnDark),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.4)),
              color: const Color(0xFF22D3EE).withOpacity(0.08),
            ),
            child: Text('Sui Devnet', style: AppTextStyles.caption.copyWith(color: const Color(0xFF67E8F9), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1423),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
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
                      Icon(active ? activeIcons[i] : icons[i], size: 22, color: active ? const Color(0xFF8B5CF6) : AppColors.textMutedOnDark),
                      const SizedBox(height: 2),
                      Text(labels[i], style: AppTextStyles.caption.copyWith(fontSize: 10, color: active ? const Color(0xFF8B5CF6) : AppColors.textMutedOnDark, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
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
