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

  String toJsonString() {
    return jsonEncode(toMap());
  }

  /// NEW: Convert Map -> PoseSequence
  factory PoseSequence.fromMap(Map<String, dynamic> map) {
    final frameList = (map['frames'] as List)
        .map((f) => PoseFrame.fromJson(Map<String, dynamic>.from(f)))
        .toList();

    return PoseSequence(frames: frameList);
  }

  /// NEW: Convert JSON string -> PoseSequence
  factory PoseSequence.fromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString);
    return PoseSequence.fromMap(decoded);
  }

  @override
  String toString() {
    return "PoseSequence: ${frames.length} frames (${fps.toStringAsFixed(1)} FPS)";
  }
}