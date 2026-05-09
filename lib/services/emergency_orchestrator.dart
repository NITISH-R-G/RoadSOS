import 'dart:async';
<<<<<<< HEAD
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
=======
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roadsos/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import '../models/dispatch_channel_status.dart';
import '../models/sos_activity_record.dart';
import 'ai_triage_service.dart';
import 'location_service.dart';
import 'mesh_network_service.dart';
import 'sms_dispatch_outcome.dart';
import 'crash_detection_service.dart';
import 'voice_assistant_service.dart';
import 'user_profile_service.dart';
import '../models/facility.dart';
import '../logging/app_log.dart';
import 'app_locale_controller.dart';
import 'facility_query_service.dart';
import 'facility_sync_service.dart';
import 'sos_activity_log_service.dart';
import 'family_tracking_service.dart';
import 'privacy_consent_service.dart';
import 'driving_mode_service.dart';
import 'wake_lock_service.dart';
import 'gyroscope_fusion_service.dart';
import 'triage_validation_agent.dart';
import 'triage_feedback_service.dart';

final facilityQueryServiceProvider = Provider<FacilityQueryService>((ref) {
  return FacilityQueryService();
});

final facilitySyncServiceProvider = Provider<FacilitySyncService>((ref) {
  return FacilitySyncService();
});

enum SOSPhase {
  idle,
  bystanderMode,
  countdown,
  gpsLocking,
  triaging,
  dispatching,
  active,
  resolved,
}

>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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

<<<<<<< HEAD
/// Complete state of an SOS event.
=======
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
class SOSState {
  final SOSPhase phase;
  final int countdownSeconds;
  final LocationFix? location;
  final TriageResult? triageResult;
  final List<SOSStatusMessage> statusLog;
  final String? incidentId;
  final List<Facility> nearbyFacilities;
  final bool isBystander;
<<<<<<< HEAD
=======
  final List<DispatchChannelRow> dispatchChannels;

  /// Whether the SOS was triggered while driving mode was active.
  final bool wasInDrivingMode;
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41

  const SOSState({
    this.phase = SOSPhase.idle,
    this.countdownSeconds = 10,
    this.location,
    this.triageResult,
    this.statusLog = const [],
    this.incidentId,
    this.nearbyFacilities = const [],
    this.isBystander = false,
<<<<<<< HEAD
=======
    this.dispatchChannels = const [],
    this.wasInDrivingMode = false,
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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
<<<<<<< HEAD
=======
    List<DispatchChannelRow>? dispatchChannels,
    bool? wasInDrivingMode,
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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
<<<<<<< HEAD
=======
      dispatchChannels: dispatchChannels ?? this.dispatchChannels,
      wasInDrivingMode: wasInDrivingMode ?? this.wasInDrivingMode,
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
    );
  }
}

/// Emergency Orchestrator — the central brain of RoadSOS.
<<<<<<< HEAD
=======
///
/// Phase 3 — Zero-hallucination safety validation:
///   After each AI tier returns a triage, [TriageValidationAgent] enforces
///   rule-based safety constraints (ambulance mandatory at sev ≥ 3, driving
///   mode severity floor = 3, gyro crash confirmation floor = 4) before the
///   result is shown to the user or passed to dispatch channels.
///
/// Phase 5 — Multi-agent observability:
///   Dispatch channels are registered in [dispatchChannels] with per-channel
///   lifecycle tracking (pending → inProgress → success | failed | skipped).
///   The UI shows each agent's status in real-time.
///
/// Phase 7 — Hands-free voice SOS:
///   When driving mode is active at trigger, the orchestrator speaks a
///   countdown announcement and listens for a voice cancel utterance in
///   parallel with the countdown timer. After dispatch, the triage summary is
///   spoken so the driver never needs to look at the screen.
///
/// Phase 8 — RL feedback loop:
///   Initializes [TriageFeedbackService] so the severity bias is available
///   for Tier 3 / Tier 4 classifiers immediately at app start.
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
class EmergencyOrchestrator extends StateNotifier<SOSState> {
  final Ref _ref;
  Timer? _countdownTimer;
  final _uuid = const Uuid();
<<<<<<< HEAD
=======
  static const Duration _sosLocationTimeout = Duration(seconds: 12);
  static const Duration _sosTriageTimeout = Duration(seconds: 10);
  static const Duration _dispatchChannelTimeout = Duration(seconds: 8);
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41

