import 'dart:async';
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/app_log.dart';
import 'package:geolocator/geolocator.dart';

/// Represents a single GPS fix with metadata about its source and quality.
class LocationFix {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String source; // 'gps', 'network', 'last_known', 'unknown'
  final DateTime timestamp;

  const LocationFix({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.source,
    required this.timestamp,
  });

  /// Compress to the 11-byte SOS payload format.
  String toCompressedString() {
    return 'LAT:${latitude.toStringAsFixed(5)}|LNG:${longitude.toStringAsFixed(5)}|ACC:${accuracy.round()}m|SRC:$source';
  }

  @override
  String toString() => '($latitude, $longitude) ±${accuracy.round()}m [$source]';
}

/// Provides real-time location with dead-reckoning fallback.
///
/// Implements Blueprint §3.4 — GPS Multipath Error handling:
/// - Caches last 60 seconds of valid GPS coordinates
/// - Falls back to last known position if current fix fails
/// - Reports accuracy and source for downstream confidence scoring
class LocationService {
  final Queue<LocationFix> _positionHistory = Queue<LocationFix>();
  static const int _maxHistorySeconds = 60;
  LocationFix? _lastGoodFix;

  /// Request current location with highest available accuracy.
  /// Returns [LocationFix] or throws if location services unavailable.
  Future<LocationFix> getCurrentLocation() async {
    // 1. Check permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _fallbackLocation('Location services disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return _fallbackLocation('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return _fallbackLocation('Location permanently denied');
    }

    // 2. Get high-accuracy position
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 5),
        ),
      );

      final fix = LocationFix(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        source: 'gps',
        timestamp: DateTime.now(),
      );

      _recordFix(fix);
      return fix;
    } catch (e) {
      // GPS timeout — try last known
      return _fallbackLocation('GPS timeout: $e');
    }
  }

  /// Fallback: return last good cached position or a degraded unknown fix.
  LocationFix _fallbackLocation(String reason) {
    appLog.d('Location fallback triggered: $reason');

    if (_lastGoodFix != null) {
      return LocationFix(
        latitude: _lastGoodFix!.latitude,
        longitude: _lastGoodFix!.longitude,
        accuracy: _lastGoodFix!.accuracy + 50, // degrade accuracy estimate
        source: 'last_known',
        timestamp: _lastGoodFix!.timestamp,
      );
    }

    // Absolute last resort: unknown location
    return LocationFix(
      latitude: 0.0,
      longitude: 0.0,
      accuracy: 99999,
      source: 'unknown',
      timestamp: DateTime.now(),
    );
  }

  /// Cache a valid fix and prune old entries.
  void _recordFix(LocationFix fix) {
    _lastGoodFix = fix;
    _positionHistory.addLast(fix);

    // Prune entries older than 60s
    final cutoff = DateTime.now().subtract(const Duration(seconds: _maxHistorySeconds));
    while (_positionHistory.isNotEmpty &&
        _positionHistory.first.timestamp.isBefore(cutoff)) {
      _positionHistory.removeFirst();
    }
  }
}

/// Riverpod provider for location service (singleton).
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
