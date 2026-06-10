import 'package:flutter/material.dart';

/// RentalMGR brand colors — light & lively theme.
abstract class AppColors {
  // ── Primary Palette ────────────────────────────────────────────
  /// Page / scaffold background
  static const Color pageBg = Color(0xFFFFFFFF);

  /// Card / surface background
  static const Color surface = Color(0xFFFFFFFF);

  /// Primary text
  static const Color textPrimary = Color(0xFF111827);

  /// Secondary / muted text
  static const Color textMuted = Color(0xFF6B7280);

  /// Subtle border
  static const Color border = Color(0xFFE2E8F0);

  /// Brand indigo-blue — CTAs, links, active states
  static const Color primary = Color(0xFF4F6EF7);

  /// Primary light tint
  static const Color primaryLight = Color(0xFFEEF2FF);

  /// Success / paid green
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);

  /// Error / danger
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  /// Warning / arrears
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  // ── Status Colors ──────────────────────────────────────────────
  static const Color statusPaid = success;
  static const Color statusArrears = warning;
  static const Color statusVacant = Color(0xFF9CA3AF);
  static const Color statusMaintenance = error;

  // ── Sidebar / nav colors (dark sidebar on light app) ──────────
  static const Color sidebarBg = Color(0xFF1E293B);
  static const Color sidebarText = Color(0xFFCBD5E1);
  static const Color sidebarActive = Color(0xFF7EB8F7);
  static const Color sidebarBorder = Color(0x14FFFFFF); // white/8

  // ── Opacity helpers ────────────────────────────────────────────
  static Color primaryWith(double opacity) =>
      primary.withValues(alpha: opacity);
  static Color textWith(double opacity) =>
      textPrimary.withValues(alpha: opacity);
  static Color borderWith(double opacity) => border.withValues(alpha: opacity);

  // ── Legacy dark canvas aliases (kept for dark-only areas like auth scaffold) ──
  static const Color canvasDark = Color(0xFF1E293B);
  static const Color surfaceDark = Color(0xFF334155);
  static const Color glassFill = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x14FFFFFF);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color textOnDark = Color(0xFFF8FAFC);
  static const Color textMutedOnDark = Color(0xFF94A3B8);

  // ── Legacy light aliases ────────────────────────────────────────
  static const Color deepCharcoal = Color(0xFF111827);
  static const Color sageSlate = Color(0xFF6B7280);
  static const Color forestTeal = Color(0xFF4F6EF7);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color tealLight = Color(0xFFEEF2FF);

  // ── Back-compat getters used across existing screens ──────────
  static Color get mid => textMuted;
  static Color get brandDark => textPrimary;
}