  EmergencyOrchestrator(this._ref) : super(const SOSState()) {
    _restoreState();
    _ref.read(crashDetectionServiceProvider).startMonitoring();
<<<<<<< HEAD
=======
    // Phase 8: ensure RL bias is loaded before any SOS fires.
    unawaited(TriageFeedbackService.instance.initialize());
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
  }

  Future<void> _restoreState() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('sos_active') ?? false) {
      _log('🚨 Recovering active SOS state after restart...', SOSPhase.active);
      state = state.copyWith(
<<<<<<< HEAD
        phase: SOSPhase.active, 
        incidentId: prefs.getString('sos_id')
      );
=======
        phase: SOSPhase.active,
        incidentId: prefs.getString('sos_id'),
      );
      await WakeLockService.acquireForSos();
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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
<<<<<<< HEAD
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
=======
    appLog.d('🚒 [ORCHESTRATOR] $message');
  }

  Future<void> startSos({bool isBystander = false}) async {
    if (state.phase != SOSPhase.idle) return;

    final isDriving = _ref.read(drivingModeProvider) == DrivingMode.driving;

    state = state.copyWith(
      phase: SOSPhase.countdown,
      countdownSeconds: 10,
      isBystander: isBystander,
      incidentId: _uuid.v4(),
      dispatchChannels: const [],
      wasInDrivingMode: isDriving,
    );

    final l10n = lookupAppLocalizations(_ref.read(appLocaleProvider));
    _log(
      isBystander
          ? l10n.orchestratorBystanderStarted
          : l10n.orchestratorSelfSosStarted,
      SOSPhase.countdown,
    );

    // Phase 7: hands-free countdown announcement when driving.
    // Spoken once at the start — no per-tick repetition to avoid interfering
    // with voice cancel listening which runs in parallel.
    if (isDriving) {
      final voice = _ref.read(voiceAssistantServiceProvider);
      unawaited(voice.speakHandsFreeCountdown(10, 'Location being acquired'));

      // Listen for voice cancel in parallel with countdown timer.
      // If the user says "cancel"/"stop"/locale equivalent → abort SOS.
      unawaited(
        voice
            .listenForCancel(listenFor: const Duration(seconds: 9))
            .then((cancelled) {
          if (cancelled && state.phase == SOSPhase.countdown) {
            appLog.i('[Orchestrator] Voice cancel detected — aborting SOS');
            cancelSos();
          }
        }),
      );
    }
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41

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
<<<<<<< HEAD
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
    _log('AI Triage Complete: ${triage.severity.name.toUpperCase()}', SOSPhase.triaging);

    _log('Dispatching connectivity cascade...', SOSPhase.dispatching);
    state = state.copyWith(phase: SOSPhase.dispatching);

    // Mesh Broadcast
    await _ref.read(meshNetworkServiceProvider).startBroadcasting(
      triage.encryptedPayload,
      lat: location.latitude,
      lng: location.longitude,
    );
    
    // SMS Fallback if needed
    await _ref.read(meshNetworkServiceProvider).triggerSmsFallback(triage.encryptedPayload);

    // ── Pipeline Complete ─────────────────────────────────
    state = state.copyWith(phase: SOSPhase.active);
    await _persistState(true);
    _log('🚨 SOS IS LIVE — all channels active', SOSPhase.active);
  }
