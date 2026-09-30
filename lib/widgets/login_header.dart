import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Bagian atas halaman: logo, badge kategori (opsional), judul, dan subjudul.
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key, this.showCategoryChips = true});

  /// Halaman Masuk menampilkan chip kategori; halaman Daftar tidak (sesuai desain Figma).
  final bool showCategoryChips;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _AppLogo(),
        const SizedBox(height: AppSpacing.lg),
        if (showCategoryChips) ...[
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              _CategoryChip(
                label: 'Magang',
                background: AppColors.badgeBlueBg,
                foreground: AppColors.primary,
                showDot: true,
              ),
              _CategoryChip(
                label: 'Part-Time',
                background: AppColors.badgeBlueBg,
                foreground: AppColors.badgeBlueText,
              ),
              _CategoryChip(
                label: 'Freelance',
                background: AppColors.badgeTealBg,
                foreground: AppColors.badgeTealText,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Text(
          'Selamat Datang di JobConnect',
          textAlign: TextAlign.center,
          style: AppTextStyles.heading,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Temukan peluang kerja yang sesuai denganmu',
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle,
        ),
      ],
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.logoAura,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33004AC6),
              blurRadius: 6,
              offset: Offset(0, 4),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryButton,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          // Ganti dengan Image.asset(...) kalau logo sudah diekspor dari Figma.
          child: const Icon(Icons.work_outline, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.background,
    required this.foreground,
    this.showDot = false,
  });

  final String label;
  final Color background;
  final Color foreground;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(label, style: AppTextStyles.badge.copyWith(color: foreground)),
        ],
      ),
    );
  }
}
