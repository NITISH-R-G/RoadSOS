# RoadSOS: Global Emergency Infrastructure

[![RoadSOS CI](https://github.com/NITISH-R-G/RoadSOS/actions/workflows/main.yml/badge.svg)](https://github.com/NITISH-R-G/RoadSOS/actions/workflows/main.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**RoadSOS** is an enterprise-grade, life-safety platform designed to provide location-based emergency access during road accidents—even in zero-connectivity environments. By combining **cloud LLM triage (Gemini Flash)**, **keyword-based offline fallback**, **BLE manufacturer beacons + scan**, and **Offline-First Persistence (PowerSync)**, RoadSOS keeps dispatch coherent when connectivity exists and degrades safely when it does not.

## 🚀 Key Features
- **🚨 1-Tap SOS**: Immediate multi-channel dispatch (Mesh + DB + SMS).
- **🧠 AI Triage**: Gemini Flash when `GEMINI_API_KEY` is set in `assets/.env`; otherwise deterministic keyword → severity mapping (no fake delays).
- **🛰️ Offline-First Maps**: Regional facility syncing for hospitals and trauma centers.
- **🛡️ Secure Mesh**: 256-bit AES-GCM encrypted BLE broadcasting.
- **🔋 Background behavior (platform-dependent)**:
  - **Android**: Foreground services can keep critical work alive when configured; behavior depends on OEM battery policies.
  - **iOS**: There is **no** app-controlled 24/7 background execution. The OS grants short windows (~30s typical) for background fetch, `BGTaskScheduler`, and silent push (`content-available` APNs). [`flutter_background_service`](https://pub.dev/packages/flutter_background_service) cannot change that — reliability while **foreground / unlocked** differs sharply from Android.
  - **HealthKit**: The app requests read access where available (e.g. Fall Detection synced to Health). **Apple’s system vehicle Crash Detection is not exposed to third-party apps via a public HealthKit type today** — enable Apple’s built-in Emergency / Crash flows in Settings for system-level handling; RoadSOS still uses on-device sensors in Dart while the app is active.

## 🏗️ Architecture
We follow a **Modular Feature-First** architecture. See [docs/ARCH.md](docs/ARCH.md) for details.
- **Core**: `lib/core`
- **Triage Module**: `lib/services/ai_triage_service.dart`
- **Mesh Module**: `lib/services/mesh_network_service.dart`

## 🛠️ Tech Stack
- **Framework**: Flutter (Dart)
- **Local DB**: PowerSync (SQLite)
- **Backend**: Supabase
- **Triage**: Google Gemini API (`gemini-1.5-flash`) + offline heuristics; optional Android **Accessibility** service for lock-screen volume SOS gesture.

## 🚦 Getting Started
1. **Prerequisites**: [Flutter SDK](https://docs.flutter.dev/get-started/install)
2. **Setup**:
   ```powershell
   ./scripts/setup.ps1
   ```
3. **Environment**: Fill in the generated `.env` file.
4. **Run**:
   ```bash
   flutter run
   ```

## 🤝 Contributing
We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for our trunk-based development workflow and coding standards.

## 🛡️ Security
For vulnerability reporting, see our [Security Policy](SECURITY.md).

---
*Built for resilience. Built for life.*
