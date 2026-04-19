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
import 'package:flutter/material.dart';

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
class EmergencyOrchestrator extends StateNotifier<SOSState> {
  final Ref _ref;
  Timer? _countdownTimer;
  final _uuid = const Uuid();

  EmergencyOrchestrator(this._ref) : super(const SOSState()) {
    _restoreState();
    _ref.read(crashDetectionServiceProvider).startMonitoring();
  }

  Future<void> _restoreState() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('sos_active') ?? false) {
      _log('🚨 Recovering active SOS state after restart...', SOSPhase.active);
      state = state.copyWith(
        phase: SOSPhase.active, 
        incidentId: prefs.getString('sos_id')
      );
    }
  }

  Future<void> _persistState(bool active) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sos_active', active);
    await prefs.setString('sos_id', state.incidentId ?? '');
  }

  void _log(String message, SOSPhase phase, {bool isError = false}) {
    final msg = SOSStatusMessage(message: message, phase: phase, isError: isError);
    state = state.copyWith(statusLog: [msg, ...state.statusLog]);
    debugPrint('🚒 [ORCHESTRATOR] $message');
  }

  /// Trigger the emergency cascade.
  Future<void> startSos({bool isBystander = false}) async {
    if (state.phase != SOSPhase.idle) return;

    state = state.copyWith(
      phase: SOSPhase.countdown,
      isBystander: isBystander,
      incidentId: _uuid.v4(),
    );
    
    _log(isBystander ? 'Bystander Alert Initiated' : 'Self-SOS Initiated', SOSPhase.countdown);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdownSeconds > 1) {
        state = state.copyWith(countdownSeconds: state.countdownSeconds - 1);
      } else {
        timer.cancel();
        _executeEmergencyPipeline();
      }
    });
  }

  void cancelSos() {
    _countdownTimer?.cancel();
    state = const SOSState();
    _persistState(false);
    _log('SOS Cancelled by user', SOSPhase.idle);
  }

  Future<void> _executeEmergencyPipeline() async {
    _log('Acquiring location fix...', SOSPhase.gpsLocking);
    state = state.copyWith(phase: SOSPhase.gpsLocking);
    
    final location = await _ref.read(locationServiceProvider).getCurrentLocation();
    state = state.copyWith(location: location);
    _log('Location secured: ${location.latitude}, ${location.longitude}', SOSPhase.gpsLocking);

    _log('Gemma 4: Generating Situational Brief...', SOSPhase.triaging);
    state = state.copyWith(phase: SOSPhase.triaging);
    
    final triage = await _ref.read(aiTriageServiceProvider).performTriage(
      location: location,
      isBystander: state.isBystander,
    );
    state = state.copyWith(triageResult: triage);
    _log('AI Triage Complete: ${triage.severityLevel.toString()}', SOSPhase.triaging);

    _log('Dispatching connectivity cascade...', SOSPhase.dispatching);
    state = state.copyWith(phase: SOSPhase.dispatching);

    // Mesh Broadcast
    await _ref.read(meshNetworkServiceProvider).startBroadcasting(
      triage.compressedPayload,
      lat: location.latitude,
      lng: location.longitude,
    );
    
    // SMS Fallback if needed
    await _ref.read(meshNetworkServiceProvider).triggerSmsFallback(triage.compressedPayload);

    // ── Pipeline Complete ─────────────────────────────────
    state = state.copyWith(phase: SOSPhase.active);
    await _persistState(true);
    _log('🚨 SOS IS LIVE — all channels active', SOSPhase.active);
  }
  void triggerSOS() => startSos();
  void cancelSOS() => cancelSos();
}

final emergencyOrchestratorProvider = StateNotifierProvider<EmergencyOrchestrator, SOSState>((ref) {
  return EmergencyOrchestrator(ref);
});

final voiceAssistantServiceProvider = Provider<VoiceAssistantService>((ref) {
  return VoiceAssistantService();
});

final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});
