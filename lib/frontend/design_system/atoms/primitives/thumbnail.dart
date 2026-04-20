import 'package:flutter/widgets.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import 'thumbnail_types.dart';

/// Atom: square placeholder box for an exercise image.
///
/// Renders a solid [AppColors.grey800] square at the specified [size].
/// Image rendering is deferred — this is a structural placeholder.
/// All values from Foundation tokens (DIP). No state (SRP).
class Thumbnail extends StatelessWidget {
  final ThumbnailSize size;

  const Thumbnail({super.key, required this.size});

  double get _dimension => switch (size) {
    ThumbnailSize.size76  => AppGrid.grid76,
    ThumbnailSize.size100 => AppGrid.grid100,
    ThumbnailSize.size128 => AppGrid.grid128,
  };

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        width: _dimension,
        height: _dimension,
        child: const ColoredBox(color: AppColors.grey800),
      ),
    );
  }
}
