import '../database/repositories/repository.dart';

class SystemMetricsService {
  final SystemMetricsRepository _metrics;

  SystemMetricsService(this._metrics);

  Future<int> logMetric({
    required String endpoint,
    required double latencyMs,
    required double processingTimeMs,
    required String status,
  }) async {
    final cleanEndpoint = endpoint.trim();
    final cleanStatus = status.trim().toUpperCase();

    if (cleanEndpoint.isEmpty) {
      throw Exception('Endpoint cannot be empty.');
    }

    if (latencyMs < 0 || processingTimeMs < 0) {
      throw Exception('Metric times cannot be negative.');
    }

    return _metrics.insertMetric(
      endpoint: cleanEndpoint,
      latencyMs: latencyMs,
      processingTimeMs: processingTimeMs,
      status: cleanStatus,
    );
  }

  Future<int> logSuccess({
    required String endpoint,
    required double latencyMs,
    required double processingTimeMs,
  }) async {
    return logMetric(
      endpoint: endpoint,
      latencyMs: latencyMs,
      processingTimeMs: processingTimeMs,
      status: 'SUCCESS',
    );
  }

  Future<int> logFailure({
    required String endpoint,
    required double latencyMs,
    required double processingTimeMs,
  }) async {
    return logMetric(
      endpoint: endpoint,
      latencyMs: latencyMs,
      processingTimeMs: processingTimeMs,
      status: 'ERROR',
    );
  }

  Future<List<Map<String, Object?>>> getAllMetrics() async {
    return _metrics.getAllMetrics();
  }

  Future<List<Map<String, Object?>>> getMetricsByEndpoint(String endpoint) async {
    final cleanEndpoint = endpoint.trim();

    if (cleanEndpoint.isEmpty) {
      throw Exception('Endpoint cannot be empty.');
    }

    return _metrics.getMetricsByEndpoint(cleanEndpoint);
  }

  Future<int> clearAllMetrics() async {
    return _metrics.deleteAllMetrics();
  }

  Future<T> trackOperation<T>({
    required String endpoint,
    required Future<T> Function() action,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await action();
      stopwatch.stop();

      await logSuccess(
        endpoint: endpoint,
        latencyMs: stopwatch.elapsedMilliseconds.toDouble(),
        processingTimeMs: stopwatch.elapsedMilliseconds.toDouble(),
      );

      return result;
    } catch (_) {
      stopwatch.stop();

      await logFailure(
        endpoint: endpoint,
        latencyMs: stopwatch.elapsedMilliseconds.toDouble(),
        processingTimeMs: stopwatch.elapsedMilliseconds.toDouble(),
      );

      rethrow;
    }
  }
}