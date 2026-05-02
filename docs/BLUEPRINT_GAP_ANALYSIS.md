# RoadSOS · April 2026 Implementation Blueprint — Gap Analysis

Honest mapping of the public blueprint to this repository (`lib/`, `supabase/`). Status is **Real** (implemented end-to-end), **Partial** (stub, env-gated, or single-platform), or **Not started** (spec only).

## Visual & UX (Section 01 / 04)

| Blueprint item | Status | Notes |
|----------------|--------|--------|
| Emergency-grade dark UI (Abyss, Blood Red, Mesh Teal) | Partial → Real | Fixed palette added as `RoadSosTokens` / `roadsos_theme.dart`; SOS override keeps high-contrast red |
| Bebas Neue + Noto Sans + DM Mono | Partial | Wired via `google_fonts`; verify font licenses for Play Store |
| 56px min tap targets, 160px SOS, 8px grid, hard edges | Partial | Tokens defined; individual screens still need audit |
| No gradients in UI (maps excluded) | Partial | Theme avoids gradients; map layers unchanged |
| Sub-100ms SOS path | Partial | No deliberate animations on SOS path; not benchmarked |

## Phase 1 — Foundation

| Blueprint item | Status | Notes |
|----------------|--------|--------|
| Gemma 4 cold-start / GGUF on-device | Not started | Triage uses Gemini HTTP + offline classifier (`ai_triage_service.dart`); no GGUF loader |
| 90s onboarding + medical profile | Partial | Profile + onboarding exist; full 4-step blueprint flow not verified |
| Crash: accel + GPS + mic + Savitzky–Golay + calibration | Partial | `CrashDetectionService`: user accel + GPS speed profile + stillness; **no microphone**, **no S–G**, **no per-device calibration UI** |
| Panic SOS: swipe-up cancel, haptics | Partial | Countdown + cancel exists; gesture spec may differ |
| Family tracking URL (24h, Edge) | Real | `incident_live_links` + `family-track` Edge Function + `FamilyTrackingService`; SMS to contact on Android when number parseable |
| Live contact SMS verification | Not started | Contact stored as free text; no OTP flow |

## Phase 2 — Wow features

| Blueprint item | Status | Notes |
|----------------|--------|--------|
| Mesh visualiser (animated graph) | Partial | `mesh_radar.dart` / BLE beacon pipeline — not full blueprint viz |
| AI triage voice (TTS/STT loop) | Partial | `voice_assistant_service`, `speech_to_text`, `flutter_tts` — wire-up depth varies |
| Ephemeral HKDF mesh keys | Partial | `SceneSecurityService` scene keys — audit vs blueprint “per-incident rotation” |
| 12 Indian languages | Partial | **6** ARB locales: `en`, `hi`, `ta`, `mr`, `bn`, `te` |
| Bystander mode | Partial | Orchestrator + BLE listen; full “non-dismissible” UX TBD |
| Ambient drive detection | Partial | `proactive_monitor_service` / heuristics — align with blueprint thresholds |

## Phase 3 — Network & scale

| Blueprint item | Status | Notes |
|----------------|--------|--------|
| 112 ERSS API | Partial | Optional `INDIA_ERSS_API_URL` ingest from `EmergencySmsDispatchService`; enrollment-specific |
| Responder dashboard | Partial | `responder_dashboard.dart` — scope vs Next.js spec |
| Battery tier architecture | Not started | Not implemented as described; document when added |
| Driving score / hazards / freemium | Not started | Spec only |

## Phase 4 — Launch & judges

| Blueprint item | Status | Notes |
|----------------|--------|--------|
| Play Store / `publish_to` | Not started | `pubspec.yaml` still `publish_to: 'none'` |
| E2E benchmark suite | Partial | Tests exist; blueprint KPI table not pinned in README |
| Case-study video | Not started | Out of repo |

## Flagship claims (Section 03)

| Claim | Status | Notes |
|-------|--------|--------|
| Encrypted BLE mesh relay | Partial | Advertising + encryption helpers; multi-hop “relay” not claimed as production-complete |
| On-device multilingual Gemma triage | Not started | Offline classifier + cloud Gemini; not Gemma IT |
| Bystander network | Partial | BLE listen + orchestration paths |
| Family link without app install | Real | Browser GET `family-track?t=…` (HTML + JSON) |
| Triple sensor crash (500ms window) | Partial | Two-sensor + stillness pipeline; different thresholds than blueprint |
| Battery &lt;5%/hr passive | Not started | Needs measurement harness |

## Maintenance

Revisit this table when merging major features; keep **Real vs Simulated** honest for judges and `ROADSOS_MASTER_DEVELOPMENT_RULEBOOK.md` Phase 8.
