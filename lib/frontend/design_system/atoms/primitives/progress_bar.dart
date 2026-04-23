import 'dart:math';

import 'package:flutter/material.dart';

import '../../foundation/color/colors.dart';
import '../../foundation/motion/curves.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/press/three_d_press_geometry.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../behaviors/three_d_press_painter.dart';
import '../behaviors/three_d_surface.dart';

/// A display-only pill-shaped progress indicator.
///
/// The fill uses the same static 3D raised effect as the toggle thumb —
/// [ThreeDSurface] + [ThreeDPressPainter] with [PressGeometry.static] —
/// but is never pressable. The fill pill is taller than the track and
/// overhangs it above and below, exactly like the toggle thumb overhangs
/// its track. The caller drives [value] externally; the atom animates
/// smoothly between states.
///
/// [value] is clamped to 0.0–1.0. The fill never shrinks below
/// [AppGrid.grid24] so the pill is always visible.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.value});

  /// Progress value from 0.0 (empty) to 1.0 (full). Clamped internally.
  final double value;

  // ── Sizing ──────────────────────────────────────────────────────────────
  static const double _fillHeight  = AppGrid.grid24; // 24px — the orange pill face
  static const double _trackHeight = AppGrid.grid16; // 16px — the dark track

  // ── 3D geometry — identical to toggle thumb ──────────────────────────────
  static final _geo = PressGeometry.static(
    top:    AppStroke.xs,  // 1px
    side:   AppStroke.md,  // 2px
    bottom: AppStroke.xl,  // 4px — creates depth
  );

  static final _painter = ThreeDPressPainter(
    backgroundColor: AppColors.brand,
    borderColor:     AppColors.shadow700[AppColors.brand]!,
    borderRadius:    AppRadius.sm,
    borderTop:       _geo.visualTop,
    borderBottom:    _geo.visualBottom,
    borderSide:      _geo.visualSide,
    faceOffset:      _geo.faceOffset,
    faceSideInset:   _geo.layoutSide,
    showBorder:      true,
  );

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);

    // Overhang layout — same pattern as toggle thumb.
    // Fill is taller than track; track is Positioned down so fill
    // sticks out equally above and below it.
    final totalHeight   = _fillHeight + _geo.visualTop + _geo.visualBottom; // 29px
    final thumbOverflow = (_fillHeight - _trackHeight) / 2;                 // 4px
    final trackTop      = thumbOverflow + (_geo.visualBottom / 2);          // 6px

    return Semantics(
      label: '${(clamped * 100).round()}% complete',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;
          final fillWidth  = max(AppGrid.grid24, clamped * trackWidth);

          return SizedBox(
            height: totalHeight,
            child: Stack(
              children: [
                // Track — pushed down so the fill pill overhangs above and below.
                Positioned(
                  top:    trackTop,
                  left:   0,
                  right:  0,
                  height: _trackHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
                // Fill — anchored at top: 0, full totalHeight, animated width.
                Positioned(
                  top:  0,
                  left: 0,
                  child: AnimatedContainer(
                    duration: AppDurations.toggle,
                    curve:    AppCurves.toggle,
                    width:    fillWidth,
                    height:   totalHeight,
                    child:    ThreeDSurface(painter: _painter),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
