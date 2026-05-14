import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonType type;
  final double? width;
  final double height;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.type = ButtonType.primary,
    this.width,
    this.height = 48,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(icon), const SizedBox(width: 8), Text(text)],
          )
        : Text(text);

    switch (type) {
      case ButtonType.primary:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading || !isEnabled ? null : onPressed,
            child: child,
          ),
        );
      case ButtonType.secondary:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: OutlinedButton(
            onPressed: isLoading || !isEnabled ? null : onPressed,
            child: child,
          ),
        );
      case ButtonType.tertiary:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: TextButton(
            onPressed: isLoading || !isEnabled ? null : onPressed,
            child: child,
          ),
        );
    }
  }
}

enum ButtonType { primary, secondary, tertiary }
