# RoadSOS — Flutter Emergency App

Road emergency response app for Indian highways. Built for the **Gemma 4 Good Hackathon** on Kaggle.

## Stack

- **Flutter** 3.11+ / Dart
- **State**: Riverpod 2.5 (StateNotifier, Provider, autoDispose intentionally avoided for session-persistent services)
- **AI**: Gemma 4 E4B on-device via flutter_gemma / MediaPipe LiteRT (Tier 2); cloud Gemma 4 27B (Tier 1)
- **Sensors**: sensors_plus 7.0 (accelerometer + gyroscope), geolocator 14
- **BLE Mesh**: flutter_blue_plus + flutter_ble_peripheral + BlePayloadCodec (12-byte compact payload)
- **Backend**: Supabase (auth + incident_live_links table), PowerSync (offline sync)
- **Maps**: flutter_map + FMTC tile cache (offline-capable)
- **Notifications**: flutter_local_notifications + flutter_background_service
- **Permissions**: permission_handler 11.4

## Architecture — 4-Tier Inference

```
Tier 1: Cloud Gemma 4 27B (needs internet, 5s timeout)
Tier 2: On-device Gemma 4 E4B via flutter_gemma / MediaPipe LiteRT
Tier 3: Heuristic scoring (always available, instant)
Tier 4: BLE mesh broadcast only (no GPS or internet)
```

## Key Services

| Service | Provider type | Notes |
|---|---|---|
| `EmergencyOrchestrator` | StateNotifier | Central SOS state machine |
| `CrashDetectionService` | Provider | Accel + gyroscope fusion, GPS speed gates |
| `GyroscopeFusionService` | (plain class, owned by CrashDetectionService) | Angular velocity → confidence multiplier |
| `DrivingModeService` | StateNotifier (NOT autoDispose) | GPS speed → driving context |
| `WakeLockService` | Static (wakelock_plus) | Screen-on during active SOS |
| `ProactiveMonitorService` | StateNotifier (NOT autoDispose) | Safe-walk escalation timer |
| `ConnectivityService` | Provider (NOT autoDispose) | Network quality for triage tier selection |
| `MeshNetworkService` | StateNotifier (NOT autoDispose) | BLE scan/advertise |
| `GemmaLocalService` | Provider | On-device Tier 2 inference |
| `EmergencyBackgroundService` | Static | Foreground service + battery opt exemption |

> **autoDispose rule**: Never use `autoDispose` for services that own timers, streams, or background state that must survive widget rebuilds. The MeshNetworkService and ProactiveMonitorService bugs from autoDispose are fixed and documented.

## Crash Detection Pipeline

```
Accel spike > (base_threshold / gyroMultiplier)
  └─ gyroMultiplier: >3.5 rad/s → 1.4x (car roll) | <1.5 rad/s → 0.6x (pothole)
     └─ GPS: pre-impact speed ≥ 30 km/h?
        └─ GPS: post-impact speed collapses or car halts?
           └─ Stillness check (unless gyro peak >3.5 → bypass)
              └─ CoolDown (deduplicate within 60s)
                 └─ triggerSOS()
```

## Android Permissions (key ones)

- `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_LOCATION` — crash detection background
- `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` — Doze exemption so service survives night drives
- `SCHEDULE_EXACT_ALARM` — precise safe-walk escalation on Android 12+
- `WAKE_LOCK` — CPU (flutter_background_service) + screen (wakelock_plus)
- `BLUETOOTH_SCAN/CONNECT/ADVERTISE` — BLE mesh
- `SEND_SMS` — emergency SMS dispatch

## App Shortcuts (long-press launcher icon)

- **SOS** — opens app to panic screen
- **Safe Walk** — opens app to safe-walk dialog

## GitHub

Repo: `https://github.com/NITISH-R-G/RoadSOS`  
Latest commit: `3fb4cad27b34f405aefc26d38c3ab2ab4d927be4`  
Previous commit: `062d2bd8b8880b0c602aebc9dffb10728eeb4354`

## Environment Variables

Managed via flutter_dotenv (`.env` file, not committed):
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`
- `GOOGLE_CLOUD_PROJECT`, `GEMMA_CLOUD_API_KEY` (Tier 1)
- `INDIA_ERSS_API_URL`, `INDIA_ERSS_API_KEY` (optional)
