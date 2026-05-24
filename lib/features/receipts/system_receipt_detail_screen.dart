import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/receipts_api.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class SystemReceiptDetailScreen extends ConsumerWidget {
  const SystemReceiptDetailScreen({super.key, required this.receiptId});
  final int receiptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_receiptProvider(receiptId));

    return Scaffold(
      backgroundColor: AppColors.deepCharcoal,
      appBar: AppBar(
        backgroundColor: AppColors.deepCharcoal,
        title: Text('Payment receipt', style: AppTextStyles.titleOnDark),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGreen)),
        error: (e, _) => Center(child: Text('Could not load receipt: $e', style: AppTextStyles.bodyMediumOnDark)),
        data: (r) => _ReceiptBody(receipt: r),
      ),
    );
  }
}

final _receiptProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, id) async {
  return ref.read(receiptsApiProvider).get(id);
});

class _ReceiptBody extends StatelessWidget {
  const _ReceiptBody({required this.receipt});
  final Map<String, dynamic> receipt;

  @override
  Widget build(BuildContext context) {
    final status = '${receipt['status'] ?? 'paid'}'.toUpperCase();
    final verifyUrl = receipt['verification_url'] as String?;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [AppColors.accentGreen.withValues(alpha: 0.15), const Color(0xFF8B5CF6).withValues(alpha: 0.08)],
            ),
            border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Text(status, style: AppTextStyles.caption.copyWith(color: AppColors.accentGreen, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('${receipt['receipt_number']}', style: AppTextStyles.headingSmallOnDark.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                '${receipt['currency'] ?? 'UGX'} ${(receipt['amount'] as num?)?.toStringAsFixed(0) ?? '0'}',
                style: AppTextStyles.headingLarge.copyWith(color: AppColors.accentGreen),
              ),
              if (receipt['smart_summary'] != null) ...[
                const SizedBox(height: 12),
                Text('${receipt['smart_summary']}', textAlign: TextAlign.center, style: AppTextStyles.bodySmallOnDark),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (verifyUrl != null)
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: verifyUrl));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification link copied')));
                  }
                },
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('Copy verify link'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.accentGreen, foregroundColor: AppColors.deepCharcoal),
              ),
            if (receipt['explorer_url'] != null)
              OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse('${receipt['explorer_url']}')),
                icon: const Icon(Icons.link, size: 18),
                label: const Text('Blockchain'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _section('Property', [
          _row('Property', receipt['property_name']),
          _row('Tenant', receipt['tenant_name']),
          _row('Period', receipt['period_label']),
        ]),
        _section('Payment', [
          _row('Method', receipt['payment_method']),
          _row('Reference', receipt['transaction_reference']),
        ]),
        if (receipt['tx_hash'] != null)
          _section('Blockchain', [
            _row('TX hash', receipt['tx_hash']),
            _row('Walrus', receipt['walrus_blob_id']),
          ]),
      ],
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.accentGreen, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String k, dynamic v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(k, style: AppTextStyles.caption.copyWith(color: Colors.white54))),
          Expanded(child: Text('${v ?? '—'}', style: AppTextStyles.bodySmallOnDark)),
        ],
      ),
    );
  }
}
