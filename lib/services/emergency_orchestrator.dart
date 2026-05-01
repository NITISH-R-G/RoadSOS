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

final facilityQueryServiceProvider = Provider<FacilityQueryService>((ref) {
  return FacilityQueryService();
});

final facilitySyncServiceProvider = Provider<FacilitySyncService>((ref) {
  return FacilitySyncService();
});

/// The lifecycle of an SOS event.
enum SOSPhase {
  idle,         // Normal operation
  bystanderMode, // Witness reporting an incident
  countdown,    // 10s cancellation window (false-positive guard)
  gpsLocking,   // Acquiring GPS fix
  triaging,     // Cloud / heuristic triage
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

  /// Per-channel dispatch outcomes (SMS, mesh, local/cloud). Never replaces real confirmation with a timer.
  final List<DispatchChannelRow> dispatchChannels;

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
    appLog.d('🚒 [ORCHESTRATOR] $message');
  }

  /// Trigger the emergency cascade.
  Future<void> startSos({bool isBystander = false}) async {
    if (state.phase != SOSPhase.idle) return;

    state = state.copyWith(
      phase: SOSPhase.countdown,
      countdownSeconds: 10,
      isBystander: isBystander,
      incidentId: _uuid.v4(),
      dispatchChannels: const [],
    );
    
    final l10n = lookupAppLocalizations(_ref.read(appLocaleProvider));
    _log(
      isBystander
          ? l10n.orchestratorBystanderStarted
          : l10n.orchestratorSelfSosStarted,
      SOSPhase.countdown,
    );

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
    final l10n = lookupAppLocalizations(_ref.read(appLocaleProvider));
    _log(l10n.orchestratorCancelled, SOSPhase.idle);
  }

  Future<void> _executeEmergencyPipeline() async {
    final l10n = lookupAppLocalizations(_ref.read(appLocaleProvider));
    final locale = _ref.read(appLocaleProvider);

    _log(l10n.orchestratorAcquiringLocation, SOSPhase.gpsLocking);
    state = state.copyWith(phase: SOSPhase.gpsLocking);

    final location = await _ref.read(locationServiceProvider).getCurrentLocation();
    state = state.copyWith(location: location);
    // Never surface precise lat/lng in the live status log (privacy + shoulder-surf risk).
    final locLine = location.source == 'unknown'
        ? l10n.orchestratorLocationUnavailable
        : l10n.orchestratorLocationSecured(
            location.latitude.toStringAsFixed(3),
            location.longitude.toStringAsFixed(3),
          );
    _log(locLine, SOSPhase.gpsLocking, isError: location.source == 'unknown');

    if (location.source == 'unknown') {
      // Location is required for many downstream steps. Do not proceed with fake (0,0).
      _log(
        l10n.orchestratorManualActionRequired,
        SOSPhase.dispatching,
        isError: true,
      );
      state = state.copyWith(
        phase: SOSPhase.dispatching,
        dispatchChannels: _initialDispatchRows(),
      );
      _patchDispatchChannel(
        'mesh',
        DispatchChannelLifecycle.skipped,
        'Skipped — no usable GPS fix.',
      );
      _patchDispatchChannel(
        'family_link',
        DispatchChannelLifecycle.skipped,
        'Skipped — no usable GPS fix.',
      );
      _patchDispatchChannel(
        'local_log',
        DispatchChannelLifecycle.failed,
        'Not saved — no usable GPS fix.',
      );
      // SMS may still be attempted without GPS.
      _patchDispatchChannel(
        'sms',
        DispatchChannelLifecycle.inProgress,
        'Sending emergency SMS (no GPS)…',
      );
      final smsOutcome = await _ref.read(meshNetworkServiceProvider).triggerSmsFallback(
            l10n.orchestratorSmsNoGpsPayload,
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

    final triage = await _ref.read(aiTriageServiceProvider).performTriage(
      location: location,
      isBystander: state.isBystander,
      languageCode: locale.languageCode,
    );
    state = state.copyWith(triageResult: triage);
    _log(l10n.orchestratorTriageDone(triage.severityLevel), SOSPhase.triaging);

    _log(l10n.orchestratorDispatching, SOSPhase.dispatching);
    state = state.copyWith(
      phase: SOSPhase.dispatching,
      dispatchChannels: _initialDispatchRows(),
    );

    final mesh = _ref.read(meshNetworkServiceProvider);

    // Dispatch channels are started in parallel. Each completion patches its row.
    _patchDispatchChannel('mesh', DispatchChannelLifecycle.inProgress, 'Broadcasting BLE beacon…');
    _patchDispatchChannel('sms', DispatchChannelLifecycle.inProgress, 'Sending emergency SMS…');
    _patchDispatchChannel('local_log', DispatchChannelLifecycle.inProgress, 'Saving incident on device…');
    _patchDispatchChannel('family_link', DispatchChannelLifecycle.inProgress, 'Family tracking link…');

    final meshFuture = mesh
        .startBroadcasting(
          triage.compressedPayload,
          lat: location.latitude,
          lng: location.longitude,
        )
        .then((meshOk) {
      _patchDispatchChannel(
        'mesh',
        meshOk ? DispatchChannelLifecycle.success : DispatchChannelLifecycle.failed,
        meshOk
            ? 'Mesh beacon active — nearby app users can detect you ✓'
            : 'Mesh did not start — Bluetooth off, unsupported, or failed.',
      );
      return meshOk;
    });

    final smsFuture = mesh
        .triggerSmsFallback(
          triage.compressedPayload,
          lat: location.latitude,
          lng: location.longitude,
        )
        .then((smsOutcome) {
      // IMPORTANT: SMS "success" means our app/backend accepted the request, not guaranteed emergency receipt.
      _patchDispatchChannel(
        'sms',
        smsOutcome.primaryAutomatedBarMet
            ? DispatchChannelLifecycle.success
            : DispatchChannelLifecycle.failed,
        smsOutcome.detail,
      );
      return smsOutcome;
    });

    final persistedFuture = _persistIncidentSnapshot(
      incidentId: state.incidentId ?? '',
      location: location,
      triage: triage,
    ).then((persisted) {
      _patchDispatchChannel(
        'local_log',
        persisted.ok ? DispatchChannelLifecycle.success : DispatchChannelLifecycle.failed,
        persisted.detail,
      );
      return persisted;
    });

    final familyFuture = _ref
        .read(familyTrackingServiceProvider)
        .registerAndNotifyContact(
          incidentId: state.incidentId ?? '',
          location: location,
          triage: triage,
        )
        .then((family) {
      _patchDispatchChannel(
        'family_link',
        family.ok ? DispatchChannelLifecycle.success : DispatchChannelLifecycle.failed,
        family.detail,
      );
      return family;
    });

    final results = await Future.wait([
      meshFuture,
      smsFuture,
      persistedFuture,
      familyFuture,
    ]);

    final smsOutcome = results[1] as SmsDispatchOutcome;
    // results[0] mesh bool, results[2] persisted snapshot, results[3] family link are already reflected in dispatch rows.

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

    // "Confirmed" == the primary automated dispatch bar for emergency SMS.
    // Mesh + local logging + family link are helpful but do not prove emergency services were reached.
    final anyConfirmed = smsOutcome.primaryAutomatedBarMet;

    state = state.copyWith(phase: SOSPhase.active);
    await _persistState(true);
    _log(
      anyConfirmed
          ? 'Emergency session active — review each channel above for request status.'
          : 'Emergency session active — no automated emergency SMS request succeeded; take manual action (dial emergency number).',
      SOSPhase.active,
      isError: !anyConfirmed,
    );
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
            ? 'Saved on device. Sync is enabled when network allows (no upload confirmation in this build).'
            : 'Saved on device. Cloud sync needs Supabase credentials (assets/.env) and anonymous auth.',
      );
    } catch (e, st) {
      appLog.w('Local incident insert failed', error: e, stackTrace: st);
      return (
        ok: false,
        detail: 'Could not save incident log on device.',
      );
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
      return 'Saved on phone — sync enabled when network allows (no confirmation of upload).';
    }
    return 'Saved on phone — enable Supabase anonymous auth for cloud backup.';
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
