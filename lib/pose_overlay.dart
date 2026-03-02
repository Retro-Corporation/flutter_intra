import 'package:flutter/material.dart' as material;
import 'package:flutter_pose_detection/flutter_pose_detection.dart'
    as pose_detection;

class PoseOverlay extends material.StatelessWidget {
  final List<pose_detection.PoseLandmark> landmarks;
  final material.Size previewSize;

  const PoseOverlay({
    super.key,
    required this.landmarks,
    required this.previewSize,
  });

  @override
  material.Widget build(material.BuildContext context) {
    return material.Positioned.fill(
      child: material.CustomPaint(
        painter: PosePainter(landmarks, previewSize),
      ),
    );
  }
}

class PosePainter extends material.CustomPainter {
  final List<pose_detection.PoseLandmark> landmarks;
  final material.Size imageSize;

  PosePainter(this.landmarks, this.imageSize);

  @override
  void paint(material.Canvas canvas, material.Size size) {
    final paint = material.Paint()
      ..color = material.Colors.green
      ..strokeWidth = 4;
    final imageAspect = imageSize.width / imageSize.height;
    final widgetAspect = size.width / size.height;

    double scale;
    double offsetX = 0;
    double offsetY = 0;

    if (widgetAspect > imageAspect) {
      // Widget is wider than camera
      scale = size.height / imageSize.height;
      offsetX = (size.width - imageSize.width * scale) / 2;
    } else {
      // Widget is taller than camera
      scale = size.width / imageSize.width;
      offsetY = (size.height - imageSize.height * scale) / 2;
    }

    for (final landmark in landmarks) {
      final x = landmark.x * imageSize.width;
      final y = landmark.y * imageSize.height;

      final dx = x * scale + offsetX;
      final dy = y * scale + offsetY;

      canvas.drawCircle(material.Offset(dx, dy), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant material.CustomPainter oldDelegate) => true;
}
