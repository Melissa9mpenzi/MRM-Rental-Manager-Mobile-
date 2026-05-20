import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/tenant_api.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/payment_method_sheet.dart';

final _invoicesProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(tenantApiProvider).myInvoices();
});

class PayRentScreen extends ConsumerWidget {
  const PayRentScreen({super.key});

  Future<void> _pay(BuildContext context, Map<String, dynamic> inv) async {
    final method = await showPaymentMethodSheet(context);
    if (method == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${method.label} checkout for invoice ${inv['invoice_number'] ?? ''} will connect to the payment gateway.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(_invoicesProvider);

    return PageScaffold(
      title: 'Pay rent',
      body: invoices.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text('No invoices due.', style: AppTextStyles.bodyMediumOnDark));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final inv = list[i] as Map<String, dynamic>;
              final due = inv['balance_due'] ?? inv['amount_due'] ?? 0;
              return GlassPanel(
                padding: const EdgeInsets.all(14),
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invoice ${inv['invoice_number'] ?? i + 1}', style: AppTextStyles.bodyMediumOnDark),
                    Text('Due: UGX $due', style: AppTextStyles.captionOnDark.copyWith(color: AppColors.accentGreen)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _pay(context, inv),
                        child: const Text('Pay now'),
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
