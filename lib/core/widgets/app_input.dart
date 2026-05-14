import 'package:flutter/material.dart';
import 'package:mobile_tenant/core/theme/app_colors.dart';
import 'package:mobile_tenant/core/theme/app_text_styles.dart';

/// Labelled text input matching the RentalMGR brand spec.
/// Always shows label above the input. Supports error state and prefix icons.
class AppInput extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;

  const AppInput({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixWidget,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.deepCharcoal,
          fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          maxLines: maxLines,
          enabled: enabled,
          textInputAction: textInputAction,
          focusNode: focusNode,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.deepCharcoal,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.inputPlaceholder,
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: AppColors.sageSlate)
                : null,
            suffix: suffixWidget,
            filled: true,
            fillColor: enabled ? AppColors.pureWhite : AppColors.pageBg,
          ),
        ),
      ],
    );
  }
}
