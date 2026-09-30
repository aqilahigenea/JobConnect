import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Input teks dengan label di atas dan ikon di kiri.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: width == 0 ? BorderSide.none : BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTextStyles.input,
          cursorColor: AppColors.primaryButton,
          decoration: InputDecoration(
            hintText: hint,
            hintMaxLines: 1,
            hintStyle: AppTextStyles.hint.copyWith(overflow: TextOverflow.ellipsis),
            filled: true,
            fillColor: AppColors.inputFill,
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: AppSizes.controlHeight,
            ),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 15.5,
            ),
            border: _border(Colors.transparent, 0),
            enabledBorder: _border(Colors.transparent, 0),
            focusedBorder: _border(AppColors.primaryButton, 1.5),
          ),
        ),
      ],
    );
  }
}
