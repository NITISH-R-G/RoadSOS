import 'package:flutter_dotenv/flutter_dotenv.dart';

double _envDouble(String key, double fallback, {double? min, double? max}) {
  final raw = dotenv.env[key]?.trim();
  if (raw == null || raw.isEmpty) return fallback;
  final v = double.tryParse(raw);
  if (v == null) return fallback;
  if (min != null && v < min) return min;
  if (max != null && v > max) return max;
  return v;
}

int _envInt(String key, int fallback, {int? min, int? max}) {
  final raw = dotenv.env[key]?.trim();
  if (raw == null || raw.isEmpty) return fallback;
  final v = int.tryParse(raw);
  if (v == null) return fallback;
  if (min != null && v < min) return min;
  if (max != null && v > max) return max;
  return v;
}

/// Crash tuning values (env-configurable) with safe bounds.
///
/// Env keys (optional):
/// - CRASH_IMPACT_THRESHOLD_MS2
/// - CRASH_MIN_APPROACH_SPEED_KMH
/// - CRASH_STOPPED_SPEED_KMH
/// - CRASH_SUDDEN_DECEL_DELTA_KMH
/// - CRASH_SPEED_HISTORY_HORIZON_MS
/// - CRASH_STILLNESS_STDDEV_MAX_MS2
/// - CRASH_STILLNESS_SAMPLE_WINDOW_MS
/// - CRASH_PRE_IMPACT_LOOKBACK_MS
/// - CRASH_POST_IMPACT_WINDOW_MS
/// - CRASH_INTER_SPIKE_DEBOUNCE_MS
/// - CRASH_SOS_COOLDOWN_MS
class CrashTuning {
  CrashTuning._();

  static double get impactThresholdMs2 =>
      _envDouble('CRASH_IMPACT_THRESHOLD_MS2', 52.0, min: 20.0, max: 160.0);

  static double get minApproachSpeedKmh =>
      _envDouble('CRASH_MIN_APPROACH_SPEED_KMH', 20.0, min: 0.0, max: 160.0);

  static double get stoppedSpeedKmh =>
      _envDouble('CRASH_STOPPED_SPEED_KMH', 8.0, min: 0.0, max: 40.0);

  static double get suddenDecelDeltaKmh =>
      _envDouble('CRASH_SUDDEN_DECEL_DELTA_KMH', 18.0, min: 2.0, max: 120.0);

  static int get speedHistoryHorizonMs =>
      _envInt('CRASH_SPEED_HISTORY_HORIZON_MS', 4000, min: 1000, max: 20000);

  static double get stillnessStdDevMaxMs2 =>
      _envDouble('CRASH_STILLNESS_STDDEV_MAX_MS2', 2.8, min: 0.6, max: 12.0);

  static int get stillnessSampleWindowMs =>
      _envInt('CRASH_STILLNESS_SAMPLE_WINDOW_MS', 1600, min: 400, max: 8000);

  static int get preImpactLookbackMs =>
      _envInt('CRASH_PRE_IMPACT_LOOKBACK_MS', 2000, min: 500, max: 10000);

  static int get postImpactWindowMs =>
      _envInt('CRASH_POST_IMPACT_WINDOW_MS', 1200, min: 300, max: 8000);

  static int get interSpikeDebounceMs =>
      _envInt('CRASH_INTER_SPIKE_DEBOUNCE_MS', 900, min: 100, max: 10000);

  static int get sosCooldownMs =>
      _envInt('CRASH_SOS_COOLDOWN_MS', 45000, min: 5000, max: 10 * 60 * 1000);
}

