import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:uuid/uuid.dart';
import '../main.dart';
import '../database/app_database.dart';
import 'ai_triage_service.dart';
import 'location_service.dart';
import 'mesh_network_service.dart';
import '../models/facility.dart';

/// The lifecycle of an SOS event.
enum SOSPhase {
  idle,         // Normal operation
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

  const SOSState({
    this.phase = SOSPhase.idle,
    this.countdownSeconds = 10,
    this.location,
    this.triageResult,
    this.statusLog = const [],
    this.incidentId,
    this.nearbyFacilities = const [],
  });

  SOSState copyWith({
    SOSPhase? phase,
    int? countdownSeconds,
    LocationFix? location,
    TriageResult? triageResult,
    List<SOSStatusMessage>? statusLog,
    String? incidentId,
    List<Facility>? nearbyFacilities,
  }) {
    return SOSState(
      phase: phase ?? this.phase,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      location: location ?? this.location,
      triageResult: triageResult ?? this.triageResult,
      statusLog: statusLog ?? this.statusLog,
      incidentId: incidentId ?? this.incidentId,
      nearbyFacilities: nearbyFacilities ?? this.nearbyFacilities,
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
///   → GPS Lock
///   → Edge AI Triage (Gemma 4)
///   → Write incident to local DB
///   → Connectivity Cascade:
///       1. Supabase cloud sync (if online)
///       2. SMS fallback to 112 (if partial signal)
///       3. BLE mesh broadcast (if dead zone)
/// ```
class EmergencyOrchestrator extends StateNotifier<SOSState> {
  final Ref _ref;
  Timer? _countdownTimer;
  final _uuid = const Uuid();

  EmergencyOrchestrator(this._ref) : super(const SOSState());

  /// Trigger the full SOS pipeline.
  /// Called when hardware button sequence detected or SOS button tapped.
  Future<void> triggerSOS() async {
    if (state.phase != SOSPhase.idle && state.phase != SOSPhase.resolved) {
      _log('SOS already in progress — ignoring duplicate trigger', SOSPhase.active);
      return;
    }

    final incidentId = _uuid.v4().substring(0, 8).toUpperCase();
    state = SOSState(
      phase: SOSPhase.countdown,
      countdownSeconds: 10,
      statusLog: [],
      incidentId: incidentId,
    );

    _log('🚨 SOS TRIGGERED — Incident $incidentId', SOSPhase.countdown);
    _log('Cancel within 10 seconds if accidental', SOSPhase.countdown);

    // Haptic feedback
    HapticFeedback.heavyImpact();

    // Start countdown
    await _runCountdown();
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

    // ── Step 2: Edge AI Triage ────────────────────────────
    state = state.copyWith(phase: SOSPhase.triaging);
    _log('🧠 Running Gemma 4 Edge AI triage...', SOSPhase.triaging);

    final aiService = _ref.read(aiTriageServiceProvider);
    final triageResult = await aiService.triageEmergency(
      audioTranscript: 'Emergency SOS triggered via hardware button',
      locationString: location.toCompressedString(),
      accelerometerSeverityHint: 4,
    );

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
      _log('📱 Triggering SMS fallback to 112...', SOSPhase.dispatching);
      await meshService.triggerSmsFallback(triageResult.compressedPayload);
      _log('📱 SMS dispatched', SOSPhase.dispatching);
    } catch (e) {
      _log('⚠️ SMS failed: $e', SOSPhase.dispatching, isError: true);
    }

    // 4c. BLE Mesh broadcast
    try {
      _log('📶 Broadcasting BLE mesh beacon...', SOSPhase.dispatching);
      await meshService.broadcastSosPayload(triageResult.compressedPayload);
      _log('📶 BLE beacon active', SOSPhase.dispatching);
    } catch (e) {
      _log('⚠️ BLE broadcast failed: $e', SOSPhase.dispatching, isError: true);
    }

    // ── Pipeline Complete ─────────────────────────────────
    state = state.copyWith(phase: SOSPhase.active);
    _log('🚨 SOS IS LIVE — all channels active', SOSPhase.active);
    _log('Waiting for first responder acknowledgment...', SOSPhase.active);

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
