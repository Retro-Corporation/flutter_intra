import 'dart:io';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CameraPage(),
    );
  }
}

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.awesome(
        saveConfig: SaveConfig.photoAndVideo(
          initialCaptureMode: CaptureMode.photo,
        ),
        sensorConfig: SensorConfig.single(
          sensor: Sensor.position(SensorPosition.back),
          aspectRatio: CameraAspectRatios.ratio_16_9,
        ),
        enablePhysicalButton: true,
        previewFit: CameraPreviewFit.contain,
        onMediaTap: (mediaCapture) {
          final file = mediaCapture.captureRequest.when(
            single: (single) => single.file,
            multiple: (multiple) => multiple.fileBySensor.values.first,
          );

          debugPrint('Media captured: ${file?.path}');
        },
        topActionsBuilder: (CameraState state) {
          return AwesomeTopActions(
            state: state,
            children: [
              AwesomeFlashButton(state: state),
              const Spacer(),
              AwesomeCameraSwitchButton(state: state),
            ],
          );
        },
        bottomActionsBuilder: (CameraState state) {
          return AwesomeBottomActions(
            state: state,
            left: AwesomeLocationButton(state: state),
            captureButton: AwesomeCaptureButton(state: state),
            right: AwesomeCameraModeSelector(state: state),
          );
        },
      ),
    );
  }
}
