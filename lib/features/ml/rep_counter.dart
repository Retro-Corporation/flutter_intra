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

  // Helps prevent jitter / accidental step jumps
  int _stableFrameCount = 0;
  final int _requiredStableFrames = 2;

  RepCounter({
    required this.referenceSequence,
    this.similarityThreshold = 0.30,
  });

  int get repCount => _repCount;

  double get repProgress =>
      referenceSequence.frames.isEmpty ? 0.0 : _currentStepIndex / referenceSequence.frames.length;

  void processFrame(PoseFrame userFrame) {
    if (referenceSequence.frames.isEmpty) return;

    int bestIndex = _currentStepIndex;
    double bestSimilarity = 0.0;

    // Find the closest pose step
    for (int i = _currentStepIndex; i < referenceSequence.frames.length; i++) {
      double similarity = MotionSimilarity.compareArms(
        userFrame,
        referenceSequence.frames[i],
      );

      if (similarity > bestSimilarity) {
        bestSimilarity = similarity;
        bestIndex = i;
      }
    }

    // Check if similarity is good enough
    if (bestSimilarity >= (1.0 - similarityThreshold)) {
      _stableFrameCount++;

      if (_stableFrameCount >= _requiredStableFrames) {
        _advanceStep(bestIndex);
        _stableFrameCount = 0;
      }
    } else {
      _stableFrameCount = 0;
    }
  }

  void _advanceStep(int newIndex) {
    // Prevent backward jumps
    if (newIndex < _currentStepIndex) return;

    _currentStepIndex = newIndex + 1;

    if (_currentStepIndex >= referenceSequence.frames.length) {
      _repCount++;
      _currentStepIndex = 0;
      print("Rep Completed! Total: $_repCount");
    }
  }

  void reset() {
    _repCount = 0;
    _currentStepIndex = 0;
    _stableFrameCount = 0;
  }
}