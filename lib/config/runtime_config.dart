import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../logging/app_log.dart';

/// Bootstraps runtime configuration without bundling secrets as app assets.
///
/// Production: prefer `--dart-define=KEY=VALUE` (and friends) via CI/CD.
/// Dev: place a non-committed `.env` file in the project root when running `flutter run` locally.
///
/// Key architecture:
/// - GEMMA_API_KEY is set as a Supabase Edge Function secret (never on the client).
/// - TWILIO_* credentials are set as Supabase Edge Function secrets.
/// - SUPABASE_URL + SUPABASE_ANON_KEY are the only credentials on the mobile client.
class RuntimeConfig {
  RuntimeConfig._();

  static Future<void> bootstrap() async {
    try {
      dotenv.env.clear();
    } catch (_) {}

    if (!kReleaseMode) {
      try {
        await dotenv.load(fileName: '.env');
        appLog.i('Loaded local .env for development');
      } catch (_) {}
    }

    // ── Backend / cloud ────────────────────────────────────────────────────
    _setIfDefined('SUPABASE_URL');
    _setIfDefined('SUPABASE_ANON_KEY');
    _setIfDefined('POWERSYNC_URL');

    // ── SMS dispatch ───────────────────────────────────────────────────────
    _setIfDefined('SMS_DISPATCH_URL');
    _setIfDefined('SMS_DISPATCH_ANON_KEY');
    _setIfDefined('SMS_RELAY_COUNTS_AS_PRIMARY_DISPATCH');

    // ── India-specific routing ─────────────────────────────────────────────
    _setIfDefined('INDIA_SOS_DISPATCH_URL');
    _setIfDefined('INDIA_ERSS_API_URL');
    _setIfDefined('INDIA_ERSS_API_KEY');
    _setIfDefined('INDIA_EMERGENCY_USSD');
    _setIfDefined('INDIA_AUTO_DIAL_AMBULANCE');

    // ── Emergency number overrides ─────────────────────────────────────────
    _setIfDefined('EMERGENCY_NUMBER_OVERRIDE');
    _setIfDefined('EMERGENCY_NUMBER_FALLBACK');

    // ── Map ────────────────────────────────────────────────────────────────
    _setIfDefined('MAP_TILE_URL_TEMPLATE');

    // ── Crash detection tuning ─────────────────────────────────────────────
    // All keys consumed by CrashTuning. Previously these were wired in
    // CrashTuning but never passed through RuntimeConfig, so --dart-define
    // values were silently ignored. Fixed here.
    _setIfDefined('CRASH_IMPACT_THRESHOLD_MS2');
    _setIfDefined('CRASH_MIN_APPROACH_SPEED_KMH');
    _setIfDefined('CRASH_STOPPED_SPEED_KMH');
    _setIfDefined('CRASH_SUDDEN_DECEL_DELTA_KMH');
    _setIfDefined('CRASH_SPEED_HISTORY_HORIZON_MS');
    _setIfDefined('CRASH_STILLNESS_STDDEV_MAX_MS2');
    _setIfDefined('CRASH_STILLNESS_SAMPLE_WINDOW_MS');
    _setIfDefined('CRASH_PRE_IMPACT_LOOKBACK_MS');
    _setIfDefined('CRASH_POST_IMPACT_WINDOW_MS');
    _setIfDefined('CRASH_INTER_SPIKE_DEBOUNCE_MS');
    _setIfDefined('CRASH_SOS_COOLDOWN_MS');

    // ── Connectivity-aware triage ──────────────────────────────────────────
    // Set to 'false' to always attempt Tier 1 cloud even when offline probe says no.
    _setIfDefined('CONNECTIVITY_AWARE_TRIAGE');
  }

  static void _setIfDefined(String key) {
    final value = _readDefine(key);
    if (value == null || value.trim().isEmpty) return;
    dotenv.env[key] = value.trim();
  }

