import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/blockchain_api.dart';
import 'package:rental_mgr_mobile/core/api/payments_api.dart';
import 'package:rental_mgr_mobile/core/api/tenant_api.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/payments/payment_method_config.dart';
import 'package:rental_mgr_mobile/core/utils/format_ugx.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/payment_method_icon.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';
import 'package:rental_mgr_mobile/features/wallet/widgets/wallet_onchain_section.dart';
import 'package:rental_mgr_mobile/features/wallet/widgets/wallet_trust_card.dart';

final walletSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(paymentsApiProvider).walletSummary();
});

final walletTransactionsProvider = FutureProvider<List<dynamic>>((ref) async {
  final role = ref.watch(authProvider).user?.role;
  if (role == 'tenant') {
    try {
      return await ref.read(tenantApiProvider).myPayments();
    } catch (_) {
      return <dynamic>[];
    }
  }
  return ref.watch(paymentsApiProvider).list();
});

final walletMyChainProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    return await ref.watch(blockchainApiProvider).myWallet();
  } catch (_) {
    return {};
  }
});

final walletChainReceiptsProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    return await ref.watch(blockchainApiProvider).listReceipts(limit: 5);
  } catch (_) {
    return [];
  }
});

final walletChainEscrowsProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    return await ref.watch(blockchainApiProvider).listEscrows();
  } catch (_) {
    return [];
  }
});

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(walletSummaryProvider);
    final tx = ref.watch(walletTransactionsProvider);
    final myChain = ref.watch(walletMyChainProvider);
    final chainReceipts = ref.watch(walletChainReceiptsProvider);
    final chainEscrows = ref.watch(walletChainEscrowsProvider);
    final role = ref.watch(authProvider).user?.role ?? 'tenant';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Future<void> refresh() async {
      ref.invalidate(walletSummaryProvider);
      ref.invalidate(walletTransactionsProvider);
      ref.invalidate(walletMyChainProvider);
      ref.invalidate(walletChainReceiptsProvider);
      ref.invalidate(walletChainEscrowsProvider);
    }

    return PageScaffold(
      title: 'Wallet',
      body: RefreshIndicator(
        color: AppColors.accentGreen,
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            summary.when(
              data: (s) {
                final total = _num(s['total_paid_ugx'] ?? s['total_collected_ugx'] ?? s['available_ugx']);
                final count = (s['payment_count'] as num?)?.toInt() ?? 0;
                final byMethod = (s['by_method'] as Map?)?.cast<String, dynamic>() ?? {};
                return GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Balance', style: AppTextStyles.captionOnDark),
                      const SizedBox(height: 6),
                      Text(formatUgx(total), style: AppTextStyles.displayHero.copyWith(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(
                        '$count payments · ${s['scope'] ?? role}',
                        style: AppTextStyles.captionOnDark,
                      ),
                      if (byMethod.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: byMethod.entries.map((e) {
                            final pm = AppPaymentMethod.fromApi(e.key) ?? AppPaymentMethod.mtnMomo;
                            return Chip(
                              backgroundColor: AppColors.glassFill,
                              side: const BorderSide(color: AppColors.glassBorder),
                              avatar: PaymentMethodIcon(method: pm, size: 22, borderRadius: 4),
                              label: Text(
                                '${pm.label} · ${formatUgx(_num(e.value))}',
                                style: AppTextStyles.captionOnDark.copyWith(fontSize: 11),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (role == 'tenant')
                            FilledButton.icon(
                              onPressed: () => context.push(RouteNames.payRent),
                              icon: const Icon(Icons.payments_outlined, size: 18),
                              label: const Text('Pay rent'),
                            ),
                          if (role != 'staff')
                            OutlinedButton.icon(
                              onPressed: () => context.push(RouteNames.receipts),
                              icon: const Icon(Icons.receipt_long_outlined, size: 18),
                              label: const Text('Receipts'),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const GlassPanel(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: AppColors.accentGreen)),
                ),
              ),
              error: (_, __) => GlassPanel(
                child: Text(
                  'Could not load wallet summary.',
                  style: AppTextStyles.captionOnDark,
                ),
              ),
            ),
            const SizedBox(height: 12),
            myChain.when(
              data: (w) => WalletTrustCard(wallet: w),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            chainReceipts.when(
              data: (receipts) => chainEscrows.when(
                data: (escrows) => WalletOnchainSection(receipts: receipts, escrows: escrows),
                loading: () => WalletOnchainSection(receipts: receipts, escrows: const []),
                error: (_, __) => WalletOnchainSection(receipts: receipts, escrows: const []),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            Text('Recent transactions', style: AppTextStyles.headingMedium),
            const SizedBox(height: 12),
            tx.when(
              data: (list) {
                if (list.isEmpty) {
                  return Text(
                    'No transactions yet.',
                    style: isDark
                        ? AppTextStyles.captionOnDark
                        : AppTextStyles.bodySmallOnDark.copyWith(color: AppColors.sageSlate),
                  );
                }
                return Column(
                  children: list.take(20).map((p) {
                    final m = p as Map<String, dynamic>;
                    final method = m['payment_method'] as String? ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassPanel(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 16,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: PaymentMethodIconFromApi(apiValue: method, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatUgx(_num(m['amount'])),
                                    style: (isDark
                                            ? AppTextStyles.bodyMediumOnDark
                                            : AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.textPrimary))
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${m['payment_date'] ?? ''} · ${paymentMethodLabelFromApi(method)}',
                                    style: isDark
                                        ? AppTextStyles.captionOnDark
                                        : AppTextStyles.bodySmallOnDark.copyWith(color: AppColors.sageSlate),
                                  ),
                                  if (m['property_name'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        '${m['property_name']}',
                                        style: (isDark
                                                ? AppTextStyles.captionOnDark
                                                : AppTextStyles.bodySmallOnDark.copyWith(color: AppColors.sageSlate))
                                            .copyWith(fontSize: 10),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: AppColors.textMutedOnDark, size: 20),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.accentGreen),
                ),
              ),
              error: (_, __) => Text(
                'Could not load transactions.',
                style: isDark
                    ? AppTextStyles.captionOnDark
                    : AppTextStyles.bodySmallOnDark.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

num _num(dynamic v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? 0;
  return 0;
}
