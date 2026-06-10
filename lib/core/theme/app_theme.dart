import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_theme_extension.dart';

export 'package:rental_mgr_mobile/core/theme/app_colors.dart';
export 'package:rental_mgr_mobile/core/theme/app_theme_extension.dart';

class AppTheme {
  /// Light theme — default app shell (light & lively)
  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        extension: RentDirectThemeExtension.light,
        primary: AppColors.primary,
        scaffold: Colors.white,
        onSurface: AppColors.textPrimary,
        muted: AppColors.textMuted,
        surfaceColor: AppColors.surface,
        borderColor: AppColors.border,
      );

  /// Dark theme — used for auth & blockchain portal
  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        extension: RentDirectThemeExtension.dark,
        primary: AppColors.accentGreen,
        scaffold: Colors.white, // Force white background
        onSurface:
            AppColors.brandDark, // Force dark text for readability on white
        muted: AppColors.textMuted,
        surfaceColor: Colors.white,
        borderColor: const Color(0x1AFFFFFF),
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required RentDirectThemeExtension extension,
    required Color primary,
    required Color scaffold,
    required Color onSurface,
    required Color muted,
    required Color surfaceColor,
    required Color borderColor,
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
              surface: surfaceColor,
              onSurface: onSurface,
              error: AppColors.error,
              onError: Colors.white,
            )
          : ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              surface: surfaceColor,
              onSurface: onSurface,
              error: AppColors.error,
              onError: Colors.white,
            ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.brandDark,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.brandDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.brandDark),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: muted, fontSize: 14),
        labelStyle: GoogleFonts.inter(
          color: isDark ? AppColors.textMutedOnDark : AppColors.textMuted,
          fontSize: 12,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: borderColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor),
        ),
        margin: const EdgeInsets.all(0),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
