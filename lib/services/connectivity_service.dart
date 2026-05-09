import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../logging/app_log.dart';

/// Network quality as seen by the emergency dispatch pipeline.
/// Determines which triage tier to attempt first.
enum NetworkQuality {
  /// No connectivity — skip cloud calls entirely, go straight to on-device tier.
  none,

  /// Cellular (2G/3G/4G/5G) — attempt cloud with tight timeout.
  cellular,

  /// WiFi or Ethernet — attempt cloud with standard timeout.
  wifi,
}

/// Monitors device network state and broadcasts changes.
///
/// Consumed by [AiTriageService] to decide whether to attempt Tier 1 cloud
/// before the 5-second timeout fires. On Indian highways, ~80% of crashes
/// happen in cellular-dead or edge-signal zones. Probing first saves up to
/// 5 seconds off total SOS dispatch time — critical in the golden hour.
class ConnectivityService {
  ConnectivityService() {
    _init();
  }

  NetworkQuality _quality = NetworkQuality.cellular;
  final _controller = StreamController<NetworkQuality>.broadcast();

  NetworkQuality get currentQuality => _quality;
  Stream<NetworkQuality> get qualityStream => _controller.stream;

  /// Returns true when any network path is available.
  bool get isOnline => _quality != NetworkQuality.none;

  StreamSubscription<List<ConnectivityResult>>? _sub;

  void _init() {
    // Probe current state immediately.
    Connectivity().checkConnectivity().then(_updateFromResults).catchError((e) {
      appLog.w('[Connectivity] Initial probe failed', error: e);
    });

    // Listen for changes.
    _sub = Connectivity().onConnectivityChanged.listen(
      _updateFromResults,
      onError: (e) => appLog.w('[Connectivity] Stream error', error: e),
    );
  }

  void _updateFromResults(List<ConnectivityResult> results) {
    final q = _qualityFromResults(results);
    _quality = q;
    appLog.d('[Connectivity] Network quality → ${q.name}');
    
    // Perform active reachability probe if not 'none'.
    if (q != NetworkQuality.none) {
      _probeInternetAccess();
    } else {
      if (!_controller.isClosed) _controller.add(q);
    }
  }

  Future<void> _probeInternetAccess() async {
    try {
      // Use a fast HEAD request to a reliable endpoint to verify actual reachability.
      // This detects 'connected but no internet' scenarios common on highway Wi-Fi.
      final response = await http
          .head(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 2));
      
      final realQuality = response.statusCode >= 200 && response.statusCode < 400
          ? _quality
          : NetworkQuality.none;
          
      if (!_controller.isClosed) _controller.add(realQuality);
      if (realQuality == NetworkQuality.none) {
        appLog.w('[Connectivity] Radio connected but internet unreachable — forcing offline mode.');
      }
    } catch (_) {
      if (!_controller.isClosed) _controller.add(NetworkQuality.none);
    }
  }

  NetworkQuality _qualityFromResults(List<ConnectivityResult> results) {
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      return NetworkQuality.none;
    }
    if (results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet)) {
      return NetworkQuality.wifi;
    }
    return NetworkQuality.cellular;
  }

  void dispose() {
    _sub?.cancel();
    if (!_controller.isClosed) _controller.close();
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final svc = ConnectivityService();
  ref.onDispose(svc.dispose);
  return svc;
});
