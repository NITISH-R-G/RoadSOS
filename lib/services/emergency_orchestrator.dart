import 'dart:async';
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

class SOSState {
  final SOSPhase phase;
  final int countdownSeconds;
  final LocationFix? location;
  final TriageResult? triageResult;
  final List<SOSStatusMessage> statusLog;
  final String? incidentId;
  final List<Facility> nearbyFacilities;
  final bool isBystander;
  final List<DispatchChannelRow> dispatchChannels;
  final bool wasInDrivingMode;

  const SOSState({
    this.phase = SOSPhase.idle,
    this.countdownSeconds = 10,
    this.location,
    this.triageResult,
    this.statusLog = const [],
    this.incidentId,
    this.nearbyFacilities = const [],
    this.isBystander = false,
    this.dispatchChannels = const [],
    this.wasInDrivingMode = false,
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
    List<DispatchChannelRow>? dispatchChannels,
    bool? wasInDrivingMode,
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
      dispatchChannels: dispatchChannels ?? this.dispatchChannels,
      wasInDrivingMode: wasInDrivingMode ?? this.wasInDrivingMode,
    );
  }
}

class EmergencyOrchestrator extends StateNotifier<SOSState> {
  final Ref _ref;
  Timer? _countdownTimer;
  final _uuid = const Uuid();
  static const Duration _sosLocationTimeout = Duration(seconds: 12);
  static const Duration _sosTriageTimeout = Duration(seconds: 10);
  static const Duration _dispatchChannelTimeout = Duration(seconds: 8);

  EmergencyOrchestrator(this._ref) : super(const SOSState()) {
    _restoreState();
    _ref.read(crashDetectionServiceProvider).startMonitoring();
    unawaited(TriageFeedbackService.instance.initialize());
  }

  Future<void> _restoreState() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('sos_active') ?? false) {
      _log('🚨 Recovering active SOS state after restart...', SOSPhase.active);
      state = state.copyWith(
        phase: SOSPhase.active,
        incidentId: prefs.getString('sos_id'),
      );
      await WakeLockService.acquireForSos();
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

    if (isDriving) {
      final voice = _ref.read(voiceAssistantServiceProvider);
      unawaited(voice.speakHandsFreeCountdown(10, 'Location being acquired'));

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
    unawaited(WakeLockService.release());
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

    // Phase 7: Agentic Takeover announcement.
    if (state.wasInDrivingMode) {
      final voice = _ref.read(voiceAssistantServiceProvider);
      unawaited(voice.speakAgenticTakeover(
        'Accident detected. Gemma 4 is taking control of this device to secure help.',
      ));
    }

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
    }

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

    _log(l10n.orchestratorDispatching, SOSPhase.dispatching);
    state = state.copyWith(
      phase: SOSPhase.dispatching,
      dispatchChannels: _initialDispatchRows(),
    );

    if (state.wasInDrivingMode) {
      final voice = _ref.read(voiceAssistantServiceProvider);
      unawaited(voice.speak('Triage complete. Initiating emergency protocols. Broadcasting mesh beacon and alerting your emergency contacts now.'));
    }

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
      timeoutDetail: 'Mesh timed out.',
      failureDetail: 'Mesh failed.',
    ).then((meshOk) {
      _patchDispatchChannel(
        'mesh',
        meshOk ? DispatchChannelLifecycle.success : DispatchChannelLifecycle.failed,
        meshOk ? 'Mesh active ✓' : 'Mesh failed.',
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
        detail: 'SMS timed out.',
      ),
      timeoutDetail: 'SMS timed out.',
      failureDetail: 'SMS failed.',
    ).then((smsOutcome) {
      _patchDispatchChannel(
        'sms',
        smsOutcome.primaryAutomatedBarMet ? DispatchChannelLifecycle.success : DispatchChannelLifecycle.failed,
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
      fallback: (ok: false, detail: 'Log timed out.'),
      timeoutDetail: 'Log timed out.',
      failureDetail: 'Log failed.',
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
      fallback: (ok: false, detail: 'Link timed out.'),
      timeoutDetail: 'Link timed out.',
      failureDetail: 'Link failed.',
    ).then((family) {
      _patchDispatchChannel(
        'family_link',
        family.ok ? DispatchChannelLifecycle.success : DispatchChannelLifecycle.failed,
        family.detail,
      );
      return family;
    });

    await Future.wait([meshFuture, smsFuture, persistedFuture, familyFuture]);

    state = state.copyWith(phase: SOSPhase.active);
    await _persistState(true);
    await WakeLockService.acquireForSos();

    if (state.wasInDrivingMode) {
      final voice = _ref.read(voiceAssistantServiceProvider);
      unawaited(voice.speakTriageSummary(
        severity: triage.severityLevel,
        services: triage.requiredServices,
        locationCoords: '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}',
      ));
    }
  }

  Future<SmsDispatchOutcome> _dispatchSmsWithRetry(String payload, {double? lat, double? lng}) async {
    final mesh = _ref.read(meshNetworkServiceProvider);
    final first = await mesh.triggerSmsFallback(payload, lat: lat, lng: lng);
    if (first.primaryAutomatedBarMet) return first;
    await Future<void>.delayed(const Duration(seconds: 3));
    return await mesh.triggerSmsFallback(payload, lat: lat, lng: lng);
  }

  List<DispatchChannelRow> _initialDispatchRows() {
    return const [
      DispatchChannelRow(id: 'mesh', title: 'Mesh beacon (BLE)', lifecycle: DispatchChannelLifecycle.pending, detail: 'Waiting…'),
      DispatchChannelRow(id: 'sms', title: 'SMS to emergency number', lifecycle: DispatchChannelLifecycle.pending, detail: 'Waiting…'),
      DispatchChannelRow(id: 'local_log', title: 'On-device incident log', lifecycle: DispatchChannelLifecycle.pending, detail: 'Waiting…'),
      DispatchChannelRow(id: 'family_link', title: 'Family tracking link', lifecycle: DispatchChannelLifecycle.pending, detail: 'Waiting…'),
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
    if (kIsWeb || !isDatabaseInitialized) return (ok: false, detail: 'Database off.');
    try {
      final now = DateTime.now().toIso8601String();
      await appDb.execute(
        'INSERT INTO reported_incidents (id, latitude, longitude, severity, services_needed, status, reported_at, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [incidentId, location.latitude, location.longitude, triage.severityLevel, triage.requiredServices.join(','), 'dispatched', now, now],
      );
      return (ok: true, detail: 'Saved ✓');
    } catch (e) {
      return (ok: false, detail: 'Error.');
    }
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
