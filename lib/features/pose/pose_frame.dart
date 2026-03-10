import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter_pose_detection/flutter_pose_detection.dart';

class PoseFrame {
  final List<Vector3> landmarks;
  final int timestamp;

  final Map<String, double> jointAngles = {};

  PoseFrame({required List<Vector3> rawLandmarks, required this.timestamp})
      : landmarks = _orientToUserLeft(rawLandmarks) {
    _computeAllJointAngles();
  }

  PoseFrame.fromPoseLandmarks({
    required List<PoseLandmark> poseLandmarks,
    required this.timestamp,
  }) : landmarks = _orientToUserLeft(
          poseLandmarks.map((l) => Vector3(l.x, l.y, l.z)).toList(),
        ) {
    _computeAllJointAngles();
  }

  static List<Vector3> _orientToUserLeft(List<Vector3> raw) {
    return raw.map((v) => Vector3(-v.x, v.y, v.z)).toList();
  }

  Map<String, double> get anglesInDegrees {
    return jointAngles.map(
      (key, value) => MapEntry(key, value * 180 / math.pi),
    );
  }

  static const List<_JointAngleDefinition> _jointDefinitions = [
    _JointAngleDefinition('left_elbow', 11, 13, 15, false),
    _JointAngleDefinition('right_elbow', 12, 14, 16, true),

    _JointAngleDefinition('left_shoulder', 23, 11, 13, false),
    _JointAngleDefinition('right_shoulder', 24, 12, 14, true),

    _JointAngleDefinition('left_wrist', 13, 15, 19, false),
    _JointAngleDefinition('right_wrist', 14, 16, 20, true),

    _JointAngleDefinition('left_knee', 23, 25, 27, false),
    _JointAngleDefinition('right_knee', 24, 26, 28, true),

    _JointAngleDefinition('left_hip', 11, 23, 25, false),
    _JointAngleDefinition('right_hip', 12, 24, 26, true),

    _JointAngleDefinition('left_ankle', 25, 27, 31, false),
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

  double _calculateAngleBetweenVectors(
    Vector3 a,
    Vector3 b,
    Vector3 c, {
    bool mirrorXAxisForRightSide = false,
  }) {
    Vector3 v1 = a - b;
    Vector3 v2 = c - b;

    if (mirrorXAxisForRightSide) {
      v1.x = -v1.x;
      v2.x = -v2.x;
    }

    return v1.angleTo(v2);
  }

  @override
  String toString() {
    String output = "--- Pose Frame @ ${timestamp}ms ---\n";

    anglesInDegrees.forEach((joint, angle) {
      output += "${joint.padRight(15)}: ${angle.toStringAsFixed(1)}°\n";
    });

    return output;
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'angles': jointAngles,
        'landmarks': landmarks
            .map((v) => {'x': v.x, 'y': v.y, 'z': v.z})
            .toList(),
      };

  factory PoseFrame.fromJson(Map<String, dynamic> json) {
    final landmarksJson = json['landmarks'] as List;

    final rawLandmarks = landmarksJson
        .map((l) => Vector3(
              (l['x'] as num).toDouble(),
              (l['y'] as num).toDouble(),
              (l['z'] as num).toDouble(),
            ))
        .toList();

    return PoseFrame(
      rawLandmarks: rawLandmarks,
      timestamp: json['timestamp'] as int,
    );
  }
}

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