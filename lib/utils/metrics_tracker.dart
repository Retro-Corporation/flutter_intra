import 'dart:developer' as dev;
import 'dart:math';

class MetricsTracker {
  static final MetricsTracker instance = MetricsTracker._internal();
  MetricsTracker._internal();

  final Map<String, List<int>> _latencies = {};
  final Map<String, int> _counters = {};

  void recordLatency(String name, int valueMs) {
    _latencies.putIfAbsent(name, () => []);
    _latencies[name]!.add(valueMs);
  }

  void increment(String name, [int value = 1]) {
    _counters[name] = (_counters[name] ?? 0) + value;
  }

  // ✅ NEW: read counters safely
  int getCounter(String name) => _counters[name] ?? 0;

  // ✅ NEW: check if latency exists
  bool hasLatency(String name) => (_latencies[name]?.isNotEmpty ?? false);

  double avg(String name) {
    final list = _latencies[name];
    if (list == null || list.isEmpty) return 0;
    return list.reduce((a, b) => a + b) / list.length;
  }

  int minValue(String name) {
    final list = _latencies[name];
    if (list == null || list.isEmpty) return 0;
    return list.reduce(min);
  }

  int maxValue(String name) {
    final list = _latencies[name];
    if (list == null || list.isEmpty) return 0;
    return list.reduce(max);
  }

  double percentile(String name, double p) {
    final list = _latencies[name];
    if (list == null || list.isEmpty) return 0;

    final sorted = List<int>.from(list)..sort();
    final index = ((sorted.length - 1) * p).round();
    return sorted[index].toDouble();
  }

  void reset() {
    _latencies.clear();
    _counters.clear();
  }

  void printSummary() {
    dev.log("========= PERFORMANCE METRICS =========");

    _latencies.forEach((name, values) {
      final avgVal = avg(name).toStringAsFixed(2);
      final minVal = minValue(name);
      final maxVal = maxValue(name);
      final p95 = percentile(name, 0.95).toStringAsFixed(2);

      dev.log("$name | samples: ${values.length} | avg: $avgVal ms | min: $minVal | max: $maxVal | p95: $p95");
    });

    _counters.forEach((name, value) {
      dev.log("$name : $value");
    });

    dev.log("=======================================");
  }
}