import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../logging/app_log.dart';

/// Bootstraps runtime configuration without bundling secrets as app assets.
///
/// Production: prefer `--dart-define=SUPABASE_URL=...` (and friends) via CI/CD.
/// Dev: you may optionally place a non-committed `.env` file in the project root
/// when running `flutter run` locally.
class RuntimeConfig {
  RuntimeConfig._();

  static Future<void> bootstrap() async {
    // Clear any prior dotenv state.
    try {
      dotenv.env.clear();
    } catch (_) {}

    // In debug/dev, allow loading from a local `.env` file when present.
    if (!kReleaseMode) {
      try {
        // Not bundled; relies on developer machine only.
        await dotenv.load(fileName: '.env');
        appLog.i('Loaded local .env for development');
      } catch (_) {
        // Silent: local .env is optional in dev.
      }
    }

    // Directly read known keys from dart-defines.
    _setIfDefined('SUPABASE_URL');
    _setIfDefined('SUPABASE_ANON_KEY');
    _setIfDefined('POWERSYNC_URL');
    _setIfDefined('SMS_DISPATCH_URL');
    _setIfDefined('SMS_DISPATCH_ANON_KEY');
    _setIfDefined('INDIA_SOS_DISPATCH_URL');
    _setIfDefined('INDIA_ERSS_API_URL');
    _setIfDefined('INDIA_ERSS_API_KEY');
    _setIfDefined('INDIA_EMERGENCY_USSD');
    _setIfDefined('INDIA_AUTO_DIAL_AMBULANCE');
    _setIfDefined('EMERGENCY_NUMBER_OVERRIDE');
    _setIfDefined('EMERGENCY_NUMBER_FALLBACK');
    _setIfDefined('MAP_TILE_URL_TEMPLATE');
    _setIfDefined('SMS_RELAY_COUNTS_AS_PRIMARY_DISPATCH');
  }

  static void _setIfDefined(String key) {
    // Dart doesn't allow dynamic fromEnvironment lookup; list keys explicitly above.
    // Each call reads a compile-time constant by name.
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
      case 'SMS_RELAY_COUNTS_AS_PRIMARY_DISPATCH':
        return const String.fromEnvironment('SMS_RELAY_COUNTS_AS_PRIMARY_DISPATCH');
    }
    return null;
  }
}

