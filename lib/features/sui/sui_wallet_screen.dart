import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/blockchain_api.dart';
import 'package:rental_mgr_mobile/core/sui/sui_wallet_actions.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';

final suiWalletProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(blockchainApiProvider).myWallet();
});

class SuiWalletScreen extends ConsumerWidget {
  const SuiWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(suiWalletProvider);
    return walletAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
      error: (e, _) => Center(child: Text('$e')),
      data: (wallet) {
        final address = wallet['sui_address']?.toString();
        final balance = wallet['sui_balance']?.toString() ?? '—';
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SUI balance', style: AppTextStyles.caption.copyWith(color: Colors.white54)),
                  const SizedBox(height: 6),
                  Text(
                    balance,
                    style: AppTextStyles.headingSmallOnDark.copyWith(fontWeight: FontWeight.w800),
                  ),
                  if (address != null && address.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(color: Colors.white38, fontFamily: 'monospace'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => openWebSuiSend(context),
                          child: const Text('Send'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => showSuiReceiveSheet(context, address: address),
                          child: const Text('Receive'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Tokens', style: AppTextStyles.headingSmallOnDark),
            const SizedBox(height: 8),
            _token('SUI', balance),
            _token('Escrow', '${wallet['escrow_balance'] ?? 0} SUI'),
          ],
        );
      },
    );
  }

  Widget _token(String sym, String bal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        child: ListTile(
          title: Text(sym, style: AppTextStyles.bodyMediumOnDark.copyWith(fontWeight: FontWeight.w700)),
          trailing: Text(bal, style: AppTextStyles.bodyMediumOnDark),
        ),
      ),
    );
  }
}
