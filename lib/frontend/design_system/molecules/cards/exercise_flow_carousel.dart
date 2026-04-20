import 'package:flutter/material.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/motion/curves.dart';
import '../../atoms/primitives/thumbnail.dart';
import '../../atoms/primitives/thumbnail_types.dart';
import '../../atoms/primitives/dot_indicator.dart';

/// Half of [AppGrid.grid12]: each slot contributes this on each touching side,
/// creating exactly [AppGrid.grid12] (12px) of gap between adjacent slots.
const double _kHalfSlotGap = AppGrid.grid12 / 2;

/// Molecule: horizontally scrolling carousel of exercise thumbnails
/// with a dot indicator below.
///
/// Active item (at [currentIndex]) shows [ThumbnailSize.size100] (100×100).
/// Inactive items show [ThumbnailSize.size76] (76×76).
/// Gap between slots: [AppGrid.grid12].
/// Parent owns [currentIndex]; molecule reports changes via [onIndexChanged].
class ExerciseFlowCarousel extends StatefulWidget {
  /// Image paths for each slot. Length drives item count.
  /// Values reserved for future image support — currently ignored by [Thumbnail].
  final List<String?> thumbnails;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const ExerciseFlowCarousel({
    super.key,
    required this.thumbnails,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  State<ExerciseFlowCarousel> createState() => _ExerciseFlowCarouselState();
}

class _ExerciseFlowCarouselState extends State<ExerciseFlowCarousel> {
  PageController? _pageController;
  double? _lastFraction;

  // Each page = active thumbnail width + full gap (112px).
  // Half-gap on each side of every item = exactly AppGrid.grid12 between neighbours.
  static const double _kPageWidth = AppGrid.grid100 + AppGrid.grid12;

  PageController _controllerFor(double availableWidth) {
    final fraction = (_kPageWidth / availableWidth).clamp(0.1, 1.0);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: AppGrid.grid100,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final controller = _controllerFor(constraints.maxWidth);
              return PageView.builder(
                controller: controller,
                itemCount: widget.thumbnails.length,
                clipBehavior: Clip.none,
                physics: const PageScrollPhysics(),
                onPageChanged: widget.onIndexChanged,
                itemBuilder: (context, i) {
                  final isActive = i == widget.currentIndex;
                  // Inactive items align toward the nearest viewport edge so
                  // they sit right at the peek boundary (centering hides them).
                  final alignment = isActive
                      ? Alignment.center
                      : i < widget.currentIndex
                          ? Alignment.centerRight
                          : Alignment.centerLeft;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: _kHalfSlotGap),
                    child: Align(
                      alignment: alignment,
                      child: Thumbnail(
                        size: isActive
                            ? ThumbnailSize.size100
                            : ThumbnailSize.size76,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
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
    );
  }
}
