import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Tombol utama (aksi terpenting di satu layar).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.controlHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          foregroundColor: Colors.white,
          elevation: 1,
          shadowColor: const Color(0x0D000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.button),
            if (trailingIcon != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(trailingIcon, size: 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
