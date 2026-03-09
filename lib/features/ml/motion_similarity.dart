/**
 * motion_similarity.dart
 * 
 * This file contains the MotionSimilarity class,
 * which computes a similarity score between two pose sequences.
 * This is a test version, we will only be comparing the arms.
 * 
 * Since the library is only returning normalized coordinates,
 * we will be comparing joint angles instead of absolute positions.
 * This makes the similarity score more robust to differences in body size and camera distance.
 * 
 * The similarity score is computed as the average percentage difference in joint angles
 */

import 'dart:math' as math;
import '../pose/pose_frame.dart';

class MotionSimilarity {
  /// Defines the arm joints we care about for this test version
  static const List<String> armJoints = [
    'left_shoulder',
    'left_elbow',
    'left_wrist',
    'right_shoulder',
    'right_elbow',
    'right_wrist',
  ];

  /// Computes the average similarity between two frames (0.0 to 1.0)
  /// 1.0 is identical, 0.0 is completely different.
  static double compareArms(PoseFrame current, PoseFrame reference) {
    double totalError = 0.0;
    int count = 0;

    for (String joint in armJoints) {
      final double? currentAngle = current.jointAngles[joint];
      final double? refAngle = reference.jointAngles[joint];

      if (currentAngle != null && refAngle != null) {
        // Calculate percentage difference relative to PI (180 degrees)
        // Using radians as stored in PoseFrame.jointAngles
        double diff = (currentAngle - refAngle).abs() / math.pi;
        totalError += diff;
        count++;
      }
    }

    if (count == 0) return 0.0;

    double averageError = totalError / count;
    // Return similarity (1.0 - error).
    // If average error is 0.10 (10%), similarity is 0.90 (90%)
    return (1.0 - averageError).clamp(0.0, 1.0);
  }

  /// Check if the similarity is within the 15% threshold (0.85 similarity)
  static bool isWithinThreshold(
    PoseFrame current,
    PoseFrame reference, {
    double threshold = 0.15,
  }) {
    return compareArms(current, reference) >= (1.0 - threshold);
  }
}
