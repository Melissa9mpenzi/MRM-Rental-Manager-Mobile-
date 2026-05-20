import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';

/// Shows progress through the 10-screen signup flow (design board).
class AuthFlowStepper extends StatelessWidget {
  const AuthFlowStepper({super.key, required this.step, this.total = 10});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = step / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Step $step of $total', style: AppTextStyles.captionOnDark),
            Text('${(progress * 100).round()}%', style: AppTextStyles.captionOnDark.copyWith(color: AppColors.accentGreen)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.glassBorder,
            color: AppColors.accentGreen,
          ),
        ),
      ],
    );
  }
}