=======
    unawaited(WakeLockService.release());
    // Stop any in-progress TTS so the countdown announcement does not keep playing.
    unawaited(_ref.read(voiceAssistantServiceProvider).stopSpeaking());
    final l10n = lookupAppLocalizations(_ref.read(appLocaleProvider));
    _log(l10n.orchestratorCancelled, SOSPhase.idle);
  }

  Future<void> _executeEmergencyPipeline() async {
    final l10n = lookupAppLocalizations(_ref.read(appLocaleProvider));
    final locale = _ref.read(appLocaleProvider);

    Future<void> failOpenToActive(String detail) async {
      _log(detail, SOSPhase.active, isError: true);
      state = state.copyWith(
        phase: SOSPhase.active,
        dispatchChannels: state.dispatchChannels.isEmpty ? _initialDispatchRows() : state.dispatchChannels,
      );
      await _persistState(true);
      await WakeLockService.acquireForSos();
    }

    _log(l10n.orchestratorAcquiringLocation, SOSPhase.gpsLocking);
    state = state.copyWith(phase: SOSPhase.gpsLocking);

    LocationFix location;
    try {
      location = await _ref
          .read(locationServiceProvider)
          .getCurrentLocation()
          .timeout(_sosLocationTimeout);
    } catch (e, st) {
      appLog.w('[Orchestrator] Location acquisition timed out/failed', error: e, stackTrace: st);
      location = LocationFix(
        latitude: 0,
        longitude: 0,
        accuracy: 99999,
        source: 'unknown',
        timestamp: DateTime.now(),
      );
    }
    state = state.copyWith(location: location);
    final locLine = location.source == 'unknown'
        ? l10n.orchestratorLocationUnavailable
        : l10n.orchestratorLocationSecured(
            location.latitude.toStringAsFixed(3),
            location.longitude.toStringAsFixed(3),
          );
    _log(locLine, SOSPhase.gpsLocking, isError: location.source == 'unknown');

    if (location.source == 'unknown') {
      _log(
        l10n.orchestratorManualActionRequired,
        SOSPhase.dispatching,
        isError: true,
      );
      state = state.copyWith(
        phase: SOSPhase.dispatching,
        dispatchChannels: _initialDispatchRows(),
      );
      _patchDispatchChannel('mesh', DispatchChannelLifecycle.skipped, 'Skipped — no usable GPS fix.');
      _patchDispatchChannel('family_link', DispatchChannelLifecycle.skipped, 'Skipped — no usable GPS fix.');
      _patchDispatchChannel('local_log', DispatchChannelLifecycle.failed, 'Not saved — no usable GPS fix.');
      _patchDispatchChannel('sms', DispatchChannelLifecycle.inProgress, 'Sending emergency SMS (no GPS)…');
      final smsOutcome = await _dispatchSmsWithRetry(
        l10n.orchestratorSmsNoGpsPayload,
        lat: null,
        lng: null,
      );
      _patchDispatchChannel(
        'sms',
        smsOutcome.primaryAutomatedBarMet
            ? DispatchChannelLifecycle.success
            : DispatchChannelLifecycle.failed,
        smsOutcome.detail,
      );
      state = state.copyWith(phase: SOSPhase.active);
      await _persistState(true);
      await WakeLockService.acquireForSos();
      _log(
        smsOutcome.primaryAutomatedBarMet
            ? 'Emergency session active — SMS requested without GPS.'
            : 'Emergency session active — automated SMS did not succeed; dial emergency number now.',
        SOSPhase.active,
        isError: !smsOutcome.primaryAutomatedBarMet,
      );
      return;
    }

    final facilities = await _ref.read(facilityQueryServiceProvider).queryNearby(
          location.latitude,
          location.longitude,
        );
    state = state.copyWith(nearbyFacilities: facilities);
    unawaited(
      _ref.read(facilitySyncServiceProvider).syncLocalRegion(
            location.latitude,
            location.longitude,
          ),
    );

    _log(l10n.orchestratorAiBrief, SOSPhase.triaging);
    state = state.copyWith(phase: SOSPhase.triaging);

    TriageResult rawTriage;
    try {
      rawTriage = await _ref
          .read(aiTriageServiceProvider)
          .performTriage(
            location: location,
            isBystander: state.isBystander,
            languageCode: locale.languageCode,
          )
          .timeout(_sosTriageTimeout);
    } catch (e, st) {
      appLog.w('[Orchestrator] Triage timed out/failed — using safety fallback', error: e, stackTrace: st);
      rawTriage = TriageResult(
        functionCall: 'dispatch_emergency',
        location: '${location.latitude},${location.longitude}',
        severityLevel: state.isBystander ? 3 : 4,
        requiredServices: const ['ambulance', 'police'],
        firstAidQuery: 'bleeding control / airway / spinal precautions',
        compressedPayload: location.toCompressedString(),
        thinkingTrace: null,
        isDegradedMode: true,
        source: TriageSource.localTier2,
        visionUsed: false,
      );
      _log(
        'AI triage timed out — using safety fallback severity ${rawTriage.severityLevel}.',
        SOSPhase.triaging,
        isError: true,
      );
    }

    // ── Phase 3: Safety validation gate ──────────────────────────────────
    // Read gyro peak over the 1.5s window around the moment of SOS trigger.
    // The gyro service has a 3s rolling buffer so the crash peak is still in
    // memory even though a few seconds elapsed during GPS lock + triage.
    final gyroService = _ref.read(gyroscopeFusionServiceProvider);
    final gyroPeak = gyroService.peakRadPerSecAt(DateTime.now(), windowMs: 3000);

    final validation = triageValidationAgent.validate(
      raw: rawTriage,
      drivingMode: _ref.read(drivingModeProvider),
      gyroPeakRadPerSec: gyroPeak,
      accelSeverityHint: state.isBystander ? 2 : 3,
    );

    final triage = validation.triage;
    state = state.copyWith(triageResult: triage);

    _log(l10n.orchestratorTriageDone(triage.severityLevel), SOSPhase.triaging);

    if (validation.wasOverridden) {
      _log(
        'Safety agent: ${validation.overrideNotes.length} override(s) applied. '
        'Confidence: ${triage.confidenceLabel}.',
        SOSPhase.triaging,
      );
    } else {
      _log(
        'Safety agent: triage validated — no overrides. '
        'Confidence: ${triage.confidenceLabel}.',
        SOSPhase.triaging,
      );
    }

    _log(l10n.orchestratorDispatching, SOSPhase.dispatching);
    state = state.copyWith(
      phase: SOSPhase.dispatching,
      dispatchChannels: _initialDispatchRows(),
    );

    final mesh = _ref.read(meshNetworkServiceProvider);

    _patchDispatchChannel('mesh', DispatchChannelLifecycle.inProgress, 'Broadcasting BLE beacon…');
    _patchDispatchChannel('sms', DispatchChannelLifecycle.inProgress, 'Sending emergency SMS…');
    _patchDispatchChannel('local_log', DispatchChannelLifecycle.inProgress, 'Saving incident on device…');
    _patchDispatchChannel('family_link', DispatchChannelLifecycle.inProgress, 'Family tracking link…');

    Future<T> guard<T>({
      required String id,
      required Future<T> future,
      required T fallback,
      required String timeoutDetail,
      required String failureDetail,
    }) async {
      try {
        return await future.timeout(
          _dispatchChannelTimeout,
          onTimeout: () {
            _patchDispatchChannel(id, DispatchChannelLifecycle.failed, timeoutDetail);
            return fallback;
          },
        );
      } catch (_) {
        _patchDispatchChannel(id, DispatchChannelLifecycle.failed, failureDetail);
        return fallback;
      }
    }

    final meshFuture = guard<bool>(
      id: 'mesh',
      future: mesh.startBroadcasting(
        triage.compressedPayload,
        lat: location.latitude,
        lng: location.longitude,
        severity: triage.severityLevel,
        services: triage.requiredServices,
      ),
      fallback: false,
      timeoutDetail: 'Mesh timed out — continue with SMS and manual action.',
      failureDetail: 'Mesh failed — Bluetooth off, unsupported, or error.',
    ).then((meshOk) {
      _patchDispatchChannel(
        'mesh',
        meshOk ? DispatchChannelLifecycle.success : DispatchChannelLifecycle.failed,
        meshOk
            ? 'Mesh beacon active — nearby app users can detect you ✓'
            : 'Mesh did not start — Bluetooth off, unsupported, or failed.',
      );
      return meshOk;
    });

    final smsFuture = guard<SmsDispatchOutcome>(
      id: 'sms',
      future: _dispatchSmsWithRetry(
        triage.compressedPayload,
        lat: location.latitude,
        lng: location.longitude,
      ),
      fallback: const SmsDispatchOutcome(
        deviceDirectSmsSent: false,
        backendRelayAccepted: false,
        primaryAutomatedBarMet: false,
        proofLevel: SmsDispatchProofLevel.none,
        detail: 'SMS timed out — use dialer/manual SMS now.',
      ),
      timeoutDetail: 'SMS timed out — use dialer/manual SMS now.',
      failureDetail: 'SMS failed — use dialer/manual SMS now.',
    ).then((smsOutcome) {
      _patchDispatchChannel(
        'sms',
        smsOutcome.primaryAutomatedBarMet
            ? DispatchChannelLifecycle.success
            : DispatchChannelLifecycle.failed,
        smsOutcome.detail,
      );
      return smsOutcome;
    });

    final persistedFuture = guard<({bool ok, String detail})>(
      id: 'local_log',
      future: _persistIncidentSnapshot(
        incidentId: state.incidentId ?? '',
        location: location,
        triage: triage,
      ),
      fallback: (ok: false, detail: 'Local log timed out — incident not saved.'),
      timeoutDetail: 'Local log timed out — incident not saved.',
      failureDetail: 'Local log failed — incident not saved.',
    ).then((persisted) {
      _patchDispatchChannel(
        'local_log',
        persisted.ok ? DispatchChannelLifecycle.success : DispatchChannelLifecycle.failed,
        persisted.detail,
      );
      return persisted;
    });

    final familyFuture = guard<({bool ok, String detail})>(
      id: 'family_link',
      future: _ref.read(familyTrackingServiceProvider).registerAndNotifyContact(
            incidentId: state.incidentId ?? '',
            location: location,
            triage: triage,
          ),
      fallback: (ok: false, detail: 'Family link timed out — share manually if needed.'),
      timeoutDetail: 'Family link timed out — share manually if needed.',
      failureDetail: 'Family link failed — share manually if needed.',
    ).then((family) {
      _patchDispatchChannel(
        'family_link',
        family.ok ? DispatchChannelLifecycle.success : DispatchChannelLifecycle.failed,
        family.detail,
      );
      return family;
    });

    List<Object?> results;
    try {
      results = await Future.wait([
        meshFuture,
        smsFuture,
        persistedFuture,
        familyFuture,
      ]).timeout(_dispatchChannelTimeout + const Duration(seconds: 1));
    } catch (e, st) {
      // Absolute guard: never hang in dispatching.
      appLog.w('[Orchestrator] Dispatch futures did not complete in time', error: e, stackTrace: st);
      await failOpenToActive('Dispatch timed out — take manual action (dial emergency number).');
      return;
    }

    final smsOutcome = results[1] as SmsDispatchOutcome;

    await SosActivityLogService.instance.append(
      SosActivityRecord(
        incidentId: state.incidentId ?? '',
        completedAtUtc: DateTime.now().toUtc(),
        latitude: location.latitude,
        longitude: location.longitude,
        accuracyM: location.accuracy,
        locationSource: location.source,
        triageSeverity: triage.severityLevel,
        triageSourceName: triage.source.name,
        requiredServices: List<String>.from(triage.requiredServices),
        channels: List<DispatchChannelRow>.from(state.dispatchChannels),
        syncStatusLine: _syncStatusLineForLog(),
        isBystander: state.isBystander,
      ),
    );

    final anyConfirmed = smsOutcome.primaryAutomatedBarMet;

    state = state.copyWith(phase: SOSPhase.active);
    await _persistState(true);

    // Acquire screen wake lock so the dispatch panel stays visible on a car seat.
    await WakeLockService.acquireForSos();

    _log(
      anyConfirmed
          ? 'Emergency session active — review each channel above for request status.'
          : 'Emergency session active — no automated emergency SMS request succeeded; take manual action (dial emergency number).',
      SOSPhase.active,
      isError: !anyConfirmed,
    );

    if (state.wasInDrivingMode) {
      _log(
        'SOS triggered during driving mode — incident context logged for ERSS report.',
        SOSPhase.active,
      );
    }

    // Phase 7: post-dispatch voice briefing — the driver hears what was sent.
    if (state.wasInDrivingMode) {
      final voice = _ref.read(voiceAssistantServiceProvider);
      unawaited(voice.speakTriageSummary(
        severity: triage.severityLevel,
        services: triage.requiredServices,
        locationCoords: '${location.latitude.toStringAsFixed(2)}, '
            '${location.longitude.toStringAsFixed(2)}',
      ));
    }
  }

  Future<SmsDispatchOutcome> _dispatchSmsWithRetry(
    String payload, {
    double? lat,
    double? lng,
  }) async {
    final mesh = _ref.read(meshNetworkServiceProvider);
    final first = await mesh.triggerSmsFallback(payload, lat: lat, lng: lng);
    if (first.primaryAutomatedBarMet) return first;

    appLog.d('[Orchestrator] SMS attempt 1 failed — retrying in 3s');
    await Future<void>.delayed(const Duration(seconds: 3));
    final retry = await mesh.triggerSmsFallback(payload, lat: lat, lng: lng);

    if (retry.primaryAutomatedBarMet) {
      appLog.i('[Orchestrator] SMS succeeded on retry ✓');
      return SmsDispatchOutcome(
        deviceDirectSmsSent: retry.deviceDirectSmsSent,
        backendRelayAccepted: retry.backendRelayAccepted,
        primaryAutomatedBarMet: true,
        proofLevel: retry.proofLevel,
        detail: '${retry.detail} (retry)',
      );
    }

    appLog.w('[Orchestrator] SMS failed after 2 attempts');
    return retry;
  }

  List<DispatchChannelRow> _initialDispatchRows() {
    return const [
      DispatchChannelRow(
        id: 'mesh',
        title: 'Mesh beacon (BLE)',
        lifecycle: DispatchChannelLifecycle.pending,
        detail: 'Waiting…',
      ),
      DispatchChannelRow(
        id: 'sms',
        title: 'SMS to emergency number',
        lifecycle: DispatchChannelLifecycle.pending,
        detail: 'Waiting…',
      ),
      DispatchChannelRow(
        id: 'local_log',
        title: 'On-device incident log',
        lifecycle: DispatchChannelLifecycle.pending,
        detail: 'Waiting…',
      ),
      DispatchChannelRow(
        id: 'family_link',
        title: 'Family tracking link',
        lifecycle: DispatchChannelLifecycle.pending,
        detail: 'Waiting…',
      ),
    ];
  }

  void _patchDispatchChannel(String id, DispatchChannelLifecycle lifecycle, String detail) {
    final list = List<DispatchChannelRow>.from(state.dispatchChannels);
    final i = list.indexWhere((e) => e.id == id);
    if (i >= 0) {
      list[i] = list[i].copyWith(lifecycle: lifecycle, detail: detail);
      state = state.copyWith(dispatchChannels: list);
    }
  }

  Future<({bool ok, String detail})> _persistIncidentSnapshot({
    required String incidentId,
    required LocationFix location,
    required TriageResult triage,
  }) async {
    if (kIsWeb || !isDatabaseInitialized) {
      return (
        ok: false,
        detail: 'Local database unavailable — incident not saved on device.',
      );
    }
    try {
      final now = DateTime.now().toIso8601String();
      final svc = triage.requiredServices.join(',');
      final extended = await PrivacyConsentService.extendedRetentionForUploads();
      await appDb.execute(
        '''INSERT INTO reported_incidents (
          id, latitude, longitude, severity, services_needed, status, reported_at, created_at, extended_retention
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        [
          incidentId,
          location.latitude,
          location.longitude,
          triage.severityLevel,
          svc,
          'dispatched',
          now,
          now,
          extended ? 1 : 0,
        ],
      );
      return (
        ok: true,
        detail: _hasSupabaseSession()
            ? 'Saved on device. Sync is enabled when network allows.'
            : 'Saved on device. Cloud sync needs Supabase credentials.',
      );
    } catch (e, st) {
      appLog.w('Local incident insert failed', error: e, stackTrace: st);
      return (ok: false, detail: 'Could not save incident log on device.');
    }
  }

  bool _hasSupabaseSession() {
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  String _syncStatusLineForLog() {
    if (kIsWeb) return 'Web — local encrypted incident log unavailable.';
    if (!isDatabaseInitialized) {
      return 'Local database off — incident row not stored on device.';
    }
    if (_hasSupabaseSession()) {
      return 'Saved on phone — sync enabled when network allows.';
    }
    return 'Saved on phone — enable Supabase anonymous auth for cloud backup.';
  }

  void triggerSOS() => startSos();
  void cancelSOS() => cancelSos();
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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
