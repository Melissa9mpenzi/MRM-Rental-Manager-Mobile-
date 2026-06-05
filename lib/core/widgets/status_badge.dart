import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';

enum BadgeStatus { paid, arrears, vacant, maintenance, open, inProgress, resolved, low, medium, high, urgent }

/// Status pill badge matching the RentalMGR brand spec
class StatusBadge extends StatelessWidget {
  final BadgeStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _badgeConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config.label,
        style: AppTextStyles.caption.copyWith(
          color: config.fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  _BadgeConfig _badgeConfig(BadgeStatus s) {
    switch (s) {
      case BadgeStatus.paid:
        return _BadgeConfig('Paid', AppColors.forestTeal.withValues(alpha: 0.12), AppColors.forestTeal);
      case BadgeStatus.arrears:
        return _BadgeConfig('Arrears', AppColors.warning.withValues(alpha: 0.12), AppColors.warning);
      case BadgeStatus.vacant:
        return _BadgeConfig('Vacant', AppColors.sageSlate.withValues(alpha: 0.12), AppColors.sageSlate);
      case BadgeStatus.maintenance:
        return _BadgeConfig('Maintenance', AppColors.error.withValues(alpha: 0.12), AppColors.error);
      case BadgeStatus.open:
        return _BadgeConfig('Open', AppColors.warning.withValues(alpha: 0.12), AppColors.warning);
      case BadgeStatus.inProgress:
        return _BadgeConfig('In Progress', AppColors.forestTeal.withValues(alpha: 0.12), AppColors.forestTeal);
      case BadgeStatus.resolved:
        return _BadgeConfig('Resolved', AppColors.success.withValues(alpha: 0.12), AppColors.success);
      case BadgeStatus.low:
        return _BadgeConfig('Low', AppColors.sageSlate.withValues(alpha: 0.12), AppColors.sageSlate);
      case BadgeStatus.medium:
        return _BadgeConfig('Medium', AppColors.warning.withValues(alpha: 0.12), AppColors.warning);
      case BadgeStatus.high:
        return _BadgeConfig('High', AppColors.error.withValues(alpha: 0.12), AppColors.error);
      case BadgeStatus.urgent:
        return const _BadgeConfig('Urgent', AppColors.error, AppColors.pureWhite);
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color bg;
  final Color fg;
  const _BadgeConfig(this.label, this.bg, this.fg);
}
