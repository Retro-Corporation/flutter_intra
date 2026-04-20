import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/type/typography.dart';
import '../../icons/app_icons.dart';
import 'icon.dart';
import 'text.dart';
import 'score_badge_types.dart';

/// Atom: displays a numeric score with a colored underline bar.
///
/// Renders what it receives — no domain knowledge about what colors mean.
/// [underlineColor] is resolved by the caller (e.g. molecule) from a domain
/// concept such as ReviewStatus, then passed in here as a raw [Color].
class ScoreBadge extends StatelessWidget {
  final double score;
  final Color underlineColor;
  final ScoreBadgeSize size;
  final ScoreBadgeVariant variant;

  const ScoreBadge({
    super.key,
    required this.score,
    required this.underlineColor,
    this.size = ScoreBadgeSize.md,
    this.variant = ScoreBadgeVariant.plain,
  });

  double get _underlineHeight => switch (size) {
        ScoreBadgeSize.md => AppStroke.xl,
        ScoreBadgeSize.sm => AppStroke.md,
      };

  Widget? _buildTrendIcon() => switch (variant) {
        ScoreBadgeVariant.plain => null,
        ScoreBadgeVariant.trendUp =>
          const AppIcon(AppIcons.trendUpFilled, color: AppColors.brand, size: 16),
        ScoreBadgeVariant.trendDown =>
          const AppIcon(AppIcons.trendDownFilled, color: AppColors.error, size: 16),
      };

  @override
  Widget build(BuildContext context) {
    final trendIcon = _buildTrendIcon();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                score.toStringAsFixed(1),
                style: AppTypography.body.bold,
                color: AppColors.textPrimary,
              ),
              if (size == ScoreBadgeSize.md) const SizedBox(height: AppGrid.grid4),
              Container(height: _underlineHeight, color: underlineColor),
            ],
          ),
        ),
        if (trendIcon != null) ...[
          const SizedBox(width: AppGrid.grid4),
          trendIcon,
        ],
      ],
    );
  }
}
