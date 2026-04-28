import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'database/app_database.dart';
import 'logging/app_log.dart';
import 'services/sms_permission_bootstrap.dart';
import 'services/first_aid_repository.dart';
import 'services/hardware_trigger_service.dart';
import 'services/ios_lifecycle_service.dart';
import 'services/emergency_orchestrator.dart';
import 'services/mesh_network_service.dart';
import 'services/app_locale_controller.dart';
import 'services/voice_assistant_service.dart';
import 'ui/dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (e, st) {
    appLog.w('Could not load assets/.env — check flutter assets', e, st);
  }
  await initializeDatabase();
  await bootstrapSupabaseAnonymousAuthOnLaunch();
  await requestSmsPermissionEarlyIfAndroid();
  await initializeFirstAidRepository();
  runApp(const ProviderScope(child: RoadSOSApp()));
}

/// Global SOS state — toggled by hardware trigger or UI button.
final isSOSActiveProvider = StateProvider<bool>((ref) => false);

class RoadSOSApp extends ConsumerWidget {
  const RoadSOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(hardwareTriggerServiceProvider);
    ref.watch(iosLifecycleServiceProvider);
    ref.watch(meshListeningBootstrapProvider);
    final isSOSActive = ref.watch(isSOSActiveProvider);
    final appLocale = ref.watch(appLocaleProvider);

    ref.listen(appLocaleProvider, (_, next) {
      ref.read(voiceAssistantServiceProvider).syncLocale(next);
    });

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (isSOSActive) {
          // Emergency Override Theme — high-contrast red/black for maximum readability
          lightScheme = const ColorScheme.light(
            primary: Colors.red,
            onPrimary: Colors.white,
            surface: Colors.black87,
            onSurface: Colors.white,
            error: Colors.redAccent,
          );
          darkScheme = const ColorScheme.dark(
            primary: Colors.red,
            onPrimary: Colors.white,
            surface: Colors.black,
            onSurface: Colors.white,
            error: Colors.redAccent,
          );
        } else {
          if (lightDynamic != null && darkDynamic != null) {
            lightScheme = lightDynamic.harmonized();
            darkScheme = darkDynamic.harmonized();
          } else {
            lightScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8));
            darkScheme = ColorScheme.fromSeed(
              seedColor: const Color(0xFF1A73E8),
              brightness: Brightness.dark,
            );
          }
        }

        return MaterialApp(
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
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
            fontFamily: 'Roboto',
          ),
          themeMode: ThemeMode.dark,
          home: const _InitialTtsSync(child: DashboardScreen()),
        );
      },
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
