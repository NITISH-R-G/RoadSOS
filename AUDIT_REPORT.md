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
