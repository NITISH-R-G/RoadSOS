import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../logging/app_log.dart';

/// ObjectBox-backed OSM tile store for [flutter_map] (`flutter_map_tile_caching`).
const String kFmtcRoadsosOsmStore = 'roadsos_osm';

bool fmtcMapCacheReady = false;

/// Initialise FMTC before [runApp]. Safe to skip on web (unsupported).
///
/// On Android, we use an explicit sub-directory in the app's documents folder
/// to avoid conflicts with other native stores (like SQLite/PowerSync).
Future<void> initializeFmtcMapCache() async {
  if (kIsWeb) return;
  if (fmtcMapCacheReady) return;
  try {
    // FMTC 10+ requires an explicit backend initialization.
    // We provide a dedicated directory for the tile cache.
    final docDir = await getApplicationDocumentsDirectory();
    final String cachePath = join(docDir.path, 'fmtc_root');
    final Directory cacheDir = Directory(cachePath);
    
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    // Explicitly pass the String path to avoid Directory vs String ambiguity
    await FMTCObjectBoxBackend().initialise(rootDirectory: cachePath);
    
    // Ensure the store is created.
    await FMTCStore(kFmtcRoadsosOsmStore).manage.create();
    
    fmtcMapCacheReady = true;
    appLog.i('[FMTC] Map cache backend initialized at $cachePath');
  } catch (e, st) {
    fmtcMapCacheReady = false;
    appLog.e(
      '[FMTC] Map cache init failed — maps will use network tiles only',
      error: e,
      stackTrace: st,
    );
  }
}
