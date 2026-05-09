import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceAssistantService {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  bool _isListening = false;

  VoiceAssistantService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
  }

  Future<void> speak(String text) async {
    print('[VoiceAssistant] Speaking: $text');
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

<<<<<<< Updated upstream
=======
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
  /// Spoken immediately after the pipeline completes so the driver/victim
  /// knows what was dispatched without needing to look at the screen.
  Future<void> speakTriageSummary({
    required int severity,
    required List<String> services,
    required String locationCoords,
  }) async {
    final msg = _localizedTriageSummary(severity, services, locationCoords);
    await _tts.setSpeechRate(0.46);
    await speak(msg);
    await _tts.setSpeechRate(0.48);
  }

  /// Announces that the Gemma 4 agent is taking over the device (Driving Mode).
  Future<void> speakAgenticTakeover(String defaultMsg) async {
    final msg = _localizedAgenticMsg(defaultMsg);
    await _tts.setSpeechRate(0.50);
    await speak(msg);
    await _tts.setSpeechRate(0.48);
  }

  String _localizedAgenticMsg(String english) {
    switch (_locale.languageCode) {
      case 'hi':
        return 'दुर्घटना का पता चला। जेम्मा 4 सहायता सुरक्षित करने के लिए इस डिवाइस का नियंत्रण ले रहा है।';
      case 'ta':
        return 'விபத்து கண்டறியப்பட்டது. உதவியைப் பெற இந்த சாதனத்தை கெம்மா 4 தனது கட்டுப்பாட்டில் எடுக்கிறது.';
      case 'te':
        return 'ప్రమాదం గుర్తించబడింది. సహాయం కోసం గెమ్మా 4 ఈ పరికరాన్ని తన ఆధీనంలోకి తీసుకుంటోంది.';
      default:
        return english;
    }
  }

  String _localizedCountdownMessage(int seconds, String locationHint) {
    switch (_locale.languageCode) {
      case 'hi':
        return 'आपातकाल SOS $seconds सेकंड में। $locationHint। रोकने के लिए "रुको" बोलें।';
      case 'ta':
        return 'அவசர SOS $seconds வினாடிகளில். நிறுத்த "நிறுத்து" என்று சொல்லுங்கள்.';
      case 'te':
        return 'అత్యవసర SOS $seconds సెకన్లలో. ఆపడానికి "ఆపు" అని చెప్పండి.';
      default:
        return 'Emergency SOS in $seconds seconds. $locationHint. '
            'Say "cancel" to stop.';
    }
  }

  String _localizedTriageSummary(
    int severity,
    List<String> services,
    String location,
  ) {
    final svcText = services.map(_serviceLabel).join(' and ');
    switch (_locale.languageCode) {
      case 'hi':
        return 'SOS भेजा गया। $svcText बुलाया गया। गंभीरता स्तर $severity। '
            'स्थान: $location। शांत रहें।';
      default:
        return 'SOS dispatched. $svcText requested. Severity level $severity. '
            'Location: $location. Stay calm and do not move if injured.';
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
>>>>>>> Stashed changes
  Future<bool> listenForConfirmation() async {
    if (_isListening) return false;
    
    bool available = await _stt.initialize();
    if (available) {
      _isListening = true;
      bool confirmed = false;
      
      print('[VoiceAssistant] Listening for confirmation...');
      await _stt.listen(
        onResult: (result) {
          final words = result.recognizedWords.toLowerCase();
          if (words.contains('confirm') || words.contains('yes') || words.contains('help')) {
            confirmed = true;
          }
        },
        listenFor: const Duration(seconds: 5),
      );
      
      await Future.delayed(const Duration(seconds: 5));
      _isListening = false;
      return confirmed;
    }
    return false;
  }
}
