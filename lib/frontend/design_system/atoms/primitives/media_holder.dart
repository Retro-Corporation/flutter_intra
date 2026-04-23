import 'package:flutter/widgets.dart';

import '../../foundation/color/colors.dart';
import '../../foundation/space/radius.dart';

const double _kMediaWidth = 332.0;
const double _kMediaHeight = 408.0;

class MediaHolder extends StatelessWidget {
  const MediaHolder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kMediaWidth,
      height: _kMediaHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
