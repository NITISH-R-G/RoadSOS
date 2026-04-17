import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'database/app_database.dart';
import 'ui/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabase();
  runApp(const ProviderScope(child: RoadSOSApp()));
}

final isSOSActiveProvider = StateProvider<bool>((ref) => false);

import 'services/hardware_trigger_service.dart';

class RoadSOSApp extends ConsumerWidget {
  const RoadSOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(hardwareTriggerServiceProvider);
    final isSOSActive = ref.watch(isSOSActiveProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (isSOSActive) {
          // Emergency Override Theme (High-Contrast Red/Black)
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
            lightScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
            darkScheme = ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            );
          }
        }

        return MaterialApp(
          title: 'RoadSOS',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
          ),
          home: const DashboardScreen(),
        );
      },
    );
  }
}
