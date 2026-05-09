<<<<<<< HEAD
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/app_database.dart';

/// Service to sync emergency facilities from OpenStreetMap (Overpass API).
/// 
/// This ensures the local database has a rich set of hospitals, police stations, 
/// and rescue services for the user's region, enabling full offline operation.
class FacilitySyncService {
  static const String overpassUrl = 'https://overpass-api.de/api/interpreter';
  static const int _syncCooldownMinutes = 30;
  static DateTime? _lastSync;

  Future<void> syncLocalRegion(double lat, double lon, {double radiusKm = 20.0}) async {
    final now = DateTime.now();
    if (_lastSync != null && now.difference(_lastSync!).inMinutes < _syncCooldownMinutes) {
      print('[FacilitySync] ⏳ Rate limiting active. Skipping Overpass query.');
      return;
    }
    _lastSync = now;

    final double delta = radiusKm / 111.0; // Rough conversion: 1 degree approx 111km
    final south = lat - delta;
    final west = lon - delta;
    final north = lat + delta;
    final east = lon + delta;

    final query = '''
      [out:json][timeout:25];
      (
        node["amenity"~"hospital|police|fire_station|ambulance"]($south,$west,$north,$east);
        way["amenity"~"hospital|police|fire_station|ambulance"]($south,$west,$north,$east);
        node["shop"~"car_repair|car"]($south,$west,$north,$east); // For showrooms & puncture shops
      );
      out body;
      >;
      out skel qt;
    ''';

    try {
      print('[FacilitySync] 🌐 Fetching OSM POIs for region ($lat, $lon)...');
      final response = await http.post(
        Uri.parse(overpassUrl),
        body: 'data=${Uri.encodeComponent(query)}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;
        
        int count = 0;
        for (var element in elements) {
          if (element['tags'] != null) {
            await _saveFacility(element);
            count++;
          }
        }
        print('[FacilitySync] ✅ Synced $count facilities from OSM.');
      }
    } catch (e) {
      print('[FacilitySync] ⚠️ Sync failed: $e');
    }
  }

  Future<void> _saveFacility(Map<String, dynamic> element) async {
    final tags = element['tags'];
    final id = element['id'].toString();
    final name = tags['name'] ?? tags['operator'] ?? 'Emergency Facility';
    
    // Determine internal type
    String type = 'emergency';
    if (tags['amenity'] != null) {
      type = tags['amenity'];
    } else if (tags['shop'] == 'car_repair') {
      type = 'puncture_shop';
    } else if (tags['shop'] == 'car') {
      type = 'showroom';
    }

    final lat = element['lat'] ?? (element['center']?['lat']) ?? 0.0;
    final lon = element['lon'] ?? (element['center']?['lon']) ?? 0.0;
    
    if (lat == 0.0) return; // Skip ways without centers for now

    try {
      await appDb.execute(
        'INSERT OR REPLACE INTO emergency_facilities (id, name, type, latitude, longitude, contact_number) VALUES (?, ?, ?, ?, ?, ?)',
        [id, name, type, lat, lon, tags['phone'] ?? tags['contact:phone']]
      );
    } catch (e) {
      // Ignore duplicates
    }
=======
import '../logging/app_log.dart';

/// Facility rows are **not** fetched from Overpass on-device (that violates public API ToS at scale).
///
/// Server-side flow:
/// 1. Supabase Edge Function [sync-osm-facilities] runs on a schedule (cron) and queries Overpass once per job.
/// 2. Rows are upserted into Postgres `public.emergency_facilities`.
/// 3. PowerSync replicates to this app’s SQLite ([appDb]) for offline queries.
///
/// Call [syncLocalRegion] after location is known only to record a *hint* for operators/telemetry.
/// The app itself does not “force sync” facilities; facilities become available when:
/// - bundled seed has been imported, and/or
/// - PowerSync is configured + connected and replicating `emergency_facilities`.
class FacilitySyncService {
  FacilitySyncService();

  /// No longer performs HTTP to Overpass. Facilities arrive via seed + PowerSync from Supabase.
  ///
  /// Returns a status line suitable for debug UI (not a guarantee of facility freshness).
  Future<String> syncLocalRegion(
    double lat,
    double lon, {
    double radiusKm = 20.0,
  }) async {
    appLog.d(
      'Facility cache: server-side OSM ingest + PowerSync (no client Overpass). '
      'Region hint: ($lat,$lon) r=${radiusKm}km',
    );
    return 'Facility sync is cloud/seed-driven (no client Overpass).';
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
  }
}
