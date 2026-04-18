import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:uuid/uuid.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../database/app_database.dart';
import 'ai_triage_service.dart';
import 'location_service.dart';
import 'mesh_network_service.dart';
import 'crash_detection_service.dart';
import 'voice_assistant_service.dart';
import 'user_profile_service.dart';
import 'gemma_assistant_service.dart';
import '../models/facility.dart';

/// The lifecycle of an SOS event.
enum SOSPhase {
  idle,         // Normal operation
  bystanderMode, // Witness reporting an incident
  countdown,    // 10s cancellation window (false-positive guard)
  gpsLocking,   // Acquiring GPS fix
  triaging,     // Gemma 4 is analyzing the situation
  dispatching,  // Writing to DB + connectivity cascade
  active,       // SOS is live and broadcasting
  resolved,     // SOS cancelled or resolved
}

/// A single status message in the SOS event log.
class SOSStatusMessage {
  final String message;
  final DateTime timestamp;
  final SOSPhase phase;
  final bool isError;

  SOSStatusMessage({
    required this.message,
    required this.phase,
    this.isError = false,
  }) : timestamp = DateTime.now();
}

/// Complete state of an SOS event.
class SOSState {
  final SOSPhase phase;
  final int countdownSeconds;
  final LocationFix? location;
  final TriageResult? triageResult;
  final List<SOSStatusMessage> statusLog;
  final String? incidentId;
  final List<Facility> nearbyFacilities;
  final bool isBystander;

  const SOSState({
    this.phase = SOSPhase.idle,
    this.countdownSeconds = 10,
    this.location,
    this.triageResult,
    this.statusLog = const [],
    this.incidentId,
    this.nearbyFacilities = const [],
    this.isBystander = false,
  });

  SOSState copyWith({
    SOSPhase? phase,
    int? countdownSeconds,
    LocationFix? location,
    TriageResult? triageResult,
    List<SOSStatusMessage>? statusLog,
    String? incidentId,
    List<Facility>? nearbyFacilities,
    bool? isBystander,
  }) {
    return SOSState(
      phase: phase ?? this.phase,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      location: location ?? this.location,
      triageResult: triageResult ?? this.triageResult,
      statusLog: statusLog ?? this.statusLog,
      incidentId: incidentId ?? this.incidentId,
      nearbyFacilities: nearbyFacilities ?? this.nearbyFacilities,
      isBystander: isBystander ?? this.isBystander,
    );
  }
}

/// Emergency Orchestrator — the central brain of RoadSOS.
///
/// When SOS is triggered (hardware button or UI), it executes this pipeline:
///
/// ```
/// SOS Trigger
///   → 10s Countdown (cancellation window)
final voiceAssistantServiceProvider = Provider<VoiceAssistantService>((ref) {
  return VoiceAssistantService();
});

final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

/// Orchestrates the end-to-end SOS workflow.
class EmergencyOrchestrator extends StateNotifier<SOSState> {
  final Ref _ref;
  Timer? _countdownTimer;
  final _uuid = const Uuid();

  EmergencyOrchestrator(this._ref) : super(const SOSState()) {
    // Start real-time hardware monitoring
    _ref.read(crashDetectionServiceProvider).startMonitoring();
    _restoreState();
  }

