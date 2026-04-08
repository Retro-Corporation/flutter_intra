/**
 * pose_frame.dart
 * 
 * A pose frame contains a landmarks list, a timestamp, and a features list. 
 * (Compute joint angles.)
 * It represents a single frame of pose data extracted from the camera feed.
 * 
 * TODO: Become camera aware so that if using front camera, no x flip is applied.
 * Also add semantic sets grouping joints such as upperBody, lowerBody, arms, etc.
 * 
 * TODO: Reduce overlap with PoseLandmark class. The library has names for
 * each landmark, and has json serialization.
 */

import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import 'package:flutter_pose_detection/flutter_pose_detection.dart';

class PoseFrame {
  final List<Vector3> landmarks;
  final int timestamp;

  // Stored internally in radians
  final Map<String, double> jointAngles = {};

  PoseFrame({required List<Vector3> rawLandmarks, required this.timestamp})
    : landmarks = _orientToUserLeft(rawLandmarks) {
    _computeAllJointAngles();
  }

  /// Creates a PoseFrame from library PoseLandmark objects (image-space)
  PoseFrame.fromPoseLandmarks({
    required List<PoseLandmark> poseLandmarks,
    required this.timestamp,
  }) : landmarks = _orientToUserLeft(
          poseLandmarks.map((l) => Vector3(l.x, l.y, l.z)).toList(),
        ) {
    _computeAllJointAngles();
  }

  /// Creates a PoseFrame from FFI world-space LandmarkData (meters, hip-centered).
  ///
  /// World landmarks are already in real-world coordinates so the
  /// X-flip for user-left orientation still applies, but the values
  /// represent metric distances rather than normalized image coords.
  PoseFrame.fromWorldLandmarks({
    required List<LandmarkData> worldLandmarks,
    required this.timestamp,
  }) : landmarks = _orientToUserLeft(
          worldLandmarks.map((l) => Vector3(l.x, l.y, l.z)).toList(),
        ) {
    _computeAllJointAngles();
  }

  /// Transforms raw MediaPipe data so Negative X = User's Actual Left
  ///
  /// MediaPipe default: Negative X is the person's right.
  /// To make Negative X represent the user's LEFT side,
  /// we negate the X coordinate.
  static List<Vector3> _orientToUserLeft(List<Vector3> raw) {
    return raw.map((v) => Vector3(-v.x, v.y, v.z)).toList();
  }

  /// Returns all joint angles converted to Degrees (0–180)
  Map<String, double> get anglesInDegrees {
    return jointAngles.map(
      (key, value) => MapEntry(key, value * 180 / math.pi),
    );
  }

  /// Joint topology definitions
  ///
  /// Format:
  /// (name, parentIndex, jointIndex, childIndex, isRightSide)
  static const List<_JointAngleDefinition> _jointDefinitions = [
    // --- Arms ---
    _JointAngleDefinition('left_elbow', 11, 13, 15, false),
    _JointAngleDefinition('right_elbow', 12, 14, 16, true),

    // Shoulder definitions from torso/hip anchor
    _JointAngleDefinition(
      'left_shoulder',
      23,
      11,
      13,
      false,
    ), // Hip-Shoulder-Elbow
    _JointAngleDefinition('right_shoulder', 24, 12, 14, true),

    // Wrist articulation
    _JointAngleDefinition('left_wrist', 13, 15, 19, false), // Elbow-Wrist-Index
    _JointAngleDefinition('right_wrist', 14, 16, 20, true),

    // --- Legs ---
    _JointAngleDefinition('left_knee', 23, 25, 27, false),
    _JointAngleDefinition('right_knee', 24, 26, 28, true),

    _JointAngleDefinition('left_hip', 11, 23, 25, false), // Shoulder-Hip-Knee
    _JointAngleDefinition('right_hip', 12, 24, 26, true),

    // --- Extremities ---
    _JointAngleDefinition(
      'left_ankle',
      25,
      27,
      31,
      false,
    ), // Knee-Ankle-FootIndex
    _JointAngleDefinition('right_ankle', 26, 28, 32, true),
  ];

  void _computeAllJointAngles() {
    for (final def in _jointDefinitions) {
      _addAngle(
        def.name,
        def.parentIndex,
        def.jointIndex,
        def.childIndex,
        isRight: def.isRightSide,
      );
    }
  }

  /// Helper to calculate and store angles
  void _addAngle(
    String name,
    int parentIndex,
    int jointIndex,
    int childIndex, {
    bool isRight = false,
  }) {
    if (landmarks.length > childIndex) {
      jointAngles[name] = _calculateAngleBetweenVectors(
        landmarks[parentIndex],
        landmarks[jointIndex],
        landmarks[childIndex],
        mirrorXAxisForRightSide: isRight,
      );
    }
  }

  /// Calculates the angle at point B formed by A-B-C
  ///
  /// If `mirrorXAxisForRightSide` is enabled, the X component of the
  /// vectors is flipped. This mimics Kinect-style symmetry where
  /// positive rotations behave consistently on both body sides.
  double _calculateAngleBetweenVectors(
    Vector3 a,
    Vector3 b,
    Vector3 c, {
    bool mirrorXAxisForRightSide = false,
  }) {
    Vector3 v1 = a - b;
    Vector3 v2 = c - b;

    // Internal flip for right-side symmetry
    if (mirrorXAxisForRightSide) {
      v1.x = -v1.x;
      v2.x = -v2.x;
    }

    return v1.angleTo(v2); // Result in radians
  }

  @override
  String toString() {
    String output = "--- Pose Frame @ ${timestamp}ms ---\n";

    anglesInDegrees.forEach((joint, angle) {
      output += "${joint.padRight(15)}: ${angle.toStringAsFixed(1)}°\n";
    });

    return output;
  }

  /// Converts the individual frame to a JSON-compatible Map.
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'angles': jointAngles,
    'landmarks': landmarks.map((v) => {'x': v.x, 'y': v.y, 'z': v.z}).toList(),
  };
}

/// Internal structure describing how a joint angle should be computed
class _JointAngleDefinition {
  final String name;
  final int parentIndex;
  final int jointIndex;
  final int childIndex;
  final bool isRightSide;

  const _JointAngleDefinition(
    this.name,
    this.parentIndex,
    this.jointIndex,
    this.childIndex,
    this.isRightSide,
  );
}
