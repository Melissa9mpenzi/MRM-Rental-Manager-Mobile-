import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/utils/format_ugx.dart';

class DashboardGreeting extends StatelessWidget {
  const DashboardGreeting({
    super.key,
    required this.fullName,
    this.subtitle,
  });

  final String fullName;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final name = firstNameOrFallback(fullName);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $name 👋',
            style: AppTextStyles.headingMedium,
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
