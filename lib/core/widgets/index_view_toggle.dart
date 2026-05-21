import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

enum IndexViewMode { list, grid }

class IndexViewToggle extends StatelessWidget {
  static const _activeColor = Color(0xFFF39C12);
  static const _borderColor = Color(0xFFE2E8F0);

  final IndexViewMode value;
  final ValueChanged<IndexViewMode> onChanged;

  const IndexViewToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IndexViewToggleButton(
            selected: value == IndexViewMode.list,
            activeColor: _activeColor,
            icon: Icons.format_list_bulleted,
            label: 'قائمة',
            onPressed: () => onChanged(IndexViewMode.list),
          ),
          _IndexViewToggleButton(
            selected: value == IndexViewMode.grid,
            activeColor: _activeColor,
            icon: Icons.grid_view_outlined,
            label: 'شبكة',
            onPressed: () => onChanged(IndexViewMode.grid),
          ),
        ],
      ),
    );
  }
}

class IndexViewControls extends StatelessWidget {
  final IndexViewMode viewMode;
  final ValueChanged<IndexViewMode> onViewModeChanged;

  const IndexViewControls({
    super.key,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: IndexViewToggle(value: viewMode, onChanged: onViewModeChanged),
    );
  }
}

class _IndexViewToggleButton extends StatelessWidget {
  final bool selected;
  final Color activeColor;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _IndexViewToggleButton({
    required this.selected,
    required this.activeColor,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: selected ? null : onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        foregroundColor: selected ? Colors.white : AppColors.onSurface,
        disabledForegroundColor: Colors.white,
        backgroundColor: selected ? activeColor : Colors.transparent,
        disabledBackgroundColor: activeColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
        ),
        textStyle: AppTextStyles.labelStrong,
      ),
    );
  }
}
