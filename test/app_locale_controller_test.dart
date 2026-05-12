import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadsos/services/app_locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AppLocaleController defaults to en if no saved locale and platform locale not supported', () {
    final controller = AppLocaleController();
    expect(controller.state, const Locale('en'));
  });

  test('AppLocaleController loadSaved updates state if supported locale found', () async {
    SharedPreferences.setMockInitialValues({'app_locale_language_code': 'hi'});
    final controller = AppLocaleController();

    // initially it should be 'en' (or whatever platform is, which is 'en-US' in tests usually)
    expect(controller.state, const Locale('en'));

    // directly await loadSaved to ensure it executes in this test context before assertion
    await controller.loadSaved();

    expect(controller.state, const Locale('hi'));
  });

  test('AppLocaleController loadSaved ignores unsupported locale', () async {
    SharedPreferences.setMockInitialValues({'app_locale_language_code': 'es'});
    final controller = AppLocaleController();

    await controller.loadSaved();

    expect(controller.state, const Locale('en'));
  });

  test('AppLocaleController setLocale saves to SharedPreferences and updates state', () async {
    final controller = AppLocaleController();

    await controller.setLocale(const Locale('ta'));

    expect(controller.state, const Locale('ta'));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale_language_code'), 'ta');
  });

  test('AppLocaleController setLocale ignores unsupported locale', () async {
    final controller = AppLocaleController();

    await controller.setLocale(const Locale('es'));

    expect(controller.state, const Locale('en')); // remains 'en'

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale_language_code'), isNull);
  });
}
