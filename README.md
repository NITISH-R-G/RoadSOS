<div align="center">
  <h1>🚨 RoadSOS</h1>
  <p><b>The world's most resilient, offline-first emergency response platform.</b></p>

  [![CI](https://github.com/roadsos/roadsos/actions/workflows/pr-validation.yml/badge.svg)](https://github.com/roadsos/roadsos/actions)
  [![Security](https://github.com/roadsos/roadsos/actions/workflows/codeql.yml/badge.svg)](https://github.com/roadsos/roadsos/actions)
  [![Flutter](https://img.shields.io/badge/Flutter-3.11.0-blue.svg)](https://flutter.dev)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

---

RoadSOS is an enterprise-grade Flutter application designed to provide instantaneous, reliable emergency dispatching and AI-driven triage (Gemma 4) in low-connectivity environments.

## 📖 Documentation

Our documentation is designed to scale from day-one onboarding to deep architectural dives:

- [Architecture Overview](docs/ARCHITECTURE.md) - System design and feature boundaries.
- [Development Setup](docs/DEVELOPMENT.md) - How to run the project locally.
- [Contributing Guidelines](CONTRIBUTING.md) - Branching strategy, PR requirements, and standards.
- [Architecture Decision Records (ADRs)](docs/adr/) - Historical log of major technical decisions.
- [Security Policy](SECURITY.md) - Vulnerability reporting and compliance.

## 🚀 Quick Start

Ensure you have Flutter 3.11+ installed.

```bash
git clone https://github.com/roadsos/roadsos.git
cd roadsos
./scripts/bootstrap.sh
flutter run
```

## 🏗️ Repository Structure

We utilize a strict Feature-Driven Architecture to support parallel development across multiple engineering squads.

* `lib/core/` - Foundation layers (DB, DI, Networking).
* `lib/features/` - Domain logic isolated by squad (e.g., Triage, Maps, Emergency).
* `.github/` - Automation pipelines, templates, and security configs.

## 🤝 Collaboration

We embrace Open Source standards. See our [CONTRIBUTING.md](CONTRIBUTING.md) for how to get involved. All changes must pass our strict CI/CD pipelines and require Code Owner review.

## 🛡️ License

MIT License. See `LICENSE` for more information.
