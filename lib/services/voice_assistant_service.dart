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

  // ── Phase 7: Hands-free SOS countdown (driving mode) ─────────────────────

  /// Speaks the SOS countdown message once at the start of the countdown.
  ///
  /// Called when driving mode is active at SOS trigger — the user cannot
  /// look at the screen, so the device announces what is happening and how
  /// to cancel. The message is spoken in the app's current locale.
  Future<void> speakHandsFreeCountdown(int totalSeconds, String locationHint) async {
    final msg = _localizedCountdownMessage(totalSeconds, locationHint);
    await _tts.setSpeechRate(0.52);
    await speak(msg);
    await _tts.setSpeechRate(0.48);
  }

  /// Announces the completed triage after dispatch — post-SOS voice briefing.
  ///
  /// [smsSucceeded] controls whether the announcement says "dispatched" or
  /// warns the user to dial manually. An injured driver relying on audio must
  /// never be falsely reassured that help is on the way when SMS failed.
  Future<void> speakTriageSummary({
    required int severity,
    required List<String> services,
    required String locationCoords,
    bool smsSucceeded = false,
  }) async {
    final msg = _localizedTriageSummary(severity, services, locationCoords, smsSucceeded);
    await _tts.setSpeechRate(0.46);
    await speak(msg);
    await _tts.setSpeechRate(0.48);
  }

  String _localizedCountdownMessage(int seconds, String locationHint) {
    switch (_locale.languageCode) {
      case 'hi':
        return 'आपातकाल SOS $seconds सेकंड में। $locationHint। रोकने के लिए "रुको" बोलें।';
      case 'ta':
        return 'அவசர SOS $seconds வினாடிகளில். நிறுத்த "நிறுத்து" என்று சொல்லுங்கள்.';
      case 'te':
        return 'అత్యవసర SOS $seconds సెకన్లలో. ఆపడానికి "ఆపు" అని చెప్పండి.';
      case 'bn':
        return 'জরুরি SOS $seconds সেকেন্ডে। বাতিল করতে "থামো" বলুন।';
      case 'mr':
        return 'आणीबाणी SOS $seconds सेकंदात। थांबवण्यासाठी "थांब" म्हणा।';
      default:
        return 'Emergency SOS in $seconds seconds. $locationHint. '
            'Say "cancel" to stop.';
    }
  }

  String _localizedTriageSummary(
    int severity,
    List<String> services,
    String location,
    bool smsSucceeded,
  ) {
    final svcText = services.map(_serviceLabel).join(' and ');
    switch (_locale.languageCode) {
      case 'hi':
        if (smsSucceeded) {
          return 'SOS भेजा गया। $svcText बुलाया गया। गंभीरता स्तर $severity। '
              'स्थान: $location। शांत रहें।';
        }
        return 'SOS संदेश भेजने में विफल। कृपया 112 डायल करें। '
            'गंभीरता स्तर $severity। स्थान: $location।';
      case 'bn':
        if (smsSucceeded) {
          return 'SOS পাঠানো হয়েছে। $svcText অনুরোধ করা হয়েছে। তীব্রতা $severity। '
              'অবস্থান: $location। শান্ত থাকুন।';
        }
        return 'SOS বার্তা পাঠানো যায়নি। অনুগ্রহ করে 112 ডায়াল করুন।';
      case 'mr':
        if (smsSucceeded) {
          return 'SOS पाठवला। $svcText मागवला। तीव्रता $severity। '
              'स्थान: $location। शांत रहा।';
        }
        return 'SOS संदेश पाठवता आला नाही। कृपया 112 डायल करा।';
      case 'ta':
        if (smsSucceeded) {
          return 'SOS அனுப்பப்பட்டது. $svcText கோரப்பட்டது. தீவிரம் $severity. '
              'இடம்: $location. அமைதியாக இருங்கள்.';
        }
        return 'SOS செய்தி அனுப்ப முடியவில்லை. 112 அழைக்கவும்.';
      case 'te':
        if (smsSucceeded) {
          return 'SOS పంపబడింది. $svcText అభ్యర్థించబడింది. తీవ్రత $severity. '
              'స్థానం: $location. ప్రశాంతంగా ఉండండి.';
        }
        return 'SOS సందేశం పంపడం విఫలమైంది. దయచేసి 112 డయల్ చేయండి.';
      default:
        if (smsSucceeded) {
          return 'SOS dispatched. $svcText requested. Severity level $severity. '
              'Location: $location. Stay calm and do not move if injured.';
        }
        return 'SOS message could not be sent automatically. '
            'Please dial 112 now. Severity level $severity. Location: $location.';
    }
  }

  String _serviceLabel(String service) {
    switch (service) {
      case 'ambulance':       return 'ambulance';
      case 'police':          return 'police';
      case 'fire_department': return 'fire department';
      case 'rescue':          return 'rescue team';
      case 'towing':          return 'towing service';
      default:                return service;
    }
  }

  // ── Phase 7: Voice cancel during countdown ────────────────────────────────

  /// Listens for a cancellation utterance during the SOS countdown.
  ///
  /// Returns true if the user said a cancel word. Used by the orchestrator to
  /// abort the SOS when hands-free mode is active (driving).
  ///
  /// Cancel words: "cancel", "stop", "no", "abort", plus locale-specific tokens.
  Future<bool> listenForCancel({
    Duration listenFor = const Duration(seconds: 8),
  }) async {
    if (_isListening) return false;
    final available = await _stt.initialize();
    if (!available) return false;

    _isListening = true;
    var cancelled = false;

    await _stt.listen(
      onResult: (result) {
        final words = result.recognizedWords.toLowerCase();
        if (_matchesCancel(words)) cancelled = true;
      },
      listenFor: listenFor,
    );

    await Future<void>.delayed(listenFor + const Duration(milliseconds: 200));
    _isListening = false;
    return cancelled;
  }

  bool _matchesCancel(String words) {
    if (words.contains('cancel') ||
        words.contains('stop') ||
        words.contains('abort') ||
        words.contains('no')) {
      return true;
    }
    switch (_locale.languageCode) {
      case 'hi':
        return words.contains('ruko') ||
            words.contains('band') ||
            words.contains('nahi') ||
            words.contains('रुको') ||
            words.contains('नहीं');
      case 'ta':
        return words.contains('நிறுத்து') || words.contains('niruthu');
      case 'te':
        return words.contains('ఆపు') || words.contains('apu');
      case 'bn':
        return words.contains('থামো') || words.contains('thamo');
      case 'mr':
        return words.contains('थांब') || words.contains('thamb');
      default:
        return false;
    }
  }

  // ── Existing confirmation listener (unchanged) ────────────────────────────

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
