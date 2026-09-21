import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Grid 2 kolom berisi kartu checkbox untuk jenis pekerjaan yang dicari.
class JobTypeSelector extends StatelessWidget {
  const JobTypeSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 2.6,
      children: options.map((label) {
        final isSelected = selected.contains(label);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onToggle(label),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.segmentBackground : AppColors.inputFill,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                _CheckboxSquare(checked: isSelected),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.badge.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CheckboxSquare extends StatelessWidget {
  const _CheckboxSquare({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: checked ? AppColors.primaryButton : Colors.white,
        borderRadius: BorderRadius.circular(2.5),
        border: checked ? null : Border.all(color: AppColors.checkboxBorder),
      ),
      child: checked
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : null,
    );
  }
}