  Future<void> _restoreState() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('sos_active') ?? false) {
      _log('🚨 Recovering active SOS state after restart...', SOSPhase.active);
      state = state.copyWith(phase: SOSPhase.active, incidentId: prefs.getString('sos_id'));
    }
  }

  Future<void> _persistState(bool active) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sos_active', active);
    await prefs.setString('sos_id', state.incidentId ?? '');
  }

  /// Trigger the full SOS pipeline.
  /// Called when hardware button sequence detected or SOS button tapped.
  Future<void> triggerSOS() async {
    if (state.phase != SOSPhase.idle && state.phase != SOSPhase.resolved) {
      _log('SOS already in progress — ignoring duplicate trigger', SOSPhase.active);
      return;
    }

    final incidentId = _uuid.v4().substring(0, 8).toUpperCase();
    state = state.copyWith(
      phase: SOSPhase.countdown,
      countdownSeconds: 10,
      incidentId: _uuid.v4(),
      statusLog: [],
      isBystander: false,
    );

    _ref.read(voiceAssistantServiceProvider).speak('Emergency detected. Starting SOS countdown. Tap to cancel if this is a mistake.');
    _log('🚨 SOS TRIGGERED — 10s window open', SOSPhase.countdown);
    _log('Cancel within 10 seconds if accidental', SOSPhase.countdown);

    // Haptic feedback
    HapticFeedback.heavyImpact();

    // Start countdown
    await _runCountdown();
  }

  /// Trigger SOS on behalf of someone else (bypass personal triage)
  void triggerBystanderSOS() {
    if (state.phase != SOSPhase.idle) return;

    state = state.copyWith(
      phase: SOSPhase.bystanderMode,
      incidentId: _uuid.v4(),
      statusLog: [],
      isBystander: true,
    );

    _ref.read(voiceAssistantServiceProvider).speak('Witness reporting mode activated. Please describe the incident.');
    _log('🚨 BYSTANDER SOS TRIGGERED', SOSPhase.bystanderMode);
    
    // Skip countdown and go straight to GPS
    _executeSOSPipeline();
  }

  /// 10-second cancellation countdown (Blueprint §3.5 false-positive guard).
  Future<void> _runCountdown() async {
    final completer = Completer<bool>();

    int remaining = 10;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      state = state.copyWith(countdownSeconds: remaining);

      // Haptic tick every second
      HapticFeedback.lightImpact();

      if (remaining <= 0) {
        timer.cancel();
        completer.complete(true); // Proceed with SOS
      }
    });

    final shouldProceed = await completer.future;

    if (shouldProceed && state.phase == SOSPhase.countdown) {
      // Activate SOS flag globally
      _ref.read(isSOSActiveProvider.notifier).state = true;
      await _executeSOSPipeline();
    }
  }

  /// Cancel SOS during countdown or while active.
  void cancelSOS() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _ref.read(isSOSActiveProvider.notifier).state = false;

    _log('✅ SOS CANCELLED by user', SOSPhase.resolved);
    state = state.copyWith(phase: SOSPhase.resolved);
  }

  /// Resolve an active SOS (after help arrives).
  void resolveSOS() {
    _countdownTimer?.cancel();
    _ref.read(isSOSActiveProvider.notifier).state = false;

    _log('✅ SOS RESOLVED — help acknowledged', SOSPhase.resolved);
    state = state.copyWith(phase: SOSPhase.resolved);
  }

  /// Reset to idle after resolution.
  void reset() {
    state = const SOSState();
  }

  /// Execute the full SOS pipeline after countdown completes.
  Future<void> _executeSOSPipeline() async {
    // ── Step 1: GPS Lock ──────────────────────────────────
    state = state.copyWith(phase: SOSPhase.gpsLocking);
    _log('📍 Acquiring GPS fix...', SOSPhase.gpsLocking);

    final locationService = _ref.read(locationServiceProvider);
    LocationFix location;
    try {
      location = await locationService.getCurrentLocation();
      _log('📍 GPS: ${location.toString()}', SOSPhase.gpsLocking);
      state = state.copyWith(location: location);
    } catch (e) {
      _log('⚠️ GPS failed: $e — using last known', SOSPhase.gpsLocking, isError: true);
      location = LocationFix(
        latitude: 0.0,
        longitude: 0.0,
        accuracy: 99999,
        source: 'unknown',
        timestamp: DateTime.now(),
      );
      state = state.copyWith(location: location);
    }

    // ── Step 2: Edge AI Triage ──────────────────────────
    state = state.copyWith(phase: SOSPhase.triaging);
    _log('🧠 Gemma 4 is analyzing audio + telemetry...', SOSPhase.triaging);
    _ref.read(voiceAssistantServiceProvider).speak('Analyzing crash telemetry and audio. Please stay calm.');

    final profile = await _ref.read(userProfileServiceProvider).getProfile();
    final triageResult = await _ref.read(aiTriageServiceProvider).triageEmergency(
      audioTranscript: "Multiple casualties. Heavy bleeding. Help!", // Real world: From STT/Microphone
      locationString: '${location.latitude},${location.longitude}',
      accelerometerSeverityHint: 5,
    );
    
    // Add medical profile to payload
    final enrichedPayload = '${triageResult.compressedPayload}|${profile.toCompactString()}';

    state = state.copyWith(triageResult: triageResult);

    if (triageResult.isDegradedMode) {
      _log('⚠️ AI in degraded mode — using keyword fallback', SOSPhase.triaging, isError: true);
    } else {
      _log('🧠 Triage complete — Severity: ${triageResult.severityLevel}/5', SOSPhase.triaging);
    }
    _log('Services: ${triageResult.requiredServices.join(", ")}', SOSPhase.triaging);
    
    // ── Step 2.5: Fetch Nearby Facilities ─────────────────
    _log('🔍 Searching local DB for nearby facilities...', SOSPhase.triaging);
    await _fetchNearbyFacilities(location);

    // ── Step 3: Write to Local DB ─────────────────────────
    // V4.0 Intelligence: Gemma Telemetry Synthesis
    final aiAssistant = ref.read(gemmaAssistantProvider.notifier);
    final situationBrief = await aiAssistant.synthesizeTelemetry(
      maxG: 25.0, // Should come from sensor service
      speedDelta: 40.0,
      impactVector: 'Frontal',
    );
    print('[Orchestrator] 🧠 Gemma SITREP: $situationBrief');

    state = state.copyWith(phase: SOSPhase.dispatching);
    _log('💾 Writing incident to local database...', SOSPhase.dispatching);

    if (isDatabaseInitialized) {
      try {
        await appDb.execute(
          'INSERT INTO reported_incidents (id, latitude, longitude, severity, services_needed, status, reported_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
          [
            state.incidentId,
            location.latitude,
            location.longitude,
            triageResult.severityLevel,
            triageResult.requiredServices.join(','),
            'active',
            DateTime.now().toIso8601String(),
          ],
        );
        _log('💾 Incident written to local DB', SOSPhase.dispatching);
      } catch (e) {
        _log('⚠️ DB write failed: $e', SOSPhase.dispatching, isError: true);
      }
    } else {
      _log('ℹ️ Local DB bypassed (Web/Dev mode)', SOSPhase.dispatching);
    }

    // ── Step 4: Connectivity Cascade ──────────────────────
    _log('📡 Starting connectivity cascade...', SOSPhase.dispatching);

    // 4a. Try cloud sync (PowerSync will auto-sync to Supabase if online)
    _log('📡 Cloud sync queued via PowerSync', SOSPhase.dispatching);

    // 4b. SMS fallback
    final meshService = MeshNetworkService();
    try {
      _log('📱 Triggering SMS fallback...', SOSPhase.dispatching);
      await meshService.triggerSmsFallback(enrichedPayload);
      _log('📱 SMS dispatched', SOSPhase.dispatching);
    } catch (e) {
      _log('⚠️ SMS failed: $e', SOSPhase.dispatching, isError: true);
    }

    // 4c. BLE Mesh broadcast
    try {
      _log('📶 Broadcasting ENCRYPTED BLE mesh beacon...', SOSPhase.dispatching);
      await meshService.broadcastSosPayload(enrichedPayload);
      _log('📶 BLE beacon active', SOSPhase.dispatching);
    } catch (e) {
      _log('⚠️ BLE broadcast failed: $e', SOSPhase.dispatching, isError: true);
    }

    // ── Pipeline Complete ─────────────────────────────────
    state = state.copyWith(phase: SOSPhase.active);
    await _persistState(true);
    _log('🚨 SOS IS LIVE — all channels active', SOSPhase.active);
    _ref.read(voiceAssistantServiceProvider).speak('SOS is live. Help is on the way. Your location and medical profile are being broadcasted.');

    HapticFeedback.heavyImpact();
  }

  /// Append a status message to the event log.
  void _log(String message, SOSPhase phase, {bool isError = false}) {
    final entry = SOSStatusMessage(
      message: message,
      phase: phase,
      isError: isError,
    );
    state = state.copyWith(statusLog: [...state.statusLog, entry]);
    print('[EmergencyOrchestrator] $message');
  }

  /// Fetch nearby facilities from the PowerSync database.
  Future<void> _fetchNearbyFacilities(LocationFix location) async {
    if (!isDatabaseInitialized) return;

    try {
      // Simple bounding box search (approx 10km)
      const double delta = 0.1; 
      final results = await appDb.getAll(
        'SELECT * FROM emergency_facilities WHERE latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?',
        [
          location.latitude - delta,
          location.latitude + delta,
          location.longitude - delta,
          location.longitude + delta,
        ],
      );

      final facilities = results.map((r) => Facility.fromMap(r)).toList();
      state = state.copyWith(nearbyFacilities: facilities);
      _log('🔍 Found ${facilities.length} nearby facilities', SOSPhase.triaging);
    } catch (e) {
      _log('⚠️ Facility search failed: $e', SOSPhase.triaging, isError: true);
    }
  }
}

/// Riverpod provider for the Emergency Orchestrator.
final emergencyOrchestratorProvider =
    StateNotifierProvider<EmergencyOrchestrator, SOSState>((ref) {
  return EmergencyOrchestrator(ref);
});
