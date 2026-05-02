import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsos/l10n/app_localizations.dart';
import 'database/app_database.dart';
import 'services/sms_permission_bootstrap.dart';
import 'services/first_aid_repository.dart';
import 'services/hardware_trigger_service.dart';
import 'services/ios_lifecycle_service.dart';
import 'services/emergency_orchestrator.dart';
import 'services/map_tile_cache.dart';
import 'services/mesh_network_service.dart';
import 'services/app_locale_controller.dart';
import 'services/connectivity_service.dart';
import 'services/driving_mode_service.dart';
import 'services/emergency_background_service.dart';
import 'services/agent_health_service.dart';
import 'services/bluetooth_vehicle_monitor.dart';
import 'services/inactivity_crash_detector.dart';
import 'services/predictive_sos_preloader.dart';
import 'services/sos_location_tracker.dart';
import 'ui/dashboard.dart';
import 'ui/consent_screen.dart';
import 'ui/onboarding_gate.dart';
import 'services/privacy_consent_service.dart';
import 'services/nearby_sos_push_service.dart';
import 'app_navigator.dart';
import 'theme/roadsos_theme.dart';
import 'config/runtime_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Phase 1: Config — all other services read from dotenv.
  await RuntimeConfig.bootstrap();

  // Phase 2: Auth + database — required before any Supabase or PowerSync call.
  await bootstrapSupabaseAuth();
  await initializeDatabase();

  // Phase 3: Parallel bootstrap — these are independent of each other.
  // Running them concurrently saves ~400–700ms of cold-start time vs. serial.
  //
  //   requestSmsPermissionEarlyIfAndroid — triggers system dialog (instant)
  //   initializeFirstAidRepository      — loads corpus JSON, seeds FTS5 table
  //   initializeFmtcMapCache             — initialises the tile cache directory
  //   BackgroundService.init + channel   — registers notification channels
  //
  // Note: initializeFirstAidRepository depends on initializeDatabase() above,
  // which is already complete at this point, so FTS writes are safe here.
  await Future.wait<void>([
    requestSmsPermissionEarlyIfAndroid(),
    initializeFirstAidRepository(),
    initializeFmtcMapCache(),
    EmergencyBackgroundService.initialize()
        .then((_) => EmergencyBackgroundService.ensureNotificationChannel()),
  ]);

  runApp(const ProviderScope(child: RoadSOSApp()));
}

class RoadSOSApp extends ConsumerStatefulWidget {
  const RoadSOSApp({super.key});

  @override
  ConsumerState<RoadSOSApp> createState() => _RoadSOSAppState();
}

class _RoadSOSAppState extends ConsumerState<RoadSOSApp> {
  bool _privacyReady = false;
  bool _privacyConsent = false;

  @override
  void initState() {
    super.initState();
    PrivacyConsentService.hasConsent().then((accepted) {
      if (!mounted) return;
      setState(() {
        _privacyConsent = accepted;
        _privacyReady = true;
      });
      if (accepted) {
        NearbySosPushService.instance.configureAfterConsentIfNeeded();
        EmergencyBackgroundService.startCrashMonitor();
        EmergencyBackgroundService.requestBatteryOptimizationExemption();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(hardwareTriggerServiceProvider);
    ref.watch(iosLifecycleServiceProvider);
    ref.watch(meshListeningBootstrapProvider);
    ref.watch(connectivityServiceProvider);
    ref.watch(drivingModeProvider);

    // Phase 4: Start agent health polling — shows readiness before SOS fires.
    ref.watch(agentHealthServiceProvider).startPolling();

    // Phase 6: BT vehicle disconnect monitor — seeds provider so it starts
    // polling Bluetooth connected devices immediately at app launch.
    ref.watch(bluetoothVehicleMonitorProvider);

    // Phase 1: Incapacitation / unconscious-driver detector — must be alive
    // from the moment driving mode could activate (non-autoDispose).
    ref.watch(inactivityCrashDetectorProvider);

    // Phase 4: SOS live location tracker — attaches listener to orchestrator;
    // begins streaming GPS updates to family contacts when SOS goes active.
    ref.watch(sosLocationTrackerProvider);

    final sosPhase =
        ref.watch(emergencyOrchestratorProvider.select((s) => s.phase));
    final appLocale = ref.watch(appLocaleProvider);

    ref.listen(appLocaleProvider, (_, next) {
      ref.read(voiceAssistantServiceProvider).syncLocale(next);
    });

    ref.listen(drivingModeProvider, (prev, mode) {
      EmergencyBackgroundService.notifyDrivingMode(
        active: mode == DrivingMode.driving,
      );
      // Phase 2: pre-warm Supabase TLS + GPS chipset when driving starts.
      if (mode == DrivingMode.driving && prev != DrivingMode.driving) {
        unawaited(PredictiveSosPreloader.onDrivingModeActivated());
      }
    });

    final theme = sosPhase == SOSPhase.idle
        ? RoadSosTheme.buildOperationalDark()
        : RoadSosTheme.buildEmergencyDark();

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      locale: appLocale,
      supportedLocales: kSupportedAppLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      home: _privacyHome(),
    );
  }

  Widget _privacyHome() {
    if (!_privacyReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_privacyConsent) {
      return ConsentScreen(
        onAccepted: () {
          setState(() => _privacyConsent = true);
          NearbySosPushService.instance.configureAfterConsentIfNeeded();
          EmergencyBackgroundService.startCrashMonitor();
          EmergencyBackgroundService.requestBatteryOptimizationExemption();
        },
      );
    }
    return const OnboardingGate(
      child: _InitialTtsSync(child: DashboardScreen()),
    );
  }
}

/// One-shot TTS locale alignment on startup.
class _InitialTtsSync extends ConsumerStatefulWidget {
  const _InitialTtsSync({required this.child});

  final Widget child;

  @override
  ConsumerState<_InitialTtsSync> createState() => _InitialTtsSyncState();
}

class _InitialTtsSyncState extends ConsumerState<_InitialTtsSync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locale = ref.read(appLocaleProvider);
      ref.read(voiceAssistantServiceProvider).syncLocale(locale);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
