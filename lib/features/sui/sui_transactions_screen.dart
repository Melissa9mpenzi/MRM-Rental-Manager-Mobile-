import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/features/sui/sui_dashboard_screen.dart';

class SuiTransactionsScreen extends ConsumerWidget {
  const SuiTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(suiDashboardProvider);
    return dash.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
      error: (e, _) => Center(child: Text('$e')),
      data: (d) {
        final rows = (d['recent_transactions'] as List?) ?? [];
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: rows.isEmpty ? 1 : rows.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            if (rows.isEmpty) {
              return Text('No transactions.', style: AppTextStyles.bodyMediumOnDark.copyWith(color: Colors.white54));
            }
            final m = Map<String, dynamic>.from(rows[i] as Map);
            return GlassPanel(
              child: ListTile(
                leading: Icon(Icons.payments_outlined, color: (m['amount_sui'] ?? 0) >= 0 ? const Color(0xFF22C55E) : Colors.white),
                title: Text('${m['type']}', style: AppTextStyles.bodyMediumOnDark),
                subtitle: Text('${m['amount_sui'] ?? 0} SUI', style: AppTextStyles.caption),
                trailing: Text('${m['status']}', style: AppTextStyles.caption.copyWith(color: const Color(0xFF22C55E))),
                onTap: () {
                  final id = m['receipt']?['id'];
                  if (id != null) context.push(RouteNames.suiReceipt(int.parse('$id')));
                },
              ),
            );
          },
        );
      },
    );
  }
}
