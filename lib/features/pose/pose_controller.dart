// pose_controller.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_pose_detection/flutter_pose_detection.dart';

import 'pose_frame.dart';
import 'pose_sequence.dart';

class PoseController extends ChangeNotifier {
  final NpuPoseDetector _detector = NpuPoseDetector();
  NativeMotionEngine? _engine;

  PoseSnapshot? _latestSnapshot;

  /// Texture ID for rendering the camera feed via [Texture] widget.
  int? get textureId => _engine?.textureId;

  /// Whether the engine is ready and producing frames.
  bool get isReady => _engine != null;

  /// The latest image-space landmarks (for overlay drawing).
  List<LandmarkData>? get poseLandmarks => _latestSnapshot?.poseLandmarks;

  /// The latest world-space landmarks (meters, hip-centered).
  List<LandmarkData>? get worldLandmarks => _latestSnapshot?.worldLandmarks;

  bool _isRecording = false;
  int? _recordingStartMs;
  final List<PoseFrame> _recordedFrames = [];

  bool get isRecording => _isRecording;

  PoseController();

  Future<void> initialize() async {
    await _detector.initialize();

    _engine = await _detector.startMotionEngine(
      config: const MotionEngineConfig(
        cameraFacing: CameraFacing.front,
        targetFps: 20, // Keep this at 20 fps to prevent overheating.
        minPoseDetectionConfidence: 0.4,
        minPosePresenceConfidence: 0.4,
        minTrackingConfidence: 0.6,
      ),
    );

    // Poll the FFI buffer every frame
    _startPolling();
    notifyListeners();
  }

  void _startPolling() {
    SchedulerBinding.instance.addPersistentFrameCallback((_) {
      if (_engine == null) return;

      final snapshot = _engine!.readLatestPose();
      if (snapshot == null) return;

      _latestSnapshot = snapshot;
      notifyListeners();

      if (_isRecording && _latestSnapshot != null) {
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        _recordingStartMs ??= nowMs;
        final relativeMs = nowMs - _recordingStartMs!;

        _recordedFrames.add(
          PoseFrame.fromWorldLandmarks(
            worldLandmarks: _latestSnapshot!.worldLandmarks,
            timestamp: relativeMs,
          ),
        );
      }
    });
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
    await _detector.stopMotionEngine();
    _detector.dispose();
    _engine = null;
  }
}