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
