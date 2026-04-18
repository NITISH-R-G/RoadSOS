import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'core/database/app_database.dart';
import 'features/emergency/services/hardware_trigger_service.dart';

import 'features/emergency/ui/dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Failed to load .env, falling back to empty variables or .env.example');
    try {
      await dotenv.load(fileName: ".env.example");
    } catch (_) {}
  }
  await initializeDatabase();
  runApp(const ProviderScope(child: RoadSOSApp()));
}

/// Global SOS state — toggled by hardware trigger or UI button.
final isSOSActiveProvider = StateProvider<bool>((ref) => false);

class RoadSOSApp extends ConsumerWidget {
  const RoadSOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wire hardware trigger service so it listens even when dashboard isn't visible
    ref.watch(hardwareTriggerServiceProvider);
    final isSOSActive = ref.watch(isSOSActiveProvider);

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
          title: 'RoadSOS',
          debugShowCheckedModeBanner: false,
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
          home: const DashboardScreen(),
        );
      },
    );
  }
}
