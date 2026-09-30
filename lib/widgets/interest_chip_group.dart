import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Grup chip multi-pilih untuk minat/bidang mahasiswa.
/// Chip terpilih berlatar biru dengan ikon centang; chip lain berlatar netral.
class InterestChipGroup extends StatelessWidget {
  const InterestChipGroup({
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
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((label) {
        final isSelected = selected.contains(label);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onToggle(label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryButton : AppColors.inputFill,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.badge.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(Icons.check, size: 11, color: Colors.white),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
