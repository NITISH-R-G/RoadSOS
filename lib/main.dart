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

  // 1. Config first — all other services read from dotenv.
  await RuntimeConfig.bootstrap();

  // 2. Auth + database — required before any Supabase or PowerSync call.
  await bootstrapSupabaseAuth();
  await initializeDatabase();

  // 3. Platform bootstrap — SMS permission, first-aid corpus, map tile cache.
  await requestSmsPermissionEarlyIfAndroid();
  await initializeFirstAidRepository();
  await initializeFmtcMapCache();

  // 4. Foreground service + notification channel.
  await EmergencyBackgroundService.initialize();
  await EmergencyBackgroundService.ensureNotificationChannel();

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
        // Start crash monitoring foreground service after consent is confirmed.
        EmergencyBackgroundService.startCrashMonitor();
        // Request battery optimization exemption so the foreground service
        // is not throttled by Doze mode during long drives at night.
        // This is a non-blocking best-effort request shown as a system dialog.
        EmergencyBackgroundService.requestBatteryOptimizationExemption();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(hardwareTriggerServiceProvider);
    ref.watch(iosLifecycleServiceProvider);
    ref.watch(meshListeningBootstrapProvider);
    // Keep connectivity provider alive for the full app session.
    ref.watch(connectivityServiceProvider);
    // Seed driving mode provider — non-autoDispose, must be alive from startup
    // so GPS speed history accumulates before any crash event could occur.
    ref.watch(drivingModeProvider);

    final sosPhase =
        ref.watch(emergencyOrchestratorProvider.select((s) => s.phase));
    final appLocale = ref.watch(appLocaleProvider);

    ref.listen(appLocaleProvider, (_, next) {
      ref.read(voiceAssistantServiceProvider).syncLocale(next);
    });

    // Mirror driving mode changes into the background service notification.
    ref.listen(drivingModeProvider, (_, mode) {
      EmergencyBackgroundService.notifyDrivingMode(
        active: mode == DrivingMode.driving,
      );
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
