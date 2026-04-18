# 1. Feature-Driven Architecture

Date: 2024-05-18

## Status

Accepted

## Context

The initial prototype of RoadSOS utilized a flat folder structure (`lib/ui`, `lib/services`). This created tight coupling, where UI elements directly instantiated backend services, making testing difficult and parallel development by multiple teams impossible due to merge conflicts.

## Decision

We will adopt a Feature-Driven Development (FDD) architecture. The `lib/` directory is split into `core/` (shared utilities, themes, base networking) and `features/` (domain-specific modules like `triage`, `emergency`, `map`).

Each feature folder must encapsulate its own UI, models, and services. Features are not permitted to directly import files from other features; communication must happen via exposed Riverpod providers or a shared Event Bus in `core/`.

## Consequences

- **Pros:** Teams can own specific folders, dramatically reducing merge conflicts. Code is highly modular and testable.
- **Cons:** Slightly more boilerplate required to set up a new feature.
