/**
 * pose_sequence.dart
 * 
 * A pose sequence is a list of pose frames, representing a continuous stream of pose data over time.
 * It contains a list of PoseFrame objects, and the lenght of the sequence in ms.
 * 
 * Designed for single-session playback or analysis.
 * TODO: join with ui to record and display sequences, and to save/load from local storage.
 * (Use JSON serialization for easy storage and retrieval, and exercise class).
 */

import 'dart:convert';
import 'pose_frame.dart';

class PoseSequence {
  final List<PoseFrame> frames;

  PoseSequence({required this.frames});

  /// Total duration of the sequence in milliseconds
  int get durationMs {
    if (frames.isEmpty) return 0;
    return frames.last.timestamp - frames.first.timestamp;
  }

  /// Average frames per second (Hz)
  double get fps {
    if (frames.length < 2) return 0.0;
    return (frames.length / (durationMs / 1000.0));
  }

  /// Converts the sequence into a Map structure for JSON encoding
  Map<String, dynamic> toMap() {
    return {
      'metadata': {
        'frame_count': frames.length,
        'duration_ms': durationMs,
        'avg_fps': fps.toStringAsFixed(2),
      },
      'frames': frames.map((f) => f.toJson()).toList(),
    };
  }

  /// Returns the sequence as a JSON string
  ///
  /// TODO: If the sequence is large, move to a background Isolate
  /// to avoid blocking the UI thread during stringification.
  String toJsonString() {
    return jsonEncode(toMap());
  }

  @override
  String toString() {
    return "PoseSequence: ${frames.length} frames (${fps.toStringAsFixed(1)} FPS)";
  }
}
