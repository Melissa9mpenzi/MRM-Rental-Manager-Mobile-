import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/blockchain_api.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/sui/sui_wallet_actions.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';

final suiDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(blockchainApiProvider).dashboard();
});

class SuiDashboardScreen extends ConsumerWidget {
  const SuiDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(suiDashboardProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(suiDashboardProvider),
      child: dash.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
        error: (e, _) => ListView(padding: const EdgeInsets.all(16), children: [Text('Could not load Sui dashboard: $e', style: AppTextStyles.bodyMediumOnDark)]),
        data: (d) {
          final totals = (d['totals'] as Map?)?.cast<String, dynamic>() ?? {};
          final wallet = (d['wallet'] as Map?)?.cast<String, dynamic>() ?? {};
          final recent = (d['recent_transactions'] as List?) ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total balance', style: AppTextStyles.caption.copyWith(color: Colors.white54)),
                    const SizedBox(height: 6),
                    Text(
                      wallet['sui_balance']?.toString() ?? 'Connect wallet',
                      style: AppTextStyles.headingSmallOnDark.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _actionBtn(context, 'Send', Icons.send_rounded, address: wallet['sui_address']?.toString()),
                        const SizedBox(width: 8),
                        _actionBtn(context, 'Receive', Icons.call_received_rounded, address: wallet['sui_address']?.toString()),
                        const SizedBox(width: 8),
                        _actionBtn(context, 'Swap', Icons.swap_horiz_rounded, address: wallet['sui_address']?.toString()),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _statGrid(totals),
              const SizedBox(height: 12),
              Text('Recent transactions', style: AppTextStyles.headingSmallOnDark),
              const SizedBox(height: 8),
              if (recent.isEmpty)
                Text('No on-chain transactions yet.', style: AppTextStyles.bodySmallOnDark.copyWith(color: Colors.white54))
              else
                ...recent.take(6).map((tx) {
                  final m = Map<String, dynamic>.from(tx as Map);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassPanel(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${m['type'] ?? 'Payment'}', style: AppTextStyles.bodyMediumOnDark.copyWith(fontWeight: FontWeight.w700)),
                                Text('${m['amount_sui'] ?? 0} SUI', style: AppTextStyles.caption.copyWith(color: Colors.white54)),
                              ],
                            ),
                          ),
                          if (m['receipt']?['id'] != null)
                            TextButton(
                              onPressed: () => context.push(RouteNames.suiReceipt(int.parse('${m['receipt']['id']}'))),
                              child: const Text('Receipt'),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _actionBtn(BuildContext context, String label, IconData icon, {String? address}) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {
          if (label == 'Send') {
            openWebSuiSend(context);
          } else if (label == 'Receive') {
            showSuiReceiveSheet(context, address: address);
          } else {
            openWebSuiSend(context);
          }
        },
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _statGrid(Map<String, dynamic> totals) {
    final items = [
      ('Transactions', '${totals['transactions'] ?? 0}'),
      ('Volume SUI', '${totals['volume_sui'] ?? 0}'),
      ('Active Escrow', '${totals['active_escrow'] ?? 0}'),
      ('Contracts', '${totals['smart_contracts'] ?? 0}'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: items.map((e) => GlassPanel(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(e.$1, style: AppTextStyles.caption.copyWith(color: Colors.white54, fontSize: 10)),
            Text(e.$2, style: AppTextStyles.titleOnDark.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
      )).toList(),
    );
  }
}
