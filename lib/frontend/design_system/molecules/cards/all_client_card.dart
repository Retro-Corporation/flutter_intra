import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/motion/curves.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/press/three_d_press_geometry.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/type/typography.dart';
import '../../icons/app_icons.dart';
import '../../atoms/behaviors/three_d_press_painter.dart';
import '../../atoms/primitives/icon.dart';
import '../../atoms/primitives/text.dart';
import 'all_client_card_types.dart';

/// Molecule: a split-zone client card for the "All clients" list.
///
/// Two independent 3D press zones in a [Row]:
/// - Left zone (expanded): client name + email → [onTap] (navigate to profile)
/// - Right zone: action icon → [onAction] (add or remove)
///
/// Cross-zone press effects:
/// - When a zone is pressed, its border thickens on the touching edge.
/// - The non-pressed zone's top inner corner rounds out for contrast.
///
/// When [state] is [AllClientCardState.rosterFull], the right zone is absent.
class AllClientCard extends StatefulWidget {
  final String clientName;
  final String email;
  final AllClientCardState state;
  final VoidCallback onTap;
  final VoidCallback onAction;

  const AllClientCard({
    super.key,
    required this.clientName,
    required this.email,
    required this.state,
    required this.onTap,
    required this.onAction,
  });

  @override
  State<AllClientCard> createState() => _AllClientCardState();
}

