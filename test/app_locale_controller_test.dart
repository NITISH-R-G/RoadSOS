import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadsos/services/app_locale_controller.dart';

void main() {
  group('AppLocaleController', () {
    setUp(() {
      WidgetsFlutterBinding.ensureInitialized();
    });

    test('loads saved supported locale successfully', () async {
      SharedPreferences.setMockInitialValues({'app_locale_language_code': 'hi'});
      final controller = AppLocaleController();

      // Wait for the microtask to finish or explicitly call it to test
      await controller.loadSaved();

      expect(controller.state, const Locale('hi'));
    });

    test('ignores unsupported locale from SharedPreferences', () async {
      // 'fr' is not in kSupportedAppLocales
      SharedPreferences.setMockInitialValues({'app_locale_language_code': 'fr'});
      final controller = AppLocaleController();

      // Store the initial state (derived from platform locale)
      final initialState = controller.state;

      await controller.loadSaved();

      // State should not have changed to 'fr'
      expect(controller.state, initialState);
      expect(controller.state.languageCode, isNot('fr'));
    });

    test('handles errors gracefully when invalid type is stored in SharedPreferences', () async {
      // Store a boolean instead of a string to force an error on getString
      SharedPreferences.setMockInitialValues({'app_locale_language_code': true});
      final controller = AppLocaleController();

      final initialState = controller.state;

      // This should not throw an exception now, since we added try-catch
      await controller.loadSaved();

      // State should remain unaffected
      expect(controller.state, initialState);
    });

    test('setLocale saves locale to SharedPreferences and updates state', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = AppLocaleController();

      await controller.setLocale(const Locale('bn'));

      // State should be updated
      expect(controller.state, const Locale('bn'));

      // SharedPreferences should be updated
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale_language_code'), 'bn');
    });

    test('setLocale ignores unsupported locales', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = AppLocaleController();

      final initialState = controller.state;

      await controller.setLocale(const Locale('fr'));

      // State should remain unaffected
      expect(controller.state, initialState);

      // SharedPreferences should not be updated
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale_language_code'), isNull);
    });
  });
}
