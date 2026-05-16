# AGENTS.md

## Cursor Cloud specific instructions

### Project overview

RoadSOS is a Flutter mobile app (Dart) with Supabase Edge Functions (TypeScript/Deno) as the backend. The primary development loop is Flutter-based: `flutter pub get`, `dart analyze`, `flutter test`, `flutter build web`.

### Flutter SDK

The CI pins **Flutter 3.41.9** (Dart 3.11.5). The `pubspec.yaml` SDK constraint is `^3.11.0`. Flutter must be installed at `/opt/flutter` with `/opt/flutter/bin` on `PATH` (the update script handles this).

### Key commands

| Action | Command |
|---|---|
| Install deps | `flutter pub get` |
| Lint | `dart analyze` |
| Test | `flutter test` |
| Build web | `flutter build web` |
| Serve locally | `python3 -m http.server 8080` (from repo root) |

### Environment file

Copy `assets/env.template` to `assets/.env` before running the Flutter app. The app needs `SUPABASE_URL` and `SUPABASE_ANON_KEY` to initialize — without them the Flutter web app shows a blank page. The standalone demo at `demo/index.html` works without any env vars.

### Testing without external services

- `dart analyze` and `flutter test` work without any secrets or external services.
- The standalone HTML demo (`demo/index.html`) supports an **Offline Fallback** triage mode that runs keyword-based classification without a Google AI API key.
- The full Flutter web app (`flutter build web` then serve `build/web/`) requires Supabase credentials to initialize.

### Gotchas

- The `flutter_blue_plus_winrt` warnings during `pub get` / build are harmless (Windows-only plugin, irrelevant on Linux).
- Localization warnings about untranslated messages in `bn`, `hi`, `mr`, `ta`, `te` are expected and non-blocking.
- The Wasm dry-run warnings during `flutter build web` are informational only; the JS build succeeds.
- `assets/.env` is gitignored; it must be created from `assets/env.template` for local dev.

### Supabase Edge Functions

Located in `supabase/functions/`. Deploying requires the Supabase CLI and project credentials. Not required for running tests or the standalone demo.
