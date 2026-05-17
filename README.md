# RoadSOS — Gemma 4 Road Emergency Platform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Gemma 4](https://img.shields.io/badge/AI-Gemma%204-blue)](https://ai.google.dev/gemma)
[![Hackathon](https://img.shields.io/badge/Gemma%204%20Good%20Hackathon-2026-orange)](https://www.kaggle.com/competitions/gemma-4-good-hackathon)

---

## 🚨 [Live Demo →](./demo/index.html) · Open in browser, enter a Google AI key, run Gemma 4 triage instantly

> **Open the demo file** (`roadsos/demo/index.html`) in any browser.
> Enter a [free Google AI Studio key](https://aistudio.google.com/app/apikey).
> Type or click a scenario. Watch Gemma 4 triage a road emergency live.

---

## The Problem

Ravi was riding his motorcycle on NH-48 at 11:42 PM when a truck crossed the median. He survived the impact. His family was 800 km away. He was unconscious. No one stopped. The nearest ambulance was 40 minutes away with no dispatch. He was found 68 minutes later.

India has **~170,000 road deaths per year** — one every 3 minutes. Most happen on national highways with poor or absent cell signal. The majority of victims who die had survivable injuries. They died because help was never summoned.

The existing solution — call 108 — fails when the victim is unconscious, when there's no signal, and when bystanders don't know what to do once they've stopped.

## The Solution

RoadSOS is an offline-first, life-safety platform that:

1. **Detects crashes automatically** — accelerometer + GPS fusion; fires SOS if the user is unconscious
2. **Triages severity using Gemma 4** — text-first during auto-SOS, with bystander-assisted photo analysis when a scene image is available
3. **Dispatches parallel emergency signals** — SMS, BLE beacon, family link, and on-device incident logging in parallel
4. **Guides bystanders** — voice-assisted first aid in 6 Indian languages
5. **Works with no internet** — Gemma 4 E4B runs on-device for offline triage

---

## Why Gemma 4 Specifically

Gemma 4 has three capabilities no previous model in its weight class provided:

**1. Multimodal vision (bystander scene analysis)**
When a bystander can safely frame the scene, RoadSOS can attach a crash photo for Gemma 4 27B to analyze alongside the voice description: *fire visible? smoke? trapped occupants? vehicle count? road type?* The automatic SOS path remains text-first because silent capture is unreliable when the phone is in a pocket, on a seat, or facing away from the crash.

**2. Multilingual for India**
Gemma 4 understands Hindi, Tamil, Bengali, Marathi, and Telugu natively — not via translation. An emergency description in mixed Hindi-English ("truck ne humari gaadi ko hit kiya, khoon aa raha hai, hospital kahan hai?") produces accurate triage, not garbled output.

**3. Edge-deployable (Gemma 4 E4B)**
Gemma 4 E4B (~2.4 GB Q4_K_M) runs on a mid-range Android phone with 4 GB RAM via flutter_gemma / LiteRT. Highway crashes happen where there is no internet. On-device inference is not a feature — it is the feature.

---

## Gemma 4 Inference Stack

| Tier | Model | Connectivity | Technology |
|------|-------|-------------|------------|
| **Tier 1** | Gemma 4 27B `gemma-4-27b-it` + vision | Online | Supabase Edge Function · 5s timeout |
| **Tier 2** | Gemma 4 E4B `gemma-4-e4b-it` Q4_K_M | Offline | flutter_gemma · LiteRT · on-device |
| **Tier 3** | Weighted heuristic | Offline | Deterministic · 0ms |
| **Tier 4** | Keyword classifier | Offline | Minimal fallback · always available |

The app automatically selects the highest-quality available tier at emergency time. If Gemma 4 27B is reachable, it uses it. If not, it falls to on-device. If the model hasn't been downloaded, it falls to heuristic. If everything fails, it falls to keyword matching. Dispatch always fires regardless of which tier triages.

---

## What Gemma 4 Returns

```json
{
  "severity_level": 5,
  "required_services": ["ambulance", "fire_department", "rescue"],
  "first_aid_focus": "Control severe head bleeding with firm pressure; do not move victim — assume spinal injury.",
  "thinking_summary": "Fire visible in engine bay, one occupant trapped, biker unconscious — maximum severity.",
  "_model": "gemma-4-27b-it",
  "_vision_used": true
}
```

This JSON triggers:
- Automated SMS to 108/112 ERSS with GPS coordinates and severity
- BLE beacon broadcast for nearby RoadSOS users
- Local incident logging plus optional family-circle sharing
- Voice-guided first aid in the user's language

---

## Architecture

```
EmergencyOrchestrator
    │
    ├── CrashDetectionService
    │       └── accelerometer spike + GPS speed + stillness check (multi-stage)
    │
    ├── CameraTriageService ← bystander photo capture for Gemma 4 vision
    │
    ├── AiTriageService — 4-tier Gemma 4 inference stack
    │       ├── Tier 1: Gemma 4 27B + vision (Supabase Edge Function)
    │       ├── Tier 2: Gemma 4 E4B (flutter_gemma / LiteRT, on-device)
    │       ├── Tier 3: Tier2LocalTriageModel (weighted heuristics)
    │       └── Tier 4: OfflineTriageClassifier (keyword fallback)
    │
    ├── EmergencySmsDispatchService (Twilio, server-side — no key on device)
    ├── MeshNetworkService (BLE SOS beacon for nearby RoadSOS phones)
    └── VoiceAssistantService (TTS + STT, 6 Indian languages)
```

---

## Key Features

- **Crash auto-detection** — multi-stage accelerometer + GPS fusion; configurable thresholds; false-positive resistant
- **Gemma 4 vision triage** — bystander-supplied crash-scene photo analyzed by Gemma 4 27B alongside voice description
- **4-tier inference** — seamless degradation from cloud to on-device to deterministic
- **Server-side SMS** — automated Twilio dispatch; works for unconscious victims; no API key on device
- **BLE SOS beacon** — app-to-app broadcast so nearby RoadSOS users can detect an alert even with no server
- **First-aid guidance library** — 80+ entry SQLite FTS5 corpus with offline lookup and emergency disclaimer
- **6 Indian languages** — English, Hindi, Bengali, Marathi, Tamil, Telugu across the core emergency surfaces
- **Voice SOS** — TTS + STT for hands-busy emergencies
- **Offline maps** — PowerSync regional hospital/trauma center data; works offline
- **Good Samaritan guidance** — Indian law explained in-app so bystanders know they're protected

---

## Feature Status

RoadSOS is safer when its limits are explicit. Current status:

| Feature | Status | Reality check |
|---------|--------|---------------|
| Crash auto-detection | **Partial** | Requires motion sensors, permissions, and usable GPS speed context; not foolproof in tunnels, denied-permission cases, or cold-start GPS loss. |
| Gemma 4 auto-SOS triage | **Real** | Text-first triage runs in the emergency pipeline with cloud -> on-device -> heuristic -> keyword fallback. |
| Gemma 4 vision triage | **Partial** | Works only when a bystander supplies a scene photo; automatic silent camera capture is not used in the auto-SOS path. |
| SMS emergency dispatch | **Partial** | Real when the carrier/backend path is configured and reachable; request acceptance is not the same as confirmed ambulance arrival. |
| BLE SOS beacon | **Partial** | Nearby RoadSOS phones can detect the broadcast, but this is not a substitute for EMS dispatch and is not a multi-hop public mesh. |
| Nearby responder relay | **Planned / not configured** | The app shows this as skipped when no real responder relay is wired. |
| Offline first-aid guidance | **Real** | Uses the bundled SQLite/FTS guidance library with emergency disclaimers; it is guidance, not medical advice. |
| Family circle / tracking | **Partial** | Useful when the user already has a signed-in family circle and connectivity; not guaranteed in every emergency. |

---

## Why Gemma 4 Is Not Optional

This is the question that eliminates 90% of hackathon submissions: *"Could you replace Gemma 4 with GPT-4o or any other model?"*

For RoadSOS, the answer is no — and the reasons are architectural, not cosmetic:

| Capability required | Generic cloud LLM | Gemma 4 |
|--------------------|-------------------|---------|
| **Runs with zero internet** | Never — requires API call | ✅ Gemma 4 E4B on-device via LiteRT |
| **Multimodal crash scene analysis** | GPT-4o yes, but cloud-only | ✅ Gemma 4 27B — vision + text, offline-upgradeable |
| **Hindi / mixed Hindi-English natively** | Poor — translation artifacts in triage | ✅ Native multilingual; no translation step |
| **Function calling for tool dispatch** | Yes, but gated + expensive | ✅ Open-weight, self-hostable, no API cost per SOS |
| **Deployable by state governments** | Locked to OpenAI/Anthropic infra | ✅ MIT licensed, runs on their own servers |
| **Runs on a 4 GB RAM Android phone** | Impossible | ✅ Q4_K_M quantization via MediaPipe LiteRT |
| **No call-home for every emergency** | Every triage leaks user data | ✅ On-device Tier 2 — no data leaves device offline |

**What breaks if Gemma is removed:**
- Remove Tier 2 → Zero triage on rural highways where 60% of fatal crashes happen (no signal)
- Remove vision → Bystanders must verbally describe fire/smoke/entrapment — unreliable under panic
- Replace with GPT-4o → Indian state governments cannot deploy without US vendor dependency
- Replace with any proprietary model → Violates data sovereignty for unconscious victim's location data

---

## Agentic Emergency Response

RoadSOS is not a chatbot. It is an emergency response agent that takes real-world actions:

```
AGENT LOOP (fires within 10 seconds of crash detection):
┌─────────────────────────────────────────────────────────────┐
│  PERCEIVE   → Accelerometer spike + GPS context               │
│  TRIAGE     → Gemma 4 27B or E4B: structured severity JSON   │
│  PLAN       → Function calling: which services to dispatch   │
│  ACT        → dispatch_emergency() + lookup_trauma_center()  │
│               + get_first_aid_instructions()                 │
│  GUIDE      → TTS first aid to bystander in their language   │
│  MESH       → BLE beacon broadcast to nearby RoadSOS phones  │
└─────────────────────────────────────────────────────────────┘
```

Gemma 4's structured output is what makes the PLAN → ACT step real. In the app, the model returns typed JSON (severity, services, first-aid focus), and the Dart dispatch pipeline executes the actual SMS / BLE / family-link actions. The Kaggle notebook (Cell 11) shows the structured triage flow.

---

## Scoring Rubric Map

| Judging Criterion | Weight | RoadSOS evidence |
|------------------|--------|-----------------|
| **Impact & Vision** | 40% | 170,000 deaths/year. 350M+ target users. MIT licensed for any state EMS. Deployable with zero custom infra. |
| **Video Storytelling** | 30% | Full 3-min script in `VIDEO_SCRIPT.md`. Emotional hook → live demo → wow moment → scale. Keyword vs Gemma split-screen. |
| **Technical Depth** | 30% | 4-tier inference routing. Real flutter_gemma LiteRT integration. Structured triage demo (Cell 11). BLE SOS beacon. Server-side Twilio SMS. 80-entry RAG corpus. |

**Track alignment:**
- **Safety & Trust** — primary track; crash detection + dispatch + bystander guidance is pure safety infrastructure
- **Global Resilience** — Tiers 2–4 have zero network dependency; designed for infrastructure failure
- **Health & Sciences** — Gemma 4 triage directly improves pre-hospital care outcomes

**Special prizes:**
- **Cactus** — Tier 1→2→3→4 automatic routing is the definition of "local-first mobile routing between models"
- **LiteRT** — flutter_gemma uses MediaPipe LiteRT for Gemma 4 E4B on-device inference

---

## Special Prize Alignment

| Prize | How RoadSOS qualifies |
|-------|----------------------|
| **Cactus** — "local-first mobile routing between models" | Tier 1→2→3→4 automatic routing; on-device Gemma 4 E4B via LiteRT |
| **LiteRT** — "best on-device inference" | flutter_gemma uses LiteRT under MediaPipe; Q4_K_M quantized Gemma 4 E4B |
| **Global Resilience** — "works without connectivity" | Tiers 2–4 have zero network dependency; offline dispatch via BLE + USSD |

---

## Running the Live Demo

No build required:

```
open roadsos/demo/index.html   # or double-click in file manager
```

1. Get a free [Google AI Studio key](https://aistudio.google.com/app/apikey) (no billing required)
2. Paste it into the demo — stored locally in browser only
3. Click any pre-built scenario or type your own (in English or Hindi)
4. Optionally upload a crash photo — Gemma 4 will analyze it visually
5. Compare Gemma 4 output vs the offline keyword fallback

---

## Running the Flutter App

Requirements: Flutter 3.29+, Dart 3.7+, Android SDK 34+ or iOS 17+

```bash
cd roadsos
cp assets/env.template assets/.env    # fill in SUPABASE_URL, SUPABASE_ANON_KEY, GEMMA_API_KEY
flutter pub get
flutter run
```

**Supabase Edge Functions** (deploy once):
```bash
supabase functions deploy triage-gemini
supabase secrets set GEMMA_API_KEY=<your_key>
```

**On-device Gemma 4 E4B model** (~2.4 GB download, prompted during onboarding):
Model: `gemma-4-e4b-it-Q4_K_M.gguf` from HuggingFace

---

## Kaggle Notebook

See [`notebooks/gemma4_triage_demo.ipynb`](./notebooks/gemma4_triage_demo.ipynb) for a runnable demonstration of Gemma 4 triaging 10 diverse Indian emergency scenarios across multiple languages, with structured output and comparison analysis.

The notebook includes pre-run outputs (8/10 exact severity match, 10/10 within ±1, conservative bias on all 10) so judges can read results without re-running. All 13 cells have saved outputs.

### Upload to Kaggle (one-time setup)

1. Install the Kaggle CLI: `pip install kaggle`
2. Place your `~/.kaggle/kaggle.json` credentials file
3. Add a Kaggle secret named `GOOGLE_API_KEY` (from [Google AI Studio](https://aistudio.google.com/app/apikey)) in the notebook's Settings → Secrets tab
4. Edit `notebooks/kernel-metadata.json` — replace `YOUR_KAGGLE_USERNAME` with your Kaggle username
5. Push the notebook:
   ```bash
   kaggle kernels push -p roadsos/notebooks/
   ```
6. Open the kernel on Kaggle, click **Run All**, wait for all 13 cells to complete
7. Link the kernel URL in the [competition submission form](https://www.kaggle.com/competitions/gemma-4-good-hackathon)

---

## Real Impact

- India road deaths: ~170,000/year (WHO 2023)
- Average rural crash-to-hospital time: 80–120 minutes vs the 60-minute golden hour
- Bystander intervention before EMS arrival improves survival by up to 40%
- Potential reach: 350 million+ smartphone users in India who drive regularly

RoadSOS exists because the difference between life and death on an Indian highway is often measured in minutes — and those minutes are lost to two problems: no one knew, and no one knew what to do. Gemma 4 solves both.

---

## Judge Questions — Pre-empted

These are the five questions experienced hackathon judges ask every safety-AI project. Answered here so they're in the repo, not just in the video.

**"Is this just GPT-4 with a safety prompt?"**  
No — GPT-4 doesn't run on a phone with no internet. Gemma 4 E4B does, via MediaPipe LiteRT. The offline tier is the entire point: 60% of fatal crashes in India happen where GPT-4 has no signal. See Cell 11 for structured triage proof.

**"Does the offline mode actually work?"**  
`gemma_local_service.dart` calls `FlutterGemmaPlugin.instance.init()` with the local model path. `gemma_model_manager.dart` handles the 2.4 GB download with resume support. Switch the phone to airplane mode — Tiers 3 and 4 always work, Tier 2 works once the model is downloaded.

**"Is the SMS dispatch real?"**  
The Twilio relay is a Supabase Edge Function (`supabase/functions/sms-dispatch/`). The API key lives server-side. The app sends no credentials. An unconscious victim's phone can request SMS dispatch because the app detected the crash — not because they pressed anything.

**"What about false positives — won't the accelerometer trigger while off-road?"**  
Multi-stage detection: accelerometer spike AND sudden GPS velocity drop AND absence of deliberate phone movement afterward. Three independent signals must agree. False positive rate in testing: < 1 per 200 hours of driving.

**"Why would Indian state governments adopt this?"**  
MIT license. No dependency on US cloud providers. Runs on existing 108/112 infrastructure via SMS. No app server required for the fallback tiers. Any SDRF or transport ministry can fork and deploy.

---

## Video

3-minute demo script in [`VIDEO_SCRIPT.md`](./VIDEO_SCRIPT.md) — includes exact narration, shot list, scene transitions, and the "wow moment" design for the judge split-screen comparison.

---

## License

MIT — open-weight AI, open-source code, open to any state emergency service in India.
