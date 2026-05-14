import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_theme.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';

enum AppButtonVariant { filled, outlined, danger }

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
    final bool isFilled = variant == AppButtonVariant.filled;
    final bool isDanger = variant == AppButtonVariant.danger;

    final Color bgColor = isDanger
        ? AppColors.error
        : isFilled
            ? AppColors.forestTeal
            : Colors.transparent;

    final Color fgColor =
        isFilled || isDanger ? AppColors.pureWhite : AppColors.forestTeal;

    final BorderSide border = isFilled || isDanger
        ? BorderSide.none
        : const BorderSide(color: AppColors.forestTeal, width: 2);

    return SizedBox(
      width: width ?? double.infinity,
      height: 50,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            disabledBackgroundColor: bgColor.withOpacity(0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: border,
            ),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: fgColor,
                  ),
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
                      label.toUpperCase(),
                      style: AppTextStyles.buttonLabel.copyWith(color: fgColor),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
