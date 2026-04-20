import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/motion/curves.dart';

/// Atom: horizontal row of tappable position indicator dots.
///
/// Renders [count] dots. The dot at [currentIndex] is shown as an
/// animated pill (active); all others are small circles (inactive).
/// Exactly one dot is active at a time — parent owns [currentIndex].
/// Tapping any dot fires [onJump] with the tapped index.
class DotIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final ValueChanged<int> onJump;

  const DotIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.onJump,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == currentIndex;
        return Padding(
          padding: EdgeInsets.only(right: i < count - 1 ? AppGrid.grid8 : 0),
          child: GestureDetector(
            onTap: () => onJump(i),
            child: AnimatedContainer(
              duration: AppDurations.toggle,
              curve: AppCurves.toggle,
              width: isActive ? AppGrid.grid16 : AppGrid.grid8,
              height: AppGrid.grid8,
              decoration: BoxDecoration(
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        );
      }),
    );
  }
}
