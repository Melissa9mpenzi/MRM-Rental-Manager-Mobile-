import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';

enum AppButtonVariant { filled, outlined, danger, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled = variant == AppButtonVariant.filled;
    final isDanger = variant == AppButtonVariant.danger;
    final isGhost = variant == AppButtonVariant.ghost;

    final Color bgColor;
    final Color fgColor;
    final BorderSide border;

    if (isDanger) {
      bgColor = AppColors.error;
      fgColor = Colors.white;
      border = BorderSide.none;
    } else if (isFilled) {
      bgColor = AppColors.primary;
      fgColor = Colors.white;
      border = BorderSide.none;
    } else if (isGhost) {
      bgColor = AppColors.primaryLight;
      fgColor = AppColors.primary;
      border = BorderSide(color: AppColors.primary.withValues(alpha: 0.3));
    } else {
      // outlined
      bgColor = Colors.transparent;
      fgColor = AppColors.primary;
      border = BorderSide(color: AppColors.primary, width: 1.5);
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.55),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: border,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: fgColor),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: fgColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.buttonLabel.copyWith(color: fgColor),
                  ),
                ],
              ),
      ),
    );
  }
}
