import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Maps app locale to flutter_tts language codes (Indian engines).
String ttsLanguageForLocale(Locale locale) {
  switch (locale.languageCode) {
    case 'hi':
      return 'hi-IN';
    case 'ta':
      return 'ta-IN';
    case 'te':
      return 'te-IN';
    case 'bn':
      return 'bn-IN';
    case 'mr':
      return 'mr-IN';
    default:
      return 'en-US';
  }
}

class VoiceAssistantService {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  bool _isListening = false;
  Locale _locale = const Locale('en');

  VoiceAssistantService() {
    _initTts();
  }

  Locale get locale => _locale;

  Future<void> _initTts() async {
    await syncLocale(_locale);
  }

  /// Call whenever [AppLocaleController] changes so TTS matches UI language.
  Future<void> syncLocale(Locale locale) async {
    _locale = Locale(locale.languageCode);
    await _tts.setLanguage(ttsLanguageForLocale(_locale));
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.48);
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  /// Simple confirmation — English + common Hindi tokens for India.
  Future<bool> listenForConfirmation() async {
    if (_isListening) return false;

    final available = await _stt.initialize();
    if (available) {
      _isListening = true;
      var confirmed = false;

      await _stt.listen(
        onResult: (result) {
          final words = result.recognizedWords.toLowerCase();
          if (_matchesConfirm(words)) {
            confirmed = true;
          }
        },
        listenFor: const Duration(seconds: 5),
      );

      await Future<void>.delayed(const Duration(seconds: 5));
      _isListening = false;
      return confirmed;
    }
    return false;
  }

  bool _matchesConfirm(String words) {
    if (words.contains('confirm') ||
        words.contains('yes') ||
        words.contains('help')) {
      return true;
    }
    switch (_locale.languageCode) {
      case 'hi':
        return words.contains('haan') ||
            words.contains('hān') ||
            words.contains('ji') ||
            words.contains('जी') ||
            words.contains('हाँ');
      case 'ta':
        return words.contains('ஆம்') || words.contains('amaam');
      case 'te':
        return words.contains('అవును') || words.contains('avunu');
      case 'bn':
        return words.contains('হ্যাঁ') || words.contains('haan');
      case 'mr':
        return words.contains('हो') || words.contains('ho') || words.contains('barob');
      default:
        return false;
    }
  }
}
