# RoadSOS Architecture

RoadSOS is built using a **Modular Monolith** approach on the client (Flutter) and interacts with a microservices backend.

## Client Architecture (Flutter)

The application follows a Feature-Driven Development (FDD) structure managed by Riverpod for dependency injection and state management.

```
lib/
├── core/
│   ├── database/       # PowerSync / SQLite configurations
│   ├── models/         # Shared domain models
│   └── services/       # Base services (Location, Networking)
└── features/
    ├── emergency/      # SOS triggers, Orchestrator, Event Logging
    ├── map/            # OSM Map rendering, Facility Sync
    └── triage/         # AI inference, First Aid RAG
```

## State Management

We use `flutter_riverpod` exclusively.
- Global state is minimized.
- Feature state is managed by `StateNotifierProvider`.
- Services are injected via `Provider`.

## Backend Architecture

The backend utilizes Supabase (PostgreSQL) for relational data and PowerSync for real-time offline-first sync.
Future integration will move heavy ML tasks (Gemma 4 Triage) from on-device FFI to AWS g5 instances accessible via an API Gateway.
