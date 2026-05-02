import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import '../config/map_tile_config.dart';
import '../services/emergency_orchestrator.dart';
import '../services/map_tile_cache.dart';
import '../models/facility.dart';

/// A robust, offline-capable Map widget for RoadSOS.
///
/// Features:
/// - Raster tiles from [MapTileConfig] (defaults to Carto CDN — not OSM.org;
///   supports Mappls/CARTO/self-hosted URLs via env)
/// - Displays user location, reported incidents, and nearby facilities
/// - Supports auto-centering on user location
class RoadSosMap extends StatefulWidget {
  final SOSState state;
  final bool autoCenter;

  const RoadSosMap({
    super.key,
    required this.state,
    this.autoCenter = true,
  });

  @override
  State<RoadSosMap> createState() => _RoadSosMapState();
}

class _RoadSosMapState extends State<RoadSosMap> with TickerProviderStateMixin {
  late final AnimatedMapController _mapController;
  late final TileProvider _tileProvider = _makeTileProvider();

  TileProvider _makeTileProvider() {
    if (kIsWeb || !fmtcMapCacheReady) {
      return NetworkTileProvider();
    }
    return FMTCTileProvider(
      stores: {kFmtcRoadsosOsmStore: BrowseStoreStrategy.readUpdateCreate},
      loadingStrategy: BrowseLoadingStrategy.cacheFirst,
    );
  }

  @override
  void initState() {
    super.initState();
    _mapController = AnimatedMapController(vsync: this);
  }

  @override
  void didUpdateWidget(RoadSosMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoCenter && widget.state.location != null) {
      final loc = widget.state.location!;
      _mapController.animateTo(
        dest: LatLng(loc.latitude, loc.longitude),
        zoom: 15,
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFix = widget.state.location != null &&
        widget.state.location!.source != 'unknown' &&
        !(widget.state.location!.latitude == 0.0 &&
            widget.state.location!.longitude == 0.0);
    final userLoc = hasFix
        ? LatLng(widget.state.location!.latitude, widget.state.location!.longitude)
        : null;

    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController.mapController,
            options: MapOptions(
              initialCenter: userLoc ?? const LatLng(20.5937, 78.9629),
              initialZoom: userLoc != null ? 15 : 4.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: MapTileConfig.effectiveUrlTemplate,
                subdomains: MapTileConfig.effectiveSubdomains,
                userAgentPackageName: 'com.roadsos.app',
                tileProvider: _tileProvider,
              ),
              MarkerLayer(
                markers: [
                  // User Location Marker
                  if (userLoc != null)
                    Marker(
                      point: userLoc,
                      width: 40,
                      height: 40,
                      child: _buildUserMarker(),
                    ),
                  
                  // Incident Markers
                  ..._buildIncidentMarkers(),
                  
                  // Facility Markers (seeded + cloud-synced via PowerSync when configured)
                  ..._buildFacilityMarkers(),
                ],
              ),
            ],
          ),
          Positioned(
            left: 8,
            bottom: 8,
            right: 56,
            child: IgnorePointer(
              child: Text(
                MapTileConfig.attributionLabel,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withOpacity(0.45),
                  shadows: const [
                    Shadow(color: Colors.black54, blurRadius: 4),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Map Overlay Controls
          Positioned(
            right: 12,
            bottom: 12,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.my_location,
                  onTap: () {
                    if (widget.state.location != null) {
                      _mapController.animateTo(
                        dest: userLoc,
                        zoom: 15,
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.add,
                  onTap: () => _mapController.animatedZoomIn(),
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.remove,
                  onTap: () => _mapController.animatedZoomOut(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: const Center(
        child: Icon(Icons.navigation, size: 20, color: Colors.blue),
      ),
    );
  }

  List<Marker> _buildIncidentMarkers() {
    if (widget.state.incidentId == null || widget.state.location == null) return [];
    if (widget.state.location!.source == 'unknown') return [];
    
    return [
      Marker(
        point: LatLng(widget.state.location!.latitude, widget.state.location!.longitude),
        width: 50,
        height: 50,
        child: const Icon(Icons.emergency, color: Colors.red, size: 40),
      ),
    ];
  }

  List<Marker> _buildFacilityMarkers() {
    return widget.state.nearbyFacilities.map((facility) {
      return Marker(
        point: facility.location,
        width: 30,
        height: 30,
        child: _FacilityMarker(facility: facility),
      );
    }).toList();
  }
}

class _FacilityMarker extends StatelessWidget {
  final Facility facility;

  const _FacilityMarker({required this.facility});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (facility.type.toLowerCase()) {
      case 'hospital':
      case 'ambulance':
      case 'primary_health_centre':
        icon = Icons.local_hospital;
        color = Colors.green;
        break;
      case 'fire_station':
        icon = Icons.fire_truck;
        color = Colors.orange;
        break;
      case 'police':
        icon = Icons.local_police;
        color = Colors.blue;
        break;
      case 'towing':
      case 'rescue':
        icon = Icons.car_repair;
        color = Colors.amber;
        break;
      case 'puncture_shop':
      case 'mechanic':
        icon = Icons.build;
        color = Colors.brown;
        break;
      case 'showroom':
        icon = Icons.store;
        color = Colors.purple;
        break;
      default:
        icon = Icons.place;
        color = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${facility.name} (${facility.type})'
              '${facility.dataSource != null ? ' · ${facility.dataSource}' : ''}',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
