import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pose_detection/flutter_pose_detection.dart';

class PoseController extends ChangeNotifier {
  final CameraDescription camera;
  final NpuPoseDetector _detector = NpuPoseDetector();

  CameraController? _cameraController;
  bool _isProcessing = false;

  List<PoseLandmark>? _landmarks;

  CameraController? get cameraController => _cameraController;
  List<PoseLandmark>? get landmarks => _landmarks;

  PoseController(this.camera);

  Future<void> initialize() async {
    await _detector.initialize();

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
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
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> disposeController() async {
    await _cameraController?.dispose();
    _detector.dispose();
  }
}
