import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';

/// Inter + Poppins text styles — light theme.
abstract class AppTextStyles {
  static TextStyle get displayHero => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingLarge => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingMedium => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingSmall => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      );

  static TextStyle get inputPlaceholder => GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textMuted.withValues(alpha: 0.7),
      );

  static TextStyle get amountMedium => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get buttonLabel => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  // ── Dark surface variants ────────────────────────────────────
  static TextStyle get bodyMediumOnDark => bodyMedium.copyWith(
        color: AppColors.textOnDark,
      );

  static TextStyle get bodySmallOnDark => bodySmall.copyWith(
        color: AppColors.textMutedOnDark,
      );

  static TextStyle get headingSmallOnDark => headingSmall.copyWith(
        color: AppColors.textOnDark,
      );

  static TextStyle get titleOnDark => headingMedium.copyWith(
        color: AppColors.textOnDark,
      );

  static TextStyle get captionOnDark => caption.copyWith(
        color: AppColors.textMutedOnDark,
      );

  static TextStyle get displayHeroOnDark => displayHero.copyWith(
        color: AppColors.textOnDark,
      );
}
