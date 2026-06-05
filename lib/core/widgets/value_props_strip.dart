import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';

/// Footer value props strip
class ValuePropsStrip extends StatelessWidget {
  const ValuePropsStrip({super.key});

  static const _items = [
    (Icons.verified_user_outlined, 'Verified'),
    (Icons.lock_outline, 'Secure'),
    (Icons.payments_outlined, 'Payments'),
    (Icons.support_agent_outlined, '24/7'),
    (Icons.auto_awesome_outlined, 'AI'),
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final iconColor = brightness == Brightness.dark
        ? AppColors.sidebarActive
        : AppColors.primary;
    final textStyle = brightness == Brightness.dark
        ? AppTextStyles.captionOnDark.copyWith(fontSize: 9)
        : AppTextStyles.caption.copyWith(fontSize: 9);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _items
          .map(
            (e) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(e.$1, size: 18, color: iconColor),
                const SizedBox(height: 4),
                Text(e.$2, style: textStyle),
              ],
            ),
          )
          .toList(),
    );
  }
}
