import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/payments/payment_method_config.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/payment_method_icon.dart';

export 'package:rental_mgr_mobile/core/payments/payment_method_config.dart' show AppPaymentMethod;

Future<AppPaymentMethod?> showPaymentMethodSheet(BuildContext context) {
  return showModalBottomSheet<AppPaymentMethod>(
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
              ...AppPaymentMethod.tenantCheckout.map(
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
                            PaymentMethodIcon(method: m, size: 40),
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
