import 'package:flutter/material.dart';

/// Theme-aware RentDirect surfaces (light + dark).
@immutable
class RentDirectThemeExtension extends ThemeExtension<RentDirectThemeExtension> {
  const RentDirectThemeExtension({
    required this.canvas,
    required this.surface,
    required this.glassFill,
    required this.glassBorder,
    required this.textPrimary,
    required this.textMuted,
  });

  final Color canvas;
  final Color surface;
  final Color glassFill;
  final Color glassBorder;
  final Color textPrimary;
  final Color textMuted;

  static const dark = RentDirectThemeExtension(
    canvas: Color(0xFF060A0C),
    surface: Color(0xFF10181C),
    glassFill: Color(0x1AFFFFFF),
    glassBorder: Color(0x33FFFFFF),
    textPrimary: Color(0xFFF8FAFC),
    textMuted: Color(0xFF94A3B8),
  );

  static const light = RentDirectThemeExtension(
    canvas: Color(0xFFF4F7F7),
    surface: Color(0xFFFFFFFF),
    glassFill: Color(0xE6FFFFFF),
    glassBorder: Color(0x33161D23),
    textPrimary: Color(0xFF161D23),
    textMuted: Color(0xFF576E6A),
  );

  @override
  RentDirectThemeExtension copyWith({
    Color? canvas,
    Color? surface,
    Color? glassFill,
    Color? glassBorder,
    Color? textPrimary,
    Color? textMuted,
  }) {
    return RentDirectThemeExtension(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      glassFill: glassFill ?? this.glassFill,
      glassBorder: glassBorder ?? this.glassBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  @override
  RentDirectThemeExtension lerp(ThemeExtension<RentDirectThemeExtension>? other, double t) {
    if (other is! RentDirectThemeExtension) return this;
    return RentDirectThemeExtension(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}

extension RentDirectThemeContext on BuildContext {
  RentDirectThemeExtension get rdTheme =>
      Theme.of(this).extension<RentDirectThemeExtension>() ?? RentDirectThemeExtension.dark;
}
