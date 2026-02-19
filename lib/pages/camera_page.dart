/// camera_page.dart
///
/// Camera preview and live analysis page.
///
/// This page displays the live camera feed and handles frame analysis.
/// It uses CameraAwesome for camera preview and streams frames for ML processing.
///
/// Responsibilities:
/// - Display camera preview with proper aspect ratio
/// - Stream camera frames to ML pipeline (via onImageForAnalysis)
/// - Render overlay UI (skeleton drawing, pose visualization)
/// - Display real-time feedback to user
///
/// This page is UI-focused and delegates processing to services:
/// - services/camera/ for camera management
/// - services/ml/ for pose detection
///
/// Dependency direction:
/// camera_page → services
///
/// This ensures the page remains focused on presentation
/// while services handle business logic.
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.previewOnly(
        sensorConfig: SensorConfig.single(
          sensor: Sensor.position(SensorPosition.back),
          aspectRatio: CameraAspectRatios.ratio_16_9,
        ),

        // live frames come here
        onImageForAnalysis: (image) async {
          // process MLKit / ONNX here
          // TODO: Connect to services/ml/ pipeline
        },

        builder: (state, preview) {
          return Stack(
            children: [
              // overlay UI / skeleton drawing
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Live video stream",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
