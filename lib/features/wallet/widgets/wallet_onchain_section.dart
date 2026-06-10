import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/config/sui_config.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/utils/format_ugx.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletOnchainSection extends StatelessWidget {
  const WalletOnchainSection({
    super.key,
    required this.receipts,
    required this.escrows,
  });

  final List<dynamic> receipts;
  final List<dynamic> escrows;

  @override
  Widget build(BuildContext context) {
    if (receipts.isEmpty && escrows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (receipts.isNotEmpty) ...[
          Text('On-chain receipts', style: AppTextStyles.headingMedium),
          const SizedBox(height: 8),
          ...receipts.take(3).map((r) {
            final m = Map<String, dynamic>.from(r as Map);
            final digest = m['tx_digest'] as String? ?? m['receipt_hash'] as String? ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassPanel(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.verified_outlined, color: Color(0xFFA78BFA), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatUgx(_num(m['amount_ugx'])),
                            style: AppTextStyles.bodyMediumOnDark.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${m['payment_method'] ?? 'sui'} · ${_shortHash(digest)}',
                            style: AppTextStyles.captionOnDark,
                          ),
                        ],
                      ),
                    ),
                    if (digest.isNotEmpty)
                      IconButton(
                        tooltip: 'Explorer',
                        icon: Icon(Icons.open_in_new, size: 18, color: AppColors.textMutedOnDark),
                        onPressed: () => _openExplorer(digest),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
        if (escrows.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Escrow', style: AppTextStyles.headingMedium),
          const SizedBox(height: 8),
          ...escrows.take(2).map((e) {
            final m = Map<String, dynamic>.from(e as Map);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassPanel(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Color(0xFF67E8F9), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m['status']?.toString() ?? 'Active',
                            style: AppTextStyles.bodyMediumOnDark.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            formatUgx(_num(m['amount_ugx'])),
                            style: AppTextStyles.captionOnDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Future<void> _openExplorer(String digest) async {
    final url = Uri.parse(SuiConfig.txUrl(digest));
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  String _shortHash(String h) {
    if (h.length <= 12) return h;
    return '${h.substring(0, 6)}…${h.substring(h.length - 4)}';
  }
}

num _num(dynamic v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? 0;
  return 0;
}
