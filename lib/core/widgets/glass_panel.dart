import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_theme_extension.dart';

/// Frosted glass card for dark screens (design board).
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final rd = context.rdTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: rd.glassFill,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: rd.glassBorder),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
