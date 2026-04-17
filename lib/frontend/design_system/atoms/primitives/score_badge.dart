import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/type/typography.dart';
import 'text.dart';

/// Atom: displays a numeric score with a colored underline bar.
///
/// Renders what it receives — no domain knowledge about what colors mean.
/// [underlineColor] is resolved by the caller (e.g. molecule) from a domain
/// concept such as ReviewStatus, then passed in here as a raw [Color].
class ScoreBadge extends StatelessWidget {
  final double score;
  final Color underlineColor;

  const ScoreBadge({
    super.key,
    required this.score,
    required this.underlineColor,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            score.toString(),
            style: AppTypography.bodyLarge.bold.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Container(height: AppStroke.lg, color: underlineColor),
        ],
      ),
    );
  }
}
