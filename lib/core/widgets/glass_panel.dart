import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_theme_extension.dart';

/// Card panel that adapts to light/dark context.
/// On dark scaffolds (auth) it uses a semi-transparent fill.
/// On light scaffolds it renders as a clean white card.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 16.0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final rd = context.rdTheme;

    final Color fill = brightness == Brightness.dark
        ? rd.glassFill
        : AppColors.surface;

    final Color border = brightness == Brightness.dark
        ? rd.glassBorder
        : AppColors.border;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border),
        boxShadow: brightness == Brightness.light
            ? [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
