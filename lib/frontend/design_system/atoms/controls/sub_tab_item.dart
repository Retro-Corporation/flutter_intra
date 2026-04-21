import 'package:flutter/material.dart';

import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/type/typography.dart';
import '../primitives/text.dart';

class SubTabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback onTap;

  const SubTabItem({
    super.key,
    required this.label,
    required this.isActive,
    this.isEnabled = true,
    required this.onTap,
  });

  Color get _textColor {
    if (!isEnabled) return AppColors.surface;
    if (isActive) return AppColors.textPrimary;
    return AppColors.textSecondary;
  }

  Color get _underlineColor => AppColors.surfaceBorder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppGrid.grid8),
            child: Center(
              child: AppText(
                label,
                style: AppTypography.body.bold,
                color: _textColor,
              ),
            ),
          ),
          Container(
            height: AppStroke.xl,
            decoration: BoxDecoration(
              color: _underlineColor,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        ],
      ),
    );
  }
}
