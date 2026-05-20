import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/payments_api.dart';
import 'package:rental_mgr_mobile/core/api/tenant_api.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

final _walletTxProvider = FutureProvider<List<dynamic>>((ref) async {
  final role = ref.watch(authProvider).user?.role;
  if (role == 'tenant') {
    try {
      return ref.watch(tenantApiProvider).myPayments();
    } catch (_) {
      return [];
    }
  }
  return ref.watch(paymentsApiProvider).list();
});

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = ref.watch(_walletTxProvider);

    return PageScaffold(
      title: 'Wallet',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total balance', style: AppTextStyles.captionOnDark),
                const SizedBox(height: 6),
                Text('UGX —', style: AppTextStyles.displayHero.copyWith(fontSize: 32)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(onPressed: () {}, child: const Text('Top up')),
                    OutlinedButton(onPressed: () {}, child: const Text('Send')),
                    OutlinedButton(onPressed: () {}, child: const Text('History')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Recent transactions', style: AppTextStyles.headingMedium),
          const SizedBox(height: 12),
          tx.when(
            data: (list) {
              if (list.isEmpty) {
                return Text('No transactions yet.', style: AppTextStyles.captionOnDark);
              }
              return Column(
                children: list.take(15).map((p) {
                  final m = p as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassPanel(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 12,
                      child: Row(
                        children: [
                          const Icon(Icons.receipt_long_outlined, color: AppColors.accentGreen),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('UGX ${m['amount'] ?? '—'}', style: AppTextStyles.bodyMediumOnDark),
                                Text('${m['payment_date'] ?? m['status'] ?? ''}', style: AppTextStyles.captionOnDark),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGreen)),
            error: (_, __) => Text('Transactions from payments API.', style: AppTextStyles.captionOnDark),
          ),
        ],
      ),
    );
  }
}
