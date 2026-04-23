import 'package:flutter/widgets.dart';

import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import 'media_holder_types.dart';

const double _kSmWidth  = AppGrid.grid332;
const double _kSmHeight = AppGrid.grid408;
const double _kLgWidth  = AppGrid.grid360;
const double _kLgHeight = AppGrid.grid452;

class MediaHolder extends StatelessWidget {
  final MediaHolderSize size;

  const MediaHolder({super.key, this.size = MediaHolderSize.sm});

  double get _width  => size == MediaHolderSize.lg ? _kLgWidth  : _kSmWidth;
  double get _height => size == MediaHolderSize.lg ? _kLgHeight : _kSmHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
