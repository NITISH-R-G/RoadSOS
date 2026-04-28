# RoadSOS Supabase backend

## Migrations

Apply with Supabase CLI (`supabase db push`) or paste into the SQL editor in order:

1. `20260428120000_emergency_facilities.sql` — OSM-derived facility rows replicated to the app via PowerSync.
2. `20260428120001_incident_retention.sql` — retention columns + purge function for `reported_incidents`.

## Edge Function: `sync-osm-facilities`

Runs **Overpass queries on the server** only (clients must not hit Overpass at scale).

1. Deploy: `supabase functions deploy sync-osm-facilities`
2. Secrets (Dashboard → Edge Functions → Secrets): `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are injected automatically when deployed via CLI; optionally set:
   - `SYNC_BBOX` — JSON bbox, e.g. `{"south":8,"west":68,"north":37.5,"east":97.5}` (defaults to a rough India box).
   - `OVERPASS_URL` — defaults to `https://overpass-api.de/api/interpreter`.
3. Schedule periodic runs (Dashboard **Edge Functions → sync-osm-facilities → Schedule**, or pg_cron / external cron POST to `/functions/v1/sync-osm-facilities` with auth).

## PowerSync

In the PowerSync dashboard, publish **`public.emergency_facilities`** so offline clients receive facility rows after Postgres upserts. Align RLS with your connector (anon read is allowed in the migration policy for `SELECT`).
