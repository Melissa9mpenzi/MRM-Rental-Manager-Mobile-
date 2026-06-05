import 'package:flutter/material.dart';

/// RentalMGR brand colors — mirrors the web design system exactly.
/// Never introduce new colors. Extend using opacity only.
abstract class AppColors {
  // ── Primary Palette ────────────────────────────────────────────
  /// Deep Charcoal — navbars, sidebars, dark cards, primary BG
  static const Color deepCharcoal = Color(0xFF161D23);

  /// Sage Slate — body text, secondary labels, muted elements
  static const Color sageSlate = Color(0xFF576E6A);

  /// Forest Teal — CTAs, links, highlights, active states
  static const Color forestTeal = Color(0xFF5E8D83);

  /// Pure White — page backgrounds, cards, modals, input fields
  static const Color pureWhite = Color(0xFFFFFFFF);

  // ── Derived Palette ────────────────────────────────────────────
  /// Light teal — hover states, light panel backgrounds
  static const Color tealLight = Color(0xFFD4E8E5);

  /// Page background
  static const Color pageBg = Color(0xFFF4F7F7);

  // ── Status Colors ──────────────────────────────────────────────
  /// Paid badge — teal
  static const Color statusPaid = forestTeal;

  /// Arrears badge — amber
  static const Color statusArrears = Color(0xFFF59E0B);

  /// Vacant badge — mid-gray
  static const Color statusVacant = sageSlate;

  /// Maintenance badge — red
  static const Color statusMaintenance = Color(0xFFEF4444);

  /// Success
  static const Color success = Color(0xFF10B981);

  /// Error
  static const Color error = Color(0xFFEF4444);

  /// Warning
  static const Color warning = Color(0xFFF59E0B);

  // ── Opacity helpers ────────────────────────────────────────────
  static Color tealWith(double opacity) => forestTeal.withValues(alpha: opacity);
  static Color slateWith(double opacity) => sageSlate.withValues(alpha: opacity);
  static Color charcoalWith(double opacity) => deepCharcoal.withValues(alpha: opacity);

  // ── RentDirect mobile (dark / glass) ───────────────────────────
  static const Color canvasDark = Color(0xFF060A0C);
  static const Color surfaceDark = Color(0xFF10181C);
  static const Color glassFill = Color(0x1AFFFFFF);
  /// Design board primary emerald (#22C55E)
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color textOnDark = Color(0xFFF8FAFC);
  static const Color textMutedOnDark = Color(0xFF94A3B8);
}
