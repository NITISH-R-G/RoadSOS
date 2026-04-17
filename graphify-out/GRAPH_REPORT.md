# Graph Report - .  (2026-04-17)

## Corpus Check
- Corpus is ~2,911 words - fits in a single context window. You may not need a graph.

## Summary
- 88 nodes · 76 edges · 18 communities detected
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 2 edges (avg confidence: 0.75)
- Token cost: 50 input · 200 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Hardware SOS Trigger & Dashboard|Hardware SOS Trigger & Dashboard]]
- [[_COMMUNITY_App Entry Point & Theming|App Entry Point & Theming]]
- [[_COMMUNITY_Offline Database & PowerSync|Offline Database & PowerSync]]
- [[_COMMUNITY_iOS Native Volume Button Trigger|iOS Native Volume Button Trigger]]
- [[_COMMUNITY_Edge AI Triage & Mesh Network|Edge AI Triage & Mesh Network]]
- [[_COMMUNITY_Android Flutter Plugin Registry|Android Flutter Plugin Registry]]
- [[_COMMUNITY_Android SOS MainActivity|Android SOS MainActivity]]
- [[_COMMUNITY_Testing & Widget Tests|Testing & Widget Tests]]
- [[_COMMUNITY_iOS LLDB Debug Helpers|iOS LLDB Debug Helpers]]
- [[_COMMUNITY_iOS XCTest Runner|iOS XCTest Runner]]
- [[_COMMUNITY_Project Documentation|Project Documentation]]
- [[_COMMUNITY_Brand Visual Identity & Assets|Brand Visual Identity & Assets]]
- [[_COMMUNITY_iOS Scene Delegate|iOS Scene Delegate]]
- [[_COMMUNITY_Android Build Config|Android Build Config]]
- [[_COMMUNITY_Android Settings|Android Settings]]
- [[_COMMUNITY_Android App Build Config|Android App Build Config]]
- [[_COMMUNITY_iOS Plugin Registrant Header|iOS Plugin Registrant Header]]
- [[_COMMUNITY_iOS Bridging Header|iOS Bridging Header]]

## God Nodes (most connected - your core abstractions)
1. `AppDelegate` - 7 edges
2. `GeneratedPluginRegistrant` - 4 edges
3. `MainActivity` - 4 edges
4. `package:flutter_riverpod/flutter_riverpod.dart` - 4 edges
5. `RunnerTests` - 3 edges
6. `package:flutter/material.dart` - 3 edges
7. `RoadSOS App Icon (Android)` - 3 edges
8. `handle_new_rx_page()` - 2 edges
9. `SceneDelegate` - 2 edges
10. `package:powersync/powersync.dart` - 2 edges

## Surprising Connections (you probably didn't know these)
- `RoadSOS App Icon (Android)` --semantically_similar_to--> `RoadSOS Launch Screen`  [INFERRED] [semantically similar]
  android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png → ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png
- `iOS Launch Image Setup Guide` --conceptually_related_to--> `RoadSOS Project Overview`  [INFERRED]
  ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md → README.md
- `RoadSOS App Icon (Android)` --semantically_similar_to--> `RoadSOS App Icon (iOS)`  [EXTRACTED] [semantically similar]
  android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png → ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png

## Hyperedges (group relationships)
- **Brand Visual Identity** — road_sos_app_icon, ios_app_icon, road_sos_launch_screen [INFERRED 0.90]

## Communities

### Community 0 - "Hardware SOS Trigger & Dashboard"
Cohesion: 0.17
Nodes (11): HardwareTriggerService, _initChannel, build, DashboardScreen, Padding, Scaffold, SizedBox, Text (+3 more)

### Community 1 - "App Entry Point & Theming"
Cohesion: 0.18
Nodes (10): database/app_database.dart, build, DynamicColorBuilder, initializeDatabase, main, MaterialApp, RoadSOSApp, package:dynamic_color/dynamic_color.dart (+2 more)

### Community 2 - "Offline Database & PowerSync"
Cohesion: 0.22
Nodes (7): PowerSyncCredentials, SupabaseConnector, package:path/path.dart, package:path_provider/path_provider.dart, package:powersync/powersync.dart, package:supabase_flutter/supabase_flutter.dart, schema.dart

### Community 3 - "iOS Native Volume Button Trigger"
Cohesion: 0.29
Nodes (3): AppDelegate, FlutterAppDelegate, FlutterImplicitEngineDelegate

### Community 4 - "Edge AI Triage & Mesh Network"
Cohesion: 0.25
Nodes (6): dart:convert, AiTriageService, launchUrl, MeshNetworkService, package:flutter_blue_plus/flutter_blue_plus.dart, package:url_launcher/url_launcher.dart

### Community 5 - "Android Flutter Plugin Registry"
Cohesion: 0.4
Nodes (2): GeneratedPluginRegistrant, -registerWithRegistry

### Community 6 - "Android SOS MainActivity"
Cohesion: 0.4
Nodes (1): MainActivity

### Community 7 - "Testing & Widget Tests"
Cohesion: 0.4
Nodes (4): package:flutter/material.dart, package:flutter_test/flutter_test.dart, package:roadsos/main.dart, main

### Community 8 - "iOS LLDB Debug Helpers"
Cohesion: 0.5
Nodes (2): handle_new_rx_page(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.

### Community 9 - "iOS XCTest Runner"
Cohesion: 0.5
Nodes (2): RunnerTests, XCTestCase

### Community 10 - "Project Documentation"
Cohesion: 0.5
Nodes (4): Road Accident Emergency Platform, Golden Hour Emergency Optimization, iOS Launch Image Setup Guide, RoadSOS Project Overview

### Community 11 - "Brand Visual Identity & Assets"
Cohesion: 0.5
Nodes (4): Flutter Multi-Density Asset Pipeline, RoadSOS App Icon (iOS), RoadSOS App Icon (Android), RoadSOS Launch Screen

### Community 12 - "iOS Scene Delegate"
Cohesion: 0.67
Nodes (2): FlutterSceneDelegate, SceneDelegate

### Community 13 - "Android Build Config"
Cohesion: 1.0
Nodes (0): 

### Community 14 - "Android Settings"
Cohesion: 1.0
Nodes (0): 

### Community 15 - "Android App Build Config"
Cohesion: 1.0
Nodes (0): 

### Community 16 - "iOS Plugin Registrant Header"
Cohesion: 1.0
Nodes (0): 

### Community 17 - "iOS Bridging Header"
Cohesion: 1.0
Nodes (0): 

## Knowledge Gaps
- **39 isolated node(s):** `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry`, `RoadSOSApp`, `main`, `initializeDatabase` (+34 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Android Build Config`** (1 nodes): `build.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Android Settings`** (1 nodes): `settings.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Android App Build Config`** (1 nodes): `build.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `iOS Plugin Registrant Header`** (1 nodes): `GeneratedPluginRegistrant.h`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `iOS Bridging Header`** (1 nodes): `Runner-Bridging-Header.h`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter_riverpod/flutter_riverpod.dart` connect `Hardware SOS Trigger & Dashboard` to `App Entry Point & Theming`, `Testing & Widget Tests`?**
  _High betweenness centrality (0.043) - this node is a cross-community bridge._
- **Why does `package:flutter/material.dart` connect `Testing & Widget Tests` to `Hardware SOS Trigger & Dashboard`, `App Entry Point & Theming`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **What connects `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry`, `RoadSOSApp` to the rest of the system?**
  _39 weakly-connected nodes found - possible documentation gaps or missing edges._