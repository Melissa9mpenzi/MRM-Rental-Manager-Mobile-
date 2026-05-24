import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rental_mgr_mobile/core/api/blockchain_api.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';

class SuiReceiptScreen extends ConsumerWidget {
  const SuiReceiptScreen({super.key, required this.receiptId});

  final int receiptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipt = ref.watch(FutureProvider((r) => r.watch(blockchainApiProvider).receipt(receiptId)));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1423),
        title: Text('Blockchain Receipt', style: AppTextStyles.titleOnDark),
      ),
      body: receipt.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
        error: (e, _) => Center(child: Text('$e')),
        data: (d) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Receipt ID', '${d['receipt_id'] ?? d['id']}'),
                  _row('Type', '${d['type'] ?? 'Payment'}'),
                  _row('Related To', '${d['related_to'] ?? 'Rent Payment'}'),
                  _row('Amount UGX', '${d['amount_ugx'] ?? '—'}'),
                  _row('TX Hash', '${d['tx_digest'] ?? '—'}'),
                  _row('Date', '${(d['created_at'] ?? '').toString().substring(0, 16)}'),
                  const SizedBox(height: 12),
                  if (d['explorer_url'] != null)
                    FilledButton(
                      onPressed: () => launchUrl(Uri.parse('${d['explorer_url']}')),
                      child: const Text('View on Sui Explorer'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(k, style: AppTextStyles.caption.copyWith(color: Colors.white54))),
          Expanded(child: Text(v, style: AppTextStyles.bodySmallOnDark)),
        ],
      ),
    );
  }
}
