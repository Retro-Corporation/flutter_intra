/// pose_detection_service.dart
///
/// ML service for real-time pose detection.
///
/// This service handles pose detection using Google ML Kit.
/// It processes camera frames and extracts body landmarks.
///
/// Responsibilities:
/// - Initialize and manage ML Kit pose detector
/// - Process camera images and detect poses
/// - Convert image formats for ML Kit compatibility
/// - Extract pose landmarks (skeleton keypoints)
/// - Dispose of resources properly
///
/// Usage:
/// ```dart
/// final service = PoseDetectionService();
/// await service.initialize();
/// final poses = await service.detectPose(image);
/// service.dispose();
/// ```
///
/// This service is stateless and can be used from any page.
/// It handles the ML Kit lifecycle independently.
import 'dart:typed_data';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

extension MLKitPoseUtils on AnalysisImage {
  InputImage toInputImage() {
    // The following planeData code is not needed for ML Kit pose detection and references an undefined class.
    // If you need plane metadata, ensure you import the correct class from ML Kit, otherwise remove this block.

    return when(
      nv21: (image) {
        return InputImage.fromBytes(
          bytes: image.bytes,
          metadata: InputImageMetadata(
            rotation: inputImageRotation,
            format: InputImageFormat.nv21,
            size: image.size,
            bytesPerRow: image.planes.first.bytesPerRow,
          ),
        );
      },
      bgra8888: (image) {
        return InputImage.fromBytes(
          bytes: image.bytes,
          metadata: InputImageMetadata(
            rotation: inputImageRotation,
            format: inputImageFormat,
            size: size,
            bytesPerRow: image.planes.first.bytesPerRow,
          ),
        );
      },
    )!;
  }

  InputImageRotation get inputImageRotation =>
      InputImageRotation.values.byName(rotation.name);

  InputImageFormat get inputImageFormat {
    switch (format) {
      case InputAnalysisImageFormat.bgra8888:
        return InputImageFormat.bgra8888;
      case InputAnalysisImageFormat.nv21:
        return InputImageFormat.nv21;
      default:
        return InputImageFormat.yuv420;
    }
  }
}

class PoseDetectionService {
  PoseDetector? _poseDetector;
  bool _isProcessing = false;

  /// Initialize the pose detector with default options.
  /// Call this before using detectPose().
  Future<void> initialize() async {
    final options = PoseDetectorOptions();
    _poseDetector = PoseDetector(options: options);
  }

  /// Process a camera image and detect poses.
  /// Returns a list of detected poses with landmarks.
  ///
  /// If still processing a previous frame, returns null to avoid backlog.
  Future<List<Pose>?> detectPose(AnalysisImage image) async {
    if (_isProcessing || _poseDetector == null) {
      return null;
    }

    try {
      _isProcessing = true;

      // Convert AnalysisImage to InputImage for ML Kit
      final inputImage = _convertToInputImage(image);

      if (inputImage == null) {
        return null;
      }

      // Perform pose detection
      final poses = await _poseDetector!.processImage(inputImage);

      return poses;
    } catch (e) {
      print('Error detecting pose: $e');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  /// Convert CameraAwesome AnalysisImage to ML Kit InputImage.
  InputImage? _convertToInputImage(AnalysisImage image) {
    try {
      return image.toInputImage();
    } catch (e) {
      print('Error converting image: $e');
      return null;
    }
  }

  /// Concatenate YUV planes into a single byte array.
  Uint8List _concatenatePlanes(
    Uint8List yBytes,
    Uint8List uBytes,
    Uint8List vBytes,
  ) {
    final allBytes = Uint8List(yBytes.length + uBytes.length + vBytes.length);
    allBytes.setRange(0, yBytes.length, yBytes);
    allBytes.setRange(yBytes.length, yBytes.length + uBytes.length, uBytes);
    allBytes.setRange(
      yBytes.length + uBytes.length,
      yBytes.length + uBytes.length + vBytes.length,
      vBytes,
    );
    return allBytes;
  }

  /// Clean up resources when done.
  /// Call this when the service is no longer needed.
  Future<void> dispose() async {
    await _poseDetector?.close();
    _poseDetector = null;
  }

  /// Check if the detector is currently processing a frame.
  bool get isProcessing => _isProcessing;

  /// Check if the detector is initialized.
  bool get isInitialized => _poseDetector != null;
}
