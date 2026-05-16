# AGENTS.md

## Cursor Cloud specific instructions

### Project overview

RoadSOS is a Flutter mobile/web app (Dart) with a Supabase backend (PostgreSQL + Deno Edge Functions). The primary development artifact is the Flutter app; Supabase functions are deployed separately.

### Environment

- **Flutter SDK**: installed at `/opt/flutter` (version 3.41.9, Dart 3.11.5). PATH includes `/opt/flutter/bin`.
- **Java**: OpenJDK 21 (pre-installed, needed for Android builds only).
- **No Node/Python** dependencies at the project root; Supabase Edge Functions use Deno (TypeScript) but are deployed via `supabase functions deploy`.

### Common commands

| Task | Command |
|------|---------|
| Install deps | `flutter pub get` |
| Lint / analyze | `dart analyze` |
| Run tests | `flutter test` |
| Build web | `flutter build web` |
| Run web dev server | `flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0` |
| Run demo page | `python3 -m http.server 8081` in `demo/` |

### Gotchas

- The Flutter web dev server (`flutter run -d web-server`) takes ~30–40 seconds to compile on first launch. Subsequent hot reloads are fast (press `r` in the terminal).
- `flutter pub get` emits warnings about `flutter_blue_plus_winrt` and untranslated l10n messages — these are non-blocking and can be ignored.
- The app degrades gracefully without Supabase/Twilio/Gemma API keys — it runs in offline mode with heuristic triage. Full backend testing requires `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and optionally `GEMMA_API_KEY` (set in `assets/.env`).
- `flutter build web` emits Wasm dry-run warnings for `flutter_gemma` and `flutter_tts` — these are informational and do not block the JS build.
- There is no `google-services.json` or Firebase config committed; Firebase-dependent features (push notifications) will not work without project setup.
- The CI workflow (`.github/workflows/flutter_ci.yml`) runs `dart analyze` + `flutter test` — match this locally before pushing.
