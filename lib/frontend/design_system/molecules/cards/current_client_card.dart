import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/type/typography.dart';
import '../../atoms/behaviors/pressable_surface.dart';
import '../../atoms/primitives/score_badge.dart';
import '../../atoms/primitives/text.dart';
import 'current_client_card_types.dart';

/// Molecule: a tappable client card for the "Current clients" list.
///
/// Composes [AppText] atoms, [ScoreBadge] atom, and [PressableSurface] atom
/// behavior into a single interactive card. [PressableSurface] owns all press
/// state — this widget is pure composition with zero state.
///
/// [ReviewStatus] is resolved to a [Color] once via [_statusColor] and passed
/// to both [PressableSurface.borderColor] and [ScoreBadge.underlineColor],
/// guaranteeing they always match.
class CurrentClientCard extends StatelessWidget {
  final String clientName;
  final String lastSessionText;
  final double score;
  final ReviewStatus status;
  final VoidCallback onTap;

  const CurrentClientCard({
    super.key,
    required this.clientName,
    required this.lastSessionText,
    required this.score,
    required this.status,
    required this.onTap,
  });

  Color _statusColor(ReviewStatus status) => switch (status) {
    ReviewStatus.urgent        => AppColors.brand,
    ReviewStatus.pendingReview => AppColors.textPrimary,
    ReviewStatus.reviewed      => AppColors.surfaceBorder,
  };

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);

    return PressableSurface(
      backgroundColor: AppColors.surface,
      borderColor: statusColor,
      borderRadius: AppRadius.sm,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppPadding.cardPadding,
          AppPadding.rem05,
          AppPadding.cardPadding,
          AppPadding.rem05,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    clientName,
                    style: AppTypography.body.bold,
                    color: AppColors.textPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppText(
                    lastSessionText,
                    style: AppTypography.bodySmall.regular,
                    color: AppColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppGrid.grid16),
            ScoreBadge(score: score, underlineColor: statusColor),
          ],
        ),
      ),
    );
  }
}
