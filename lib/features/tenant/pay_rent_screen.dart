import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/tenant_api.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/payments/checkout_flow.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/utils/format_ugx.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

final _invoicesProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(tenantApiProvider).myInvoices();
});

class PayRentScreen extends ConsumerWidget {
  const PayRentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(_invoicesProvider);
    final phone = ref.watch(authProvider).user?.phone;

    return PageScaffold(
      title: 'Pay rent',
      body: invoices.when(
        data: (list) {
          final open = list.where((e) {
            final inv = e as Map<String, dynamic>;
            final st = '${inv['status'] ?? ''}'.toLowerCase();
            return st != 'paid' && st != 'cancelled' && _num(inv['balance_due']) > 0;
          }).toList();
          if (open.isEmpty) {
            return Center(child: Text('No invoices due.', style: AppTextStyles.bodyMediumOnDark));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: open.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final inv = open[i] as Map<String, dynamic>;
              final due = _num(inv['balance_due']);
              return GlassPanel(
                padding: const EdgeInsets.all(14),
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invoice ${inv['invoice_number'] ?? i + 1}', style: AppTextStyles.bodyMediumOnDark),
                    Text('Due: ${formatUgx(due)}', style: AppTextStyles.captionOnDark.copyWith(color: AppColors.accentGreen)),
                    if (inv['due_date'] != null)
                      Text('Due date: ${inv['due_date']}', style: AppTextStyles.captionOnDark),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => runTenantCheckoutFlow(
                          ref: ref,
                          context: context,
                          invoice: inv,
                          defaultPhone: phone,
                        ),
                        child: const Text('Pay with MTN / Airtel / Card'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGreen)),
        error: (_, __) => Center(
          child: Text('Requires tenant profile linked by landlord.', style: AppTextStyles.captionOnDark),
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
