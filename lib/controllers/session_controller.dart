
import '../servicesbackend/session_service.dart';

class SessionController {
  final SessionService _session;

  SessionController(this._session);

  /// POST /sessions/start
  /// Input: userId, exerciseId
  /// Output: { success, sessionId }
  Future<Map<String, Object?>> startSession({
    required int userId,
    required int exerciseId,
  }) async {
    try {
      final sessionId = await _session.startSession(
        userId: userId,
        exerciseId: exerciseId,
      );

      return {
        'success': true,
        'sessionId': sessionId,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// POST /sessions/frame
  /// Input: sessionId, exerciseId, frameNumber, timestamp, poseJson
  /// Output: { success, accuracy }
  Future<Map<String, Object?>> addFrame({
    required int sessionId,
    required int exerciseId,
    required int frameNumber,
    required double timestamp,
    required String poseJson,
  }) async {
    try {
      final accuracy = await _session.addLiveFrameAndScore(
        sessionId: sessionId,
        exerciseId: exerciseId,
        frameNumber: frameNumber,
        timestamp: timestamp,
        poseJson: poseJson,
      );

      return {
        'success': true,
        'accuracy': accuracy, // double? (0..100) or null
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// POST /sessions/end
  /// Input: sessionId
  /// Output: { success }
  Future<Map<String, Object?>> endSession({
    required int sessionId,
  }) async {
    try {
      await _session.endSession(sessionId: sessionId);
      return {
        'success': true,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}