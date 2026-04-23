import 'package:flutter/material.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/motion/curves.dart';
import '../../atoms/primitives/thumbnail.dart';
import '../../atoms/primitives/thumbnail_types.dart';
import '../../atoms/primitives/dot_indicator.dart';
import '../../atoms/primitives/media_holder.dart';
import '../../atoms/primitives/media_holder_types.dart';
import 'exercise_flow_carousel_types.dart';

/// Half of [AppGrid.grid12]: each slot contributes this on each touching side,
/// creating exactly [AppGrid.grid12] (12px) of gap between adjacent slots.
const double _kHalfSlotGap = AppGrid.grid12 / 2;

/// Molecule: horizontally scrolling carousel of exercise slots with a dot
/// indicator below.
///
/// Sized by [size]:
///   - [ExerciseFlowCarouselSize.sm] (default) — active slot shows
///     [ThumbnailSize.size100] (100×100), inactive shows [ThumbnailSize.size76]
///     (76×76). Existing behaviour preserved.
///   - [ExerciseFlowCarouselSize.lg] — each slot renders a
///     [MediaHolder] at [MediaHolderSize.lg] (360×452). Page width = 372px so
///     neighbours peek slightly on a standard phone.
///
/// Dot indicator is hidden when [thumbnails] has only one item.
/// Parent owns [currentIndex]; molecule reports changes via [onIndexChanged].
class ExerciseFlowCarousel extends StatefulWidget {
  /// Image paths for each slot. Length drives item count.
  /// Values reserved for future image support — currently ignored.
  final List<String?> thumbnails;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final ExerciseFlowCarouselSize size;

  const ExerciseFlowCarousel({
    super.key,
    required this.thumbnails,
    required this.currentIndex,
    required this.onIndexChanged,
    this.size = ExerciseFlowCarouselSize.sm,
  });

  @override
  State<ExerciseFlowCarousel> createState() => _ExerciseFlowCarouselState();
}

class _ExerciseFlowCarouselState extends State<ExerciseFlowCarousel> {
  PageController? _pageController;
  double? _lastFraction;

  // sm: active thumbnail width (100) + full gap (12) = 112px
  // lg: MediaHolder lg width (360) + full gap (12) = 372px
  double get _pageWidth => widget.size == ExerciseFlowCarouselSize.lg
      ? AppGrid.grid360 + AppGrid.grid12
      : AppGrid.grid100 + AppGrid.grid12;

  double get _viewportHeight => widget.size == ExerciseFlowCarouselSize.lg
      ? AppGrid.grid452
      : AppGrid.grid100;

  PageController _controllerFor(double availableWidth) {
    final fraction = (_pageWidth / availableWidth).clamp(0.1, 1.0);
    if (_lastFraction != fraction) {
      _pageController?.dispose();
      _pageController = PageController(
        viewportFraction: fraction,
        initialPage: widget.currentIndex,
      );
      _lastFraction = fraction;
    }
    return _pageController!;
  }

  @override
  void didUpdateWidget(ExerciseFlowCarousel old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _pageController?.animateToPage(
        widget.currentIndex,
        duration: AppDurations.toggle,
        curve: AppCurves.toggle,
      );
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Widget _buildSlot(int i) {
    if (widget.size == ExerciseFlowCarouselSize.lg) {
      return const Center(child: MediaHolder(size: MediaHolderSize.lg));
    }
    // sm: active/inactive thumbnail with peek alignment
    final isActive = i == widget.currentIndex;
    final alignment = isActive
        ? Alignment.center
        : i < widget.currentIndex
            ? Alignment.centerRight
            : Alignment.centerLeft;
    return Align(
      alignment: alignment,
      child: Thumbnail(
        size: isActive ? ThumbnailSize.size100 : ThumbnailSize.size76,
      ),
    );
  }

  Widget _buildPageView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final controller = _controllerFor(constraints.maxWidth);
        return PageView.builder(
          controller: controller,
          itemCount: widget.thumbnails.length,
          clipBehavior: Clip.none,
          physics: const PageScrollPhysics(),
          onPageChanged: widget.onIndexChanged,
          itemBuilder: (context, i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: _kHalfSlotGap),
              child: _buildSlot(i),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLg = widget.size == ExerciseFlowCarouselSize.lg;
    final hasDots = widget.thumbnails.length > 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: _viewportHeight, child: _buildPageView()),
        if (hasDots) ...[
          SizedBox(height: AppGrid.grid8),
          Center(
            child: DotIndicator(
              count: widget.thumbnails.length,
              currentIndex: widget.currentIndex,
              onJump: (i) {
                widget.onIndexChanged(i);
                _pageController?.animateToPage(
                  i,
                  duration: AppDurations.toggle,
                  curve: AppCurves.toggle,
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
