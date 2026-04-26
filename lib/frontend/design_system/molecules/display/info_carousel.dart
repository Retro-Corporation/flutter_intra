import 'dart:async';
import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/motion/curves.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/type/typography.dart';
import '../../icons/app_icons.dart';
import '../../icons/icon_sizes.dart';
import '../../atoms/primitives/icon.dart';
import '../../atoms/primitives/text.dart';

/// Auto-cycling hint message strip with icon.
///
/// Advances through exactly 3 messages on a [interval] timer.
/// Resets to message 0 when [messages] changes (e.g. on tab switch).
/// Fade transition between messages via [AnimatedSwitcher].
class InfoCarousel extends StatefulWidget {
  const InfoCarousel({
    super.key,
    required this.messages,
    this.interval = const Duration(seconds: 8),
    this.iconPath = AppIcons.info,
  }) : assert(
          messages.length == 3,
          'InfoCarousel requires exactly 3 messages — received a list of length '
          '${messages.length}. Pass exactly 3 strings.',
        );

  /// The 3 messages to cycle through. Must have exactly 3 elements.
  final List<String> messages;

  /// How long each message is displayed before advancing. Defaults to 8 s.
  final Duration interval;

  /// SVG asset path for the leading icon. Defaults to [AppIcons.info].
  final String iconPath;

  @override
  State<InfoCarousel> createState() => _InfoCarouselState();
}

class _InfoCarouselState extends State<InfoCarousel> {
  int _index = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(InfoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages != oldWidget.messages) {
      _timer.cancel();
      setState(() => _index = 0);
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(widget.interval, (_) {
      setState(() {
        _index = (_index + 1) % widget.messages.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppIcon(
          widget.iconPath,
          size: IconSizes.md,
          color: AppColors.textPrimary,
        ),
        SizedBox(width: AppGrid.grid8),
        Flexible(
          child: AnimatedSwitcher(
            duration: AppDurations.toggle,
            switchInCurve: AppCurves.toggle,
            switchOutCurve: AppCurves.toggle,
            child: AppText(
              widget.messages[_index],
              key: ValueKey(_index),
              style: AppTypography.body.semiBold,
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
