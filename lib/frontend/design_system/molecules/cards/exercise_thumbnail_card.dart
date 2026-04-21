import 'package:flutter/widgets.dart';
import '../../atoms/behaviors/pressable_surface.dart';
import '../../atoms/primitives/text.dart';
import '../../atoms/primitives/thumbnail.dart';
import '../../atoms/primitives/thumbnail_types.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/type/typography.dart';
import 'exercise_thumbnail_card_types.dart';

/// Molecule: a tappable thumbnail card for the Add Exercise page.
///
/// Composes [Thumbnail] (placeholder image area) and [AppText] (label for the
/// large variant) inside a [PressableSurface] that owns the press animation
/// and draws the border.
///
/// Selection is expressed by flipping the border color only:
/// - unselected → [AppColors.surfaceBorder]
/// - selected   → [AppColors.textPrimary]
///
/// [selected] is passed in by the parent — this widget never tracks it. Cross-
/// card selection state belongs to the organism or template that composes
/// many cards.
class ExerciseThumbnailCard extends StatelessWidget {
  /// Size variant. [ExerciseThumbnailCardSize.small] hides the label;
  /// [ExerciseThumbnailCardSize.large] shows it.
  final ExerciseThumbnailCardSize size;

  /// Label rendered below the thumbnail. Only valid when [size] is
  /// [ExerciseThumbnailCardSize.large].
  final String? label;

  /// Whether this card is currently selected. Flips the border color.
  final bool selected;

  /// Optional tap callback. When null, the card is non-interactive.
  final VoidCallback? onTap;

  const ExerciseThumbnailCard({
    super.key,
    required this.size,
    this.label,
    this.selected = false,
    this.onTap,
  }) : assert(
         size == ExerciseThumbnailCardSize.large || label == null,
         'label is only rendered when size is ExerciseThumbnailCardSize.large',
       );

  ThumbnailSize get _thumbnailSize => switch (size) {
    ExerciseThumbnailCardSize.small => ThumbnailSize.size100,
    ExerciseThumbnailCardSize.large => ThumbnailSize.size128,
  };

  @override
  Widget build(BuildContext context) {
    final surface = PressableSurface(
      backgroundColor: AppColors.grey800,
      borderColor: selected
          ? AppColors.textPrimary
          : AppColors.surfaceBorder,
      borderRadius: AppRadius.sm,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.rem075),
        child: Thumbnail(size: _thumbnailSize),
      ),
    );

    if (size == ExerciseThumbnailCardSize.small || label == null) {
      return surface;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        surface,
        const SizedBox(height: AppGrid.grid8),
        SizedBox(
          width: AppGrid.grid128,
          child: AppText(
            label!,
            style: AppTypography.body.bold,
            color: AppColors.textPrimary,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
