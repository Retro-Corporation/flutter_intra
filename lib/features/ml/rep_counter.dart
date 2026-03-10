/**
 * rep_counter.dart
 * 
 * from a pose sequence, compute the number of reps performed.
 * This is done by comparing the current pose sequence to a reference pose
 * and when it is within 15% joint angle similarity, we move to the next pose in the reference sequence.
 * When we reach the end of the reference sequence, we increment the rep count and start over
 * 
 * TODO: Join with UI layer to display rep count and progresss
 */

import '../pose/pose_frame.dart';
import '../pose/pose_sequence.dart';
import 'motion_similarity.dart';

class RepCounter {
  final PoseSequence referenceSequence;
  final double similarityThreshold;

  int _repCount = 0;
  int _currentStepIndex = 0;

  RepCounter({
    required this.referenceSequence,
    this.similarityThreshold = 0.30,
  });

  int get repCount => _repCount;

  /// The percentage of the current rep completed (0.0 to 1.0)
  double get repProgress => _currentStepIndex / referenceSequence.frames.length;

  /// Processes a new frame from the live camera feed
  void processFrame(PoseFrame userFrame) {
    if (referenceSequence.frames.isEmpty) return;

    // Get the target pose we are looking for in the reference sequence
    PoseFrame targetPose = referenceSequence.frames[_currentStepIndex];

    // Check if the user's current pose matches the target within 15%
    if (MotionSimilarity.isWithinThreshold(
      userFrame,
      targetPose,
      threshold: similarityThreshold,
    )) {
      _moveToNextStep();
    }
  }

  void _moveToNextStep() {
    _currentStepIndex++;

    // If we reached the end of the reference sequence, one rep is complete
    if (_currentStepIndex >= referenceSequence.frames.length) {
      _repCount++;
      _currentStepIndex = 0; // Reset for next rep
      print("Rep Completed! Total: $_repCount");
    }
  }

  void reset() {
    _repCount = 0;
    _currentStepIndex = 0;
  }
}
