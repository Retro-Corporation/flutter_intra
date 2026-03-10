// pose_controller.dart
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pose_detection/flutter_pose_detection.dart';

import 'pose_frame.dart';
import 'pose_sequence.dart';

class PoseController extends ChangeNotifier {
  final CameraDescription camera;
  final NpuPoseDetector _detector = NpuPoseDetector();

  CameraController? _cameraController;
  bool _isProcessing = false;

  List<PoseLandmark>? _landmarks;

  CameraController? get cameraController => _cameraController;
  List<PoseLandmark>? get landmarks => _landmarks;


  bool _isRecording = false;
  int? _recordingStartMs;           
  final List<PoseFrame> _recordedFrames = [];

  bool get isRecording => _isRecording;

  PoseController(this.camera);

  Future<void> initialize() async {
    await _detector.initialize();

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
      fps: 20, // Limit to 20 FPS to reduce processing load
    );

    await _cameraController!.initialize();
    await _cameraController!.startImageStream(_processFrame);

    notifyListeners();
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isProcessing || !_detector.isInitialized) return;
    _isProcessing = true;

    try {
      final planes = image.planes
          .map(
            (p) => {
              'bytes': p.bytes,
              'bytesPerRow': p.bytesPerRow,
              'bytesPerPixel': p.bytesPerPixel,
            },
          )
          .toList();

      final result = await _detector.processFrame(
        planes: planes,
        width: image.width,
        height: image.height,
        format: 'yuv420',
        rotation: _cameraController!.description.sensorOrientation,
      );

      if (result.hasPoses) {
        _landmarks = result.firstPose!.landmarks;
        notifyListeners();

        if (_isRecording && _landmarks != null) {
          final nowMs = DateTime.now().millisecondsSinceEpoch;

          // Lazily set recording start time on first frame
          _recordingStartMs ??= nowMs;
          final relativeMs = nowMs - _recordingStartMs!;

          // Use the new fromPoseLandmarks constructor
          _recordedFrames.add(
            PoseFrame.fromPoseLandmarks(
              poseLandmarks: _landmarks!,
              timestamp: relativeMs,
            ),
          );
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  // Start collecting PoseFrames
  void startRecording() {
    _recordedFrames.clear();
    _recordingStartMs = null;
    _isRecording = true;
  }

  // Stop and return PoseSequence built from collected frames
  PoseSequence stopRecording() {
    _isRecording = false;
    return PoseSequence(frames: List.unmodifiable(_recordedFrames));
  }

  Future<void> disposeController() async {
    await _cameraController?.dispose();
    _detector.dispose();
  }
}