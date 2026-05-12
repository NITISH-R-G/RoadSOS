import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadsos/services/app_locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // Clear SharedPreferences mock before each test
    SharedPreferences.setMockInitialValues({});
  });

  group('AppLocaleController Tests', () {
    test('initial state resolves to default locale (en) when no saved preference exists', () {
      WidgetsFlutterBinding.ensureInitialized();

      final controller = AppLocaleController();
      expect(controller.state, equals(const Locale('en')));
    });

    test('loadSaved loads a valid supported locale from SharedPreferences', () async {
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({'app_locale_language_code': 'hi'});

      final controller = AppLocaleController();

      // Wait for microtask (loadSaved) to complete
      await Future.delayed(Duration.zero);

      expect(controller.state, equals(const Locale('hi')));
    });

    test('loadSaved ignores unsupported locale and stays on default', () async {
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({'app_locale_language_code': 'fr'}); // 'fr' is not supported

      final controller = AppLocaleController();

      // Wait for microtask (loadSaved) to complete
      await Future.delayed(Duration.zero);

      expect(controller.state, equals(const Locale('en')));
    });

    test('loadSaved handles missing preference gracefully', () async {
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});

      final controller = AppLocaleController();

      // Wait for microtask (loadSaved) to complete
      await Future.delayed(Duration.zero);

      expect(controller.state, equals(const Locale('en')));
    });

    test('setLocale successfully updates state and SharedPreferences for supported locale', () async {
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});

      final controller = AppLocaleController();

      await controller.setLocale(const Locale('ta'));

      expect(controller.state, equals(const Locale('ta')));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale_language_code'), equals('ta'));
    });

    test('setLocale ignores unsupported locale', () async {
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});

      final controller = AppLocaleController();

      await controller.setLocale(const Locale('xyz'));

      expect(controller.state, equals(const Locale('en')));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale_language_code'), isNull);
    });
  });
}
