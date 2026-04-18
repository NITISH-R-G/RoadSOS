# RoadSOS: Global Emergency Infrastructure

[![RoadSOS CI](https://github.com/NITISH-R-G/RoadSOS/actions/workflows/main.yml/badge.svg)](https://github.com/NITISH-R-G/RoadSOS/actions/workflows/main.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**RoadSOS** is an enterprise-grade, life-safety platform designed to provide location-based emergency access during road accidents—even in zero-connectivity environments. By combining **Edge AI (Gemma 4 IT)**, **BLE Mesh Networking**, and **Offline-First Persistence (PowerSync)**, RoadSOS ensures that help is always reachable.

## 🚀 Key Features
- **🚨 1-Tap SOS**: Immediate multi-channel dispatch (Mesh + DB + SMS).
- **🧠 Edge AI Triage**: Tiered inference using Gemma 4 IT for medically grounded advice.
- **🛰️ Offline-First Maps**: Regional facility syncing for hospitals and trauma centers.
- **🛡️ Secure Mesh**: 256-bit AES-GCM encrypted BLE broadcasting.
- **🔋 Battery Resilient**: Persistent foreground services for 24/7 reliability.

## 🏗️ Architecture
We follow a **Modular Feature-First** architecture. See [docs/ARCH.md](docs/ARCH.md) for details.
- **Core**: `lib/core`
- **Triage Module**: `lib/services/ai_triage_service.dart`
- **Mesh Module**: `lib/services/mesh_network_service.dart`

## 🛠️ Tech Stack
- **Framework**: Flutter (Dart)
- **Local DB**: PowerSync (SQLite)
- **Backend**: Supabase
- **Edge AI**: Gemma 4 IT (via `llamadart`)

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
