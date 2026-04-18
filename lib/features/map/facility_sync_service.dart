import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/database/app_database.dart';

/// Service to sync emergency facilities from OpenStreetMap (Overpass API).
/// 
/// This ensures the local database has a rich set of hospitals, police stations, 
/// and rescue services for the user's region, enabling full offline operation.
class FacilitySyncService {
  static const String overpassUrl = 'https://overpass-api.de/api/interpreter';

  Future<void> syncLocalRegion(double lat, double lon, {double radiusKm = 20.0}) async {
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
  }
}
