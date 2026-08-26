import 'package:latlong2/latlong.dart';

class Facility {
  final String id;
  final String name;
  final String type; // 'hospital', 'fire_station', 'police', etc.
  final double latitude;
  final double longitude;
  final String? contactNumber;
  final String? capabilities;

  /// gov_nhm | gov_ayushman | osm | merged
  final String? dataSource;

  const Facility({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.contactNumber,
    this.capabilities,
    this.dataSource,
  });

  LatLng get location => LatLng(latitude, longitude);

  factory Facility.fromMap(Map<String, dynamic> map) {
    return Facility(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown Facility',
      // ⚡ Bolt Optimization: Normalize type to lowercase during parsing instead of in the UI render loop.
      // This saves O(N) redundant string allocations per frame when drawing N map markers.
      type: (map['type'] as String? ?? 'emergency').toLowerCase(),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      contactNumber: map['contact_number'],
      capabilities: map['capabilities'],
      dataSource: map['data_source'] as String?,
    );
  }
}
