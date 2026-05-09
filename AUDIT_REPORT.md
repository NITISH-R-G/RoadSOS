# Audit Report: RoadSOS (Updated May 2026)

This document tracks identified issues and their resolution status.

---

## Critical Issues — RESOLVED

### ✅ FIXED: Used Gemini Flash instead of Gemma 4
**Was:** `gemini-2.0-flash` (closed proprietary model — not Gemma)
**Fix:** All AI inference now uses `gemma-4-27b-it` (cloud) and `gemma-4-e4b-it` (on-device).
- `supabase/functions/triage-gemini/index.ts` — updated to `gemma-4-27b-it` with `gemma-3-27b-it` fallback
- `supabase/functions/gemini-generate/index.ts` — updated to `gemma-4-27b-it`
- `lib/services/gemini_http.dart` — updated model default
- `lib/services/ai_triage_service.dart` — rebuilt as 4-tier Gemma 4 pipeline

### ✅ FIXED: On-device AI was keyword matching, not a model
**Was:** `OfflineTriageClassifier` — pure string `.contains()` checks
**Fix:** Added `GemmaLocalService` — Gemma 4 E4B (Edge 4B) via `flutter_gemma` / LiteRT as Tier 2. Keyword classifier is now Tier 4 (last resort only). See `lib/services/gemma_local_service.dart`.

### ✅ FIXED: SMS dispatch required user to tap send
**Was:** `url_launcher` opening `sms:112` URI — requires conscious user.
**Fix:** Added `supabase/functions/sms-dispatch/index.ts` — Twilio-based server-side SMS dispatch. No user interaction required. Works even if victim is unconscious. Android direct SEND_SMS remains as device-level fallback.

### ✅ FIXED: Supabase auth was silently failing
**Was:** `currentSession` always null — PowerSync never synced.
**Fix:** `lib/database/app_database.dart` already has `signInAnonymously()` — verified present and correct. Documented clearly.

### ✅ FIXED: Client was directly querying Overpass API (ToS violation at scale)
**Was:** Mobile client calling `overpass-api.de` directly.
**Fix:** `lib/services/facility_sync_service.dart` — no client Overpass queries. `supabase/functions/sync-osm-facilities/index.ts` runs server-side (cron job). Clients receive data via PowerSync.

### ✅ FIXED: First Aid "RAG" was 5 hardcoded strings
**Was:** Literal dictionary of 5 strings.
**Fix:** `lib/services/first_aid_repository.dart` uses SQLite FTS5 full-text search against the bundled `assets/first_aid/corpus.json`. Token scoring fallback for web.

### ✅ FIXED: Hardcoded credentials in source
**Was:** Supabase URL/key in Dart source code.
**Fix:** All credentials via `flutter_dotenv` (`.env` file, never committed) or `--dart-define` in CI. Supabase function secrets (GEMMA_API_KEY, Twilio) never reach the client.

---

## High Issues — RESOLVED

### ✅ FIXED: No GEMMA_API_KEY env var
**Fix:** `assets/env.template` updated with clear documentation. Edge functions use `GEMMA_API_KEY` (set as Supabase secret, never on client).

### ✅ FIXED: Overpass API would get IP-banned at scale
**Fix:** Server-side cron via `sync-osm-facilities` edge function. PowerSync replicates to clients.

---

## Automation

- **CI:** `.github/workflows/flutter_ci.yml` runs `dart analyze` + `flutter test` on every push/PR to `main`.
- **Docs:** `docs/BLUEPRINT_GAP_ANALYSIS.md` is reconciled with the Gemma 4 stack — do not revert outdated “Gemini-only” rows without verifying code.

## Remaining Known Gaps (not blocking hackathon submission)

### 🔶 Background crash detection reliability
- **Android**: Multi-stage crash detection (accel + GPS speed + stillness) works with foreground service.
- **iOS**: Severely limited by OS background execution policy. System Crash Detection (Apple) is not exposed to third-party apps. RoadSOS crash detection works while app is active.
- **Fix priority**: Post-hackathon — requires iOS background mode entitlements review.

### 🔶 BLE mesh requires both devices to have app running
- Background BLE scanning on iOS requires specific entitlements.
- Android foreground service can keep scanning alive.
- **Impact**: Mesh is a "bonus channel" — SMS dispatch via Twilio is the primary automated path.

### 🔶 On-device Gemma 4 E4B requires ~2.4 GB download
- Model must be pre-downloaded during onboarding.
- For hackathon demo: pre-load the model file before recording.
- Long-term: progressive download with delta updates.

### 🔶 No Play Store / App Store listing
- `publish_to: 'none'` is for pub.dev package publishing, not app stores.
- App store submission requires privacy review, medical disclaimer, and production Supabase setup.

### 🔶 No professional human dispatch loop
- Currently: automated SMS to 112 + Twilio relay.
- Missing: confirmed callback from dispatch center.
- Long-term: API partnership with India's ERSS/112 system.

---

## Architecture Summary (Post-Fix)

```
SOS Trigger (tap / crash detection)
    ↓
EmergencyOrchestrator
    ↓ [parallel]
┌─────────────────────────────────────┐
│ Gemma 4 Triage Stack                │
│   Tier 1: gemma-4-27b-it (cloud)   │ ← 3s timeout
│   Tier 2: gemma-4-e4b-it (device)  │ ← 8s timeout, offline-capable
│   Tier 3: Weighted heuristic        │ ← always available
│   Tier 4: Keyword classifier        │ ← last resort
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ Dispatch Channels (parallel)        │
│   SMS: Twilio edge fn (automated)  │ ← no user tap needed
│   SMS: Android SEND_SMS (fallback) │
│   BLE: Encrypted mesh beacon       │
│   DB: PowerSync → Supabase         │
│   Family: tracking link            │
└─────────────────────────────────────┘
```