class _AllClientCardState extends State<AllClientCard>
    with TickerProviderStateMixin {
  bool _leftPressed = false;
  bool _rightPressed = false;

  late final AnimationController _leftController = AnimationController(
    vsync: this,
    duration: AppDurations.press,
  );
  late final AnimationController _rightController = AnimationController(
    vsync: this,
    duration: AppDurations.press,
  );
  late final CurvedAnimation _leftAnim = CurvedAnimation(
    parent: _leftController,
    curve: AppCurves.press,
  );
  late final CurvedAnimation _rightAnim = CurvedAnimation(
    parent: _rightController,
    curve: AppCurves.press,
  );

  @override
  void dispose() {
    _leftAnim.dispose();
    _rightAnim.dispose();
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  /// Extra border width on the touching edge when a zone is pressed.
  static const double _touchBorderExtra = 3.0;

  Widget? _actionIcon() => switch (widget.state) {
        AllClientCardState.add =>
          const AppIcon(AppIcons.add, color: AppColors.textPrimary),
        AllClientCardState.rosterFull => null,
        AllClientCardState.remove =>
          const AppIcon(AppIcons.close, color: AppColors.textPrimary),
      };

  /// Builds a single 3D press zone with GestureDetector + animated CustomPaint.
  ///
  /// [pressAnim] drives the 3D geometry lerp between unpressed and pressed.
  /// [onPressChanged] flips the discrete bool used for cross-zone corner
  /// rounding (snap at 80ms is fine) and starts/reverses the animation.
  /// [touchingEdge] is which side of this zone touches the sibling zone —
  /// that side's border thickens by [_touchBorderExtra * pressAnim.value].
  Widget _buildZone({
    required Animation<double> pressAnim,
    required BorderRadius corners,
    required VoidCallback onTap,
    required void Function(bool) onPressChanged,
    required Widget child,
    _TouchingEdge? touchingEdge,
  }) {
    final geoUnpressed = PressGeometry.outline(pressed: false);
    final geoPressed = PressGeometry.outline(pressed: true);

    return GestureDetector(
      onTapDown: (_) => onPressChanged(true),
      onTapUp: (_) {
        onPressChanged(false);
        onTap();
      },
      onTapCancel: () => onPressChanged(false),
      child: AnimatedBuilder(
        animation: pressAnim,
        child: child,
        builder: (context, innerChild) {
          final t = pressAnim.value;
          final geo = PressGeometry.lerp(geoUnpressed, geoPressed, t);
          final thickening = _touchBorderExtra * t;
          final double? borderSideLeft =
              touchingEdge == _TouchingEdge.left ? geo.visualSide + thickening : null;
          final double? borderSideRight =
              touchingEdge == _TouchingEdge.right ? geo.visualSide + thickening : null;
          return CustomPaint(
            painter: ThreeDPressPainter(
              backgroundColor: AppColors.surface,
              borderColor: AppColors.surfaceBorder,
              borderRadius: AppRadius.sm,
              borderRadiusGeometry: corners,
              borderTop: geo.visualTop,
              borderBottom: geo.visualBottom,
              borderSide: geo.visualSide,
              borderSideLeft: borderSideLeft,
              borderSideRight: borderSideRight,
              faceOffset: geo.faceOffset,
              faceSideInset: geo.layoutSide,
              showBorder: geo.showBorder,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: geo.layoutSide,
                right: geo.layoutSide,
                top: geo.visualTop + geo.faceOffset,
                bottom: (geo.reservedVertical - geo.visualTop - geo.faceOffset)
                    .clamp(0.0, double.infinity),
              ),
              child: innerChild,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actionIcon = _actionIcon();
    final hasRightZone = actionIcon != null;

    // --- Corner radius computation ---
    // Inner corners are 0 at rest. When the OTHER zone is pressed,
    // the top inner corner rounds out to AppRadius.sm for contrast.
    final BorderRadius leftCorners;
    if (!hasRightZone) {
      leftCorners = BorderRadius.circular(AppRadius.sm);
    } else if (_rightPressed) {
      leftCorners = BorderRadius.only(
        topLeft: Radius.circular(AppRadius.sm),
        bottomLeft: Radius.circular(AppRadius.sm),
        topRight: Radius.circular(AppRadius.sm),
      );
    } else {
      leftCorners = BorderRadius.only(
        topLeft: Radius.circular(AppRadius.sm),
        bottomLeft: Radius.circular(AppRadius.sm),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left zone: profile navigation
          Expanded(
            child: _buildZone(
              pressAnim: _leftAnim,
              corners: leftCorners,
              onTap: widget.onTap,
              onPressChanged: (p) {
                setState(() => _leftPressed = p);
                if (p) {
                  _leftController.value = 1.0;
                } else {
                  _leftController.reverse();
                }
              },
              touchingEdge: hasRightZone ? _TouchingEdge.right : null,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppPadding.cardPadding,
                  AppPadding.rem05,
                  AppPadding.cardPadding,
                  AppPadding.rem05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      widget.clientName,
                      style: AppTypography.body.bold,
                      color: AppColors.textPrimary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppText(
                      widget.email,
                      style: AppTypography.bodySmall.regular,
                      color: AppColors.textSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right zone: add/remove action (absent when rosterFull)
          if (actionIcon != null) ...[
            Transform.translate(
              offset: const Offset(-AppStroke.md, 0),
              child: _buildZone(
                pressAnim: _rightAnim,
                corners: _leftPressed
                    ? BorderRadius.only(
                        topRight: Radius.circular(AppRadius.sm),
                        bottomRight: Radius.circular(AppRadius.sm),
                        topLeft: Radius.circular(AppRadius.sm),
                      )
                    : BorderRadius.only(
                        topRight: Radius.circular(AppRadius.sm),
                        bottomRight: Radius.circular(AppRadius.sm),
                      ),
                onTap: widget.onAction,
                onPressChanged: (p) {
                  setState(() => _rightPressed = p);
                  if (p) {
                    _rightController.value = 1.0;
                  } else {
                    _rightController.reverse();
                  }
                },
                touchingEdge: _TouchingEdge.left,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppPadding.rem15,
                    AppPadding.rem05,
                    AppPadding.rem15,
                    AppPadding.rem05,
                  ),
                  child: Center(child: actionIcon),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Which edge of a zone touches the sibling zone in the Row.
enum _TouchingEdge { left, right }
