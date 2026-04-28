import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsos/l10n/app_localizations.dart';
import 'database/app_database.dart';
import 'logging/app_log.dart';
import 'services/sms_permission_bootstrap.dart';
import 'services/first_aid_repository.dart';
import 'services/hardware_trigger_service.dart';
import 'services/ios_lifecycle_service.dart';
import 'services/emergency_orchestrator.dart';
import 'services/map_tile_cache.dart';
import 'services/mesh_network_service.dart';
import 'services/app_locale_controller.dart';
import 'services/voice_assistant_service.dart';
import 'ui/dashboard.dart';
import 'ui/consent_screen.dart';
import 'ui/onboarding_gate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/privacy_consent_service.dart';
import 'services/nearby_sos_push_service.dart';
import 'app_navigator.dart';
import 'theme/roadsos_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (e, st) {
    appLog.w(
      'Could not load assets/.env — check flutter assets',
      error: e,
      stackTrace: st,
    );
  }
  await bootstrapSupabaseAuth();
  await initializeDatabase();
  await requestSmsPermissionEarlyIfAndroid();
  await initializeFirstAidRepository();
  await initializeFmtcMapCache();
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(hardwareTriggerServiceProvider);
    ref.watch(iosLifecycleServiceProvider);
    ref.watch(meshListeningBootstrapProvider);
    final sosPhase =
        ref.watch(emergencyOrchestratorProvider.select((s) => s.phase));
    final appLocale = ref.watch(appLocaleProvider);

    ref.listen(appLocaleProvider, (_, next) {
      ref.read(voiceAssistantServiceProvider).syncLocale(next);
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
        },
      );
    }
    return const OnboardingGate(
      child: _InitialTtsSync(child: DashboardScreen()),
    );
  }
}

/// One-shot TTS locale alignment on startup ([loadSaved] may update locale later;
/// [ref.listen] on [appLocaleProvider] handles further changes).
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
