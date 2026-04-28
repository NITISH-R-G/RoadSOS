import '../logging/app_log.dart';

/// Facility rows are **not** fetched from Overpass on-device (that violates public API ToS at scale).
///
/// Server-side flow:
/// 1. Supabase Edge Function [sync-osm-facilities] runs on a schedule (cron) and queries Overpass once per job.
/// 2. Rows are upserted into Postgres `public.emergency_facilities`.
/// 3. PowerSync replicates to this app’s SQLite ([appDb]) for offline queries.
///
/// Call [syncLocalRegion] after location is known only to log intent; sync is automatic when PowerSync is connected.
class FacilitySyncService {
  FacilitySyncService();

  /// No longer performs HTTP to Overpass. Facilities arrive via PowerSync from Supabase.
  Future<void> syncLocalRegion(double lat, double lon, {double radiusKm = 20.0}) async {
    appLog.d(
      'Facility cache: server-side OSM ingest + PowerSync (no client Overpass). '
      'Region hint: ($lat,$lon) r=${radiusKm}km',
    );
  }
}
