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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [AppColors.brandDark, const Color(0xFF1C262E)] 
              : [AppColors.bg, Colors.white],
          ),
        ),
        child: RefreshIndicator(
          color: AppColors.accentGreen,
          onRefresh: refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Wallet Activity',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: isDark ? Colors.white : AppColors.brandDark,
                        letterSpacing: -0.5,
                      )),
                  IconButton(
                    icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                    onPressed: toggleTheme,
                    color: AppColors.accentGreen,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.accentGreen.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              summary.when(
                data: (s) {
                  final total = _num(s['total_paid_ugx']);
                  final count = (s['payment_count'] as num?)?.toInt() ?? 0;
                  final byMethod =
                      (s['by_method'] as Map?)?.cast<String, dynamic>() ?? {};
                  return GlassPanel(
                    borderRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total recorded',
                            style: isDark
                                ? AppTextStyles.captionOnDark
                                : AppTextStyles.bodySmallOnDark
                                    .copyWith(color: AppColors.mid)),
                        const SizedBox(height: 6),
                        Text(
                          formatUgx(total),
                          style: AppTextStyles.displayHero.copyWith(
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.brandDark,
                            shadows: [
                              Shadow(
                                color: AppColors.accentGreen.withOpacity(0.4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$count payments · ${s['scope'] ?? ''}',
                          style: (isDark
                              ? AppTextStyles.captionOnDark
                              : AppTextStyles.bodySmallOnDark
                                  .copyWith(color: AppColors.mid)).copyWith(fontWeight: FontWeight.w500),
                        ),
                        if (byMethod.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text('Usage breakdown', 
                              style: isDark
                                  ? AppTextStyles.captionOnDark.copyWith(fontSize: 10, uppercase: true)
                                  : AppTextStyles.bodySmallOnDark.copyWith(color: AppColors.mid, fontSize: 10, uppercase: true)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: byMethod.entries.map((e) {
                              final pm = AppPaymentMethod.fromApi(e.key) ??
                                  AppPaymentMethod.other;
                              return Chip(
                                backgroundColor: isDark
                                    ? AppColors.glassFill
                                    : Colors.white.withOpacity(0.8),
                                side: BorderSide(
                                    color: isDark ? AppColors.glassBorder : AppColors.accentGreen.withOpacity(0.2)),
                                avatar: PaymentMethodIcon(
                                    method: pm, size: 20, borderRadius: 4),
                                label: Text(
                                  '${pm.label} · ${formatUgx(_num(e.value))}',
                                  style: (isDark
                                          ? AppTextStyles.captionOnDark
                                          : AppTextStyles.bodySmallOnDark
                                              .copyWith(
                                                  color: AppColors.brandDark))
                                      .copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            if (role == 'tenant')
                              Expanded(
                                child: FilledButton(
                                  onPressed: () => context.push(RouteNames.payRent),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.accentGreen,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Pay Rent Now'),
                                ),
                              ),
                            if (role == 'tenant') const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => context.push(RouteNames.receipts),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.accentGreen),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('View Receipts'),
                              ),
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
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.accentGreen)),
                  ),
                ),
                error: (err, __) => GlassPanel(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Could not load summary: $err'),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text('Recent Transactions', 
                style: AppTextStyles.headingMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.brandDark,
                  fontSize: 18,
                )),
              const SizedBox(height: 16),
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
