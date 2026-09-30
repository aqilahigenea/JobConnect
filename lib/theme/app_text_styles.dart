import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Gaya teks: Plus Jakarta Sans untuk judul, Inter untuk sisanya.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _inter(
    double size,
    double lineHeight,
    FontWeight weight,
    Color color, {
    double letterSpacing = 0,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle get heading => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: AppColors.textPrimary,
      );

  static TextStyle get subtitle =>
      _inter(14, 20, FontWeight.w400, AppColors.textSecondary);

  static TextStyle get badge =>
      _inter(11, 14, FontWeight.w600, AppColors.primary, letterSpacing: 0.22);

  static TextStyle get tab =>
      _inter(14, 20, FontWeight.w600, AppColors.textSecondary, letterSpacing: 0.14);

  static TextStyle get notice =>
      _inter(12, 16, FontWeight.w400, AppColors.textSecondary);

  static TextStyle get label =>
      _inter(12, 16, FontWeight.w600, AppColors.textPrimary, letterSpacing: 0.12);

  static TextStyle get input =>
      _inter(14, 17, FontWeight.w400, AppColors.textPrimary);

  static TextStyle get hint =>
      _inter(14, 17, FontWeight.w400, AppColors.textHint);

  static TextStyle get checkboxLabel =>
      _inter(12, 16, FontWeight.w500, AppColors.textPrimary);

  static TextStyle get link =>
      _inter(11, 14, FontWeight.w600, AppColors.primary, letterSpacing: 0.22);

  static TextStyle get button =>
      _inter(14, 20, FontWeight.w600, Colors.white, letterSpacing: 0.14);

  static TextStyle get altButton =>
      _inter(12, 16, FontWeight.w600, AppColors.textPrimary, letterSpacing: 0.12);

  static TextStyle get dividerText =>
      _inter(11, 14, FontWeight.w500, AppColors.textSecondary, letterSpacing: 0.22);

  static TextStyle get footer =>
      _inter(14, 20, FontWeight.w400, AppColors.textSecondary);

  static TextStyle get footerLink =>
      _inter(12, 16, FontWeight.w600, AppColors.primary, letterSpacing: 0.12);

  static TextStyle get ribbon => _inter(
        11,
        14,
        FontWeight.w600,
        AppColors.textHint.withValues(alpha: 0.7),
        letterSpacing: 0.275,
      );
}
