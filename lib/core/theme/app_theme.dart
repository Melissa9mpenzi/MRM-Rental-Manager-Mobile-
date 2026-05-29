import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_theme_extension.dart';

export 'package:rental_mgr_mobile/core/theme/app_colors.dart';
export 'package:rental_mgr_mobile/core/theme/app_theme_extension.dart';

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        extension: RentDirectThemeExtension.light,
        primary: AppColors.forestTeal,
        scaffold: AppColors.pageBg,
        onSurface: AppColors.deepCharcoal,
        muted: AppColors.sageSlate,
        glassFill: RentDirectThemeExtension.light.glassFill,
        glassBorder: RentDirectThemeExtension.light.glassBorder,
      );

  /// RentDirect-style dark app shell (glass + green accents).
  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        extension: RentDirectThemeExtension.dark,
        primary: AppColors.accentGreen,
        scaffold: AppColors.canvasDark,
        onSurface: AppColors.textOnDark,
        muted: AppColors.textMutedOnDark,
        glassFill: AppColors.glassFill,
        glassBorder: AppColors.glassBorder,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required RentDirectThemeExtension extension,
    required Color primary,
    required Color scaffold,
    required Color onSurface,
    required Color muted,
    required Color glassFill,
    required Color glassBorder,
  }) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
    );
    return base.copyWith(
      extensions: [extension],
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primary,
              onPrimary: Colors.white,
              surface: extension.surface,
              onSurface: onSurface,
              error: AppColors.error,
              onError: Colors.white,
            )
          : ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              surface: extension.surface,
              onSurface: onSurface,
              error: AppColors.error,
              onError: Colors.white,
            ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: muted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: muted, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: BorderSide(color: glassBorder),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: glassBorder, width: 1.5),
      ),
    );
  }
}
