import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(walletSummaryProvider);
    final tx = ref.watch(walletTransactionsProvider);
    final role = ref.watch(authProvider).user?.role ?? 'tenant';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void toggleTheme() {
      // Note: This assumes an AppTheme notifier is available in your core providers
      // If not yet implemented, this shows how to wire the UI for the 'Live' theme toggle
      try {
        // ref.read(appThemeProvider.notifier).toggle();
      } catch (e) { /* Fallback if provider is missing in this context */ }
    }

    Future<void> refresh() async {
      ref.invalidate(walletSummaryProvider);
      ref.invalidate(walletTransactionsProvider);
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
                final total = _num(s['total_paid_ugx']);
                final count = (s['payment_count'] as num?)?.toInt() ?? 0;
                final byMethod = (s['by_method'] as Map?)?.cast<String, dynamic>() ?? {};
                return GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total recorded', style: AppTextStyles.captionOnDark),
                      const SizedBox(height: 6),
                      Text(formatUgx(total), style: AppTextStyles.displayHero.copyWith(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(
                        '$count payments · ${s['scope'] ?? ''}',
                        style: AppTextStyles.captionOnDark,
                      ),
                      if (byMethod.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text('Methods used (from history)', style: AppTextStyles.captionOnDark),
                        const SizedBox(height: 8),
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
                          OutlinedButton.icon(
                            onPressed: () => context.push(RouteNames.receipts),
                            icon: const Icon(Icons.receipt_long_outlined, size: 18),
                            label: const Text('Receipts'),
                          ),
                          OutlinedButton(
                            onPressed: () => _showWalletActionsInfo(context, role),
                            child: const Text('Top up / Send / Withdraw'),
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
                  'Could not load wallet summary. Is the API running?',
                  style: AppTextStyles.captionOnDark,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Recent transactions', style: AppTextStyles.headingMedium),
            const SizedBox(height: 12),
            tx.when(
              data: (list) {
                if (list.isEmpty) {
                  return Text('No transactions yet.',
                      style: isDark
                          ? AppTextStyles.captionOnDark
                          : AppTextStyles.bodySmallOnDark
                              .copyWith(color: AppColors.mid));
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
                                  color: AppColors.accentGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: PaymentMethodIconFromApi(
                                    apiValue: method, size: 28),
                              ),
                              const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(formatUgx(_num(m['amount'])),
                                      style: isDark
                                            ? AppTextStyles.bodyMediumOnDark.copyWith(fontWeight: FontWeight.bold)
                                          : AppTextStyles.bodyMediumOnDark
                                              .copyWith(
                                                    color: AppColors.brandDark, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                  Text(
                                    '${m['payment_date'] ?? ''} · ${paymentMethodLabelFromApi(method)}',
                                    style: isDark
                                        ? AppTextStyles.captionOnDark
                                        : AppTextStyles.bodySmallOnDark
                                            .copyWith(color: AppColors.mid),
                                  ),
                                  if (m['property_name'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text('${m['property_name']}',
                                            style: (isDark
                                                ? AppTextStyles.captionOnDark
                                                : AppTextStyles.bodySmallOnDark
                                                    .copyWith(color: AppColors.mid)).copyWith(fontSize: 10),
                                            maxLines: 1),
                                      ),
                                ],
                              ),
                            ),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.mid, size: 20),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.accentGreen)),
              ),
              error: (_, __) => Text('Could not load transactions.',
                  style: isDark
                      ? AppTextStyles.captionOnDark
                      : AppTextStyles.bodySmallOnDark
                          .copyWith(color: AppColors.brandDark)),
            ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWalletActionsInfo(BuildContext context, String role) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.surfaceDark 
            : Colors.white,
        title: Text('Wallet actions', style: Theme.of(context).brightness == Brightness.dark 
            ? AppTextStyles.headingSmallOnDark 
            : AppTextStyles.headingSmall.copyWith(color: AppColors.brandDark)),
        content: Text(
          role == 'tenant'
              ? 'Your balance is the sum of rent payments recorded for your tenancy in RentDirect. '
                  'Top-up, peer-to-peer send, and withdrawals are not processed inside this app yet — '
                  'use Pay rent when your landlord invoices you, or pay offline and ask them to record it.'
              : 'This wallet shows rent collected and recorded in RentDirect. '
                  'Disbursements to MTN/Airtel/bank are handled outside the app for now.',
          style: AppTextStyles.bodySmallOnDark.copyWith(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK',
                style: AppTextStyles.bodySmallOnDark
                    .copyWith(color: AppColors.accentGreen)),
          ),
        ],
      ),
    );
  }
}

num _num(dynamic v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? 0;
  return 0;
}