  static String? _readDefine(String key) {
    switch (key) {
      case 'SUPABASE_URL':
        return const String.fromEnvironment('SUPABASE_URL');
      case 'SUPABASE_ANON_KEY':
        return const String.fromEnvironment('SUPABASE_ANON_KEY');
      case 'POWERSYNC_URL':
        return const String.fromEnvironment('POWERSYNC_URL');
      case 'SMS_DISPATCH_URL':
        return const String.fromEnvironment('SMS_DISPATCH_URL');
      case 'SMS_DISPATCH_ANON_KEY':
        return const String.fromEnvironment('SMS_DISPATCH_ANON_KEY');
      case 'SMS_RELAY_COUNTS_AS_PRIMARY_DISPATCH':
        return const String.fromEnvironment('SMS_RELAY_COUNTS_AS_PRIMARY_DISPATCH');
      case 'INDIA_SOS_DISPATCH_URL':
        return const String.fromEnvironment('INDIA_SOS_DISPATCH_URL');
      case 'INDIA_ERSS_API_URL':
        return const String.fromEnvironment('INDIA_ERSS_API_URL');
      case 'INDIA_ERSS_API_KEY':
        return const String.fromEnvironment('INDIA_ERSS_API_KEY');
      case 'INDIA_EMERGENCY_USSD':
        return const String.fromEnvironment('INDIA_EMERGENCY_USSD');
      case 'INDIA_AUTO_DIAL_AMBULANCE':
        return const String.fromEnvironment('INDIA_AUTO_DIAL_AMBULANCE');
      case 'EMERGENCY_NUMBER_OVERRIDE':
        return const String.fromEnvironment('EMERGENCY_NUMBER_OVERRIDE');
      case 'EMERGENCY_NUMBER_FALLBACK':
        return const String.fromEnvironment('EMERGENCY_NUMBER_FALLBACK');
      case 'MAP_TILE_URL_TEMPLATE':
        return const String.fromEnvironment('MAP_TILE_URL_TEMPLATE');
      // Crash tuning
      case 'CRASH_IMPACT_THRESHOLD_MS2':
        return const String.fromEnvironment('CRASH_IMPACT_THRESHOLD_MS2');
      case 'CRASH_MIN_APPROACH_SPEED_KMH':
        return const String.fromEnvironment('CRASH_MIN_APPROACH_SPEED_KMH');
      case 'CRASH_STOPPED_SPEED_KMH':
        return const String.fromEnvironment('CRASH_STOPPED_SPEED_KMH');
      case 'CRASH_SUDDEN_DECEL_DELTA_KMH':
        return const String.fromEnvironment('CRASH_SUDDEN_DECEL_DELTA_KMH');
      case 'CRASH_SPEED_HISTORY_HORIZON_MS':
        return const String.fromEnvironment('CRASH_SPEED_HISTORY_HORIZON_MS');
      case 'CRASH_STILLNESS_STDDEV_MAX_MS2':
        return const String.fromEnvironment('CRASH_STILLNESS_STDDEV_MAX_MS2');
      case 'CRASH_STILLNESS_SAMPLE_WINDOW_MS':
        return const String.fromEnvironment('CRASH_STILLNESS_SAMPLE_WINDOW_MS');
      case 'CRASH_PRE_IMPACT_LOOKBACK_MS':
        return const String.fromEnvironment('CRASH_PRE_IMPACT_LOOKBACK_MS');
      case 'CRASH_POST_IMPACT_WINDOW_MS':
        return const String.fromEnvironment('CRASH_POST_IMPACT_WINDOW_MS');
      case 'CRASH_INTER_SPIKE_DEBOUNCE_MS':
        return const String.fromEnvironment('CRASH_INTER_SPIKE_DEBOUNCE_MS');
      case 'CRASH_SOS_COOLDOWN_MS':
        return const String.fromEnvironment('CRASH_SOS_COOLDOWN_MS');
      // Connectivity
      case 'CONNECTIVITY_AWARE_TRIAGE':
        return const String.fromEnvironment('CONNECTIVITY_AWARE_TRIAGE');
    }
    return null;
  }
}
