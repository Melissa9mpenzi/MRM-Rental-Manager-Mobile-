import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';

class WalletTrustCard extends StatelessWidget {
  const WalletTrustCard({super.key, required this.wallet});

  final Map<String, dynamic> wallet;

  @override
  Widget build(BuildContext context) {
    final rep = (wallet['reputation'] as Map?)?.cast<String, dynamic>() ?? {};
    final stats = (rep['stats'] as Map?)?.cast<String, dynamic>() ?? {};
    final score = (rep['score'] as num?)?.toInt() ?? 0;
    final label = rep['label'] as String? ?? 'New';
    final address = wallet['sui_address'] as String?;

    if (score == 0 && address == null) return const SizedBox.shrink();

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFCD34D), size: 18),
              const SizedBox(width: 8),
              Text('Trust score', style: AppTextStyles.headingSmallOnDark),
              const Spacer(),
              Text('$score', style: AppTextStyles.displayHero.copyWith(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.captionOnDark),
          const SizedBox(height: 12),
          Row(
            children: [
              _stat('Listings', stats['properties_on_sui']),
              _stat('Leases', stats['agreements_anchored']),
              _stat('Payments', stats['on_chain_payments']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, dynamic value) {
    final n = (value as num?)?.toInt() ?? 0;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.glassBorder),
          color: AppColors.glassFill,
        ),
        child: Column(
          children: [
            Text('$n', style: AppTextStyles.bodyMediumOnDark.copyWith(fontWeight: FontWeight.w800)),
            Text(label, style: AppTextStyles.captionOnDark.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
