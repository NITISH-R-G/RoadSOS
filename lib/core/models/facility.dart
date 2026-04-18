import 'package:latlong2/latlong.dart';

class Facility {
  final String id;
  final String name;
  final String type; // 'hospital', 'fire_station', 'police', etc.
  final double latitude;
  final double longitude;
  final String? contactNumber;
  final String? capabilities;

  const Facility({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.contactNumber,
    this.capabilities,
  });

  LatLng get location => LatLng(latitude, longitude);

  factory Facility.fromMap(Map<String, dynamic> map) {
    return Facility(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown Facility',
      type: map['type'] ?? 'emergency',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      contactNumber: map['contact_number'],
      capabilities: map['capabilities'],
    );
  }
}
