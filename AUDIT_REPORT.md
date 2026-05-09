<<<<<<< HEAD
# Deep Forensic Audit Report: RoadSOS

**Auditor:** Senior Product Auditor, UX Strategist, Systems Architect, & Startup CTO
**Date:** Current
**Target:** RoadSOS Application (Flutter/Dart Codebase + Native Modules)

## Executive Summary
RoadSOS is a conceptually ambitious application that looks polished on the surface but is fundamentally broken underneath. It is heavily reliant on “smoke and mirrors” (hardcoded placeholders, simulated AI, and UI-only features). The current architecture violates platform constraints (iOS/Android background limitations), relies on unsustainable infrastructure (public Overpass/OSM APIs), and would fail catastrophically in a real-world emergency scenario. It cannot be launched publicly and requires a significant architectural rewrite.

---

## 1. Features that look functional but cannot work in real-world production

**A. Background Hardware SOS Trigger (`MainActivity.kt` & `HardwareTriggerService`)**
*   **The Issue:** The volume button trigger relies on overriding `onKeyDown` within `MainActivity.kt`.
*   **Real-World Impact:** This ONLY works when the app is open and in the foreground. If the phone is locked, in a pocket, or the app is in the background, pressing the volume buttons does nothing. A user in a crash cannot be expected to unlock their phone, open the app, and *then* press the hardware buttons.
*   **Solution:** On Android, this requires an Accessibility Service or a persistent Foreground Service listening to Media Session events. On iOS, intercepting global hardware buttons is strictly prohibited by Apple. The feature must be re-engineered using supported SOS APIs (like Apple's Crash Detection integration or Android's Personal Safety APIs).

**B. Fake Edge AI Triage (`AiTriageService`)**
*   **The Issue:** The code simulates loading a Gemma 4 2B model using a `Future.delayed` and hardcoded string responses. The `llamadart` implementation is completely commented out.
*   **Real-World Impact:** The core value proposition—Edge AI triage—does not exist. Furthermore, loading a 1.5GB+ GGUF model into memory on low-end Android devices (which make up the majority of global users) will cause out-of-memory (OOM) crashes, especially when the device is thermally throttling or damaged in a crash.
*   **Solution:** Remove the fake simulation. Implement a cloud-first LLM triage with a lightweight heuristic-based fallback (the "degraded mode") on-device.

**C. SMS Fallback Requires User Interaction (`MeshNetworkService.triggerSmsFallback`)**
*   **The Issue:** The app uses `url_launcher` to open the `sms:112` URI.
*   **Real-World Impact:** This merely opens the user's SMS app and pre-fills the text. It *requires the user to manually press the send button*. If the user is unconscious or trapped, the SOS is never dispatched.
*   **Solution:** For true automated background SMS on Android, the app needs the `SEND_SMS` permission (which requires a rigorous Google Play policy review). On iOS, background SMS is impossible without user interaction; fallbacks must rely on data connectivity to a backend service (e.g., Twilio) which then dispatches the SMS to authorities.

---

## 2. UX patterns that create confusion, friction, or perceived gimmicks

**A. First Aid RAG is a Hardcoded Map (`FirstAidStore`)**
*   **The Issue:** The "verified medical advice" is a hardcoded dictionary of exactly 5 strings.
*   **Real-World Impact:** Users relying on this for critical first aid will find it entirely useless for any query not exactly matching the 5 predefined scenarios. It creates a false sense of security.
*   **Solution:** Integrate a real vector database (e.g., ObjectBox or SQLite with vector extensions) synced with a legitimate medical database.

---

## 3. Missing backend logic or incomplete system design

**A. No Authentication for PowerSync (`app_database.dart`)**
*   **The Issue:** `SupabaseConnector.fetchCredentials()` attempts to get a token from `db.auth.currentSession`. However, there is no authentication UI or anonymous login implemented in the app.
*   **Real-World Impact:** The `currentSession` will always be null. PowerSync will silently fail to sync incidents to Supabase. The app effectively operates 100% offline with zero cloud backup.
*   **Solution:** Implement an anonymous sign-in flow (`Supabase.instance.client.auth.signInAnonymously()`) on app launch to ensure a valid session exists for PowerSync.

---

## 4. Scalability limitations preventing global adoption

**A. DDoSing the Public Overpass API (`FacilitySyncService`)**
*   **The Issue:** The app directly queries `https://overpass-api.de/api/interpreter` from the client.
*   **Real-World Impact:** The Overpass API strictly limits requests and forbids heavy automated usage by mobile apps. If the app scales to even a few thousand active users, it will be IP-banned, breaking the facility sync feature globally.
*   **Solution:** Move the Overpass query to a backend cron job that caches facility data in Supabase. The mobile app should solely sync via PowerSync from your own Supabase tables.

**B. Violating OpenStreetMap Tile Usage Policy (`RoadSosMap`)**
*   **The Issue:** Direct usage of `https://tile.openstreetmap.org/{z}/{x}/{y}.png`.
*   **Real-World Impact:** Similar to Overpass, OSM tile servers will block the app at scale.
*   **Solution:** Use a commercial tile provider (Mapbox, Google Maps, or a self-hosted Protomaps instance).

---

## 5. Security, privacy, or compliance risks

**A. Hardcoded Supabase Credentials (`app_database.dart`)**
*   **The Issue:** `Supabase.initialize` contains hardcoded `url` and `anonKey`.
*   **Real-World Impact:** Anyone can decompile the APK, extract the keys, and write arbitrary data to the database, polluting emergency incident reports.
*   **Solution:** Move these to environment variables (e.g., using `flutter_dotenv`) and implement Row Level Security (RLS) on the Supabase backend.

---

## 6. Infrastructure or performance bottlenecks

**A. Naive Crash Detection Causes False Positives (`CrashDetectionService`)**
*   **The Issue:** It triggers an SOS simply if the accelerometer registers > 25G.
*   **Real-World Impact:** Dropping a phone onto a hard floor, or hitting a severe pothole, can easily spike over 25G momentarily. This will result in massive false positives, irritating users and spamming emergency networks.
*   **Solution:** Implement a multi-stage heuristic: High-G impact followed by absolute stillness (device at rest) or integration of gyroscope and GPS speed data to confirm a vehicle was in motion prior to the impact.

---

## 7. Dead flows, broken navigation paths, or logical inconsistencies

**A. Mesh Network "Scanning" is a Dead End (`MeshNetworkService`)**
*   **The Issue:** `listenForSosBeacons` scans for 15 seconds when called, but it is never actually called anywhere in the app lifecycle. Furthermore, no one is constantly scanning in the background.
*   **Real-World Impact:** The BLE mesh network feature exists only in code and is never activated to receive signals, meaning broadcasting a beacon is effectively shouting into the void.
*   **Solution:** Implement a background scanning service (within Android/iOS limits) or remove the claim of a mesh network.

---

## Conclusion
RoadSOS is currently a prototype masquerading as a production app. To prepare for global public launch, the team must prioritize replacing all simulated components with actual logic, moving away from public/hobbyist APIs, securing the database, and fundamentally rethinking the hardware trigger and SMS fallback to align with mobile OS limitations.
=======
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
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
