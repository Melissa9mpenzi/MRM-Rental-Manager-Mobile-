import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';

enum PaymentMethod { mtn, airtel, visa, sui }

extension PaymentMethodLabel on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.mtn => 'MTN Mobile Money',
        PaymentMethod.airtel => 'Airtel Money',
        PaymentMethod.visa => 'Visa / Card',
        PaymentMethod.sui => 'Sui Wallet',
      };

  IconData get icon => switch (this) {
        PaymentMethod.mtn => Icons.phone_android_rounded,
        PaymentMethod.airtel => Icons.sim_card_outlined,
        PaymentMethod.visa => Icons.credit_card_rounded,
        PaymentMethod.sui => Icons.account_balance_wallet_outlined,
      };
}

Future<PaymentMethod?> showPaymentMethodSheet(BuildContext context) {
  return showModalBottomSheet<PaymentMethod>(
    context: context,
    backgroundColor: AppColors.surfaceDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Choose payment method', style: AppTextStyles.headingMedium),
              const SizedBox(height: 12),
              ...PaymentMethod.values.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.pop(ctx, m),
                      child: GlassPanel(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        borderRadius: 14,
                        child: Row(
                          children: [
                            Icon(m.icon, color: AppColors.accentGreen),
                            const SizedBox(width: 12),
                            Expanded(child: Text(m.label, style: AppTextStyles.bodyMediumOnDark)),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedOnDark),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
