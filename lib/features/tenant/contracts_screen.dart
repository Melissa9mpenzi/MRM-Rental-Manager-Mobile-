import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/tenant_api.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

final _leaseProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.watch(tenantApiProvider).myLease();
});

class ContractsScreen extends ConsumerWidget {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lease = ref.watch(_leaseProvider);

    return PageScaffold(
      title: 'My contracts',
      body: lease.when(
        data: (l) {
          if (l == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No active lease linked to your account yet. Your landlord can invite you from the web app.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMediumOnDark,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active lease', style: AppTextStyles.headingMedium),
                    const SizedBox(height: 12),
                    _row('Property', '${l['property_name'] ?? '—'}'),
                    _row('Unit', '${l['unit_number'] ?? '—'}'),
                    _row('Rent', 'UGX ${l['rent_amount'] ?? '—'}'),
                    _row('Start', '${l['start_date'] ?? '—'}'),
                    _row('End', '${l['end_date'] ?? '—'}'),
                    _row('Status', '${l['status'] ?? '—'}'),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Tenant lease API: ${e.toString()}', style: AppTextStyles.captionOnDark)),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: AppTextStyles.captionOnDark),
            Flexible(child: Text(v, style: AppTextStyles.bodyMediumOnDark, textAlign: TextAlign.end)),
          ],
        ),
      );
}
