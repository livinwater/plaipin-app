import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Voice Service
/// Handles speech-to-text and text-to-speech
class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _speechEnabled = false;

  Future<void> initialize() async {
    _speechEnabled = await _speechToText.initialize();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
  }

  bool get isEnabled => _speechEnabled;

  // TODO: Implement speech recognition
  Future<String> startListening() async {
    throw UnimplementedError('To be implemented in Phase 3');
  }

  void stopListening() {
    _speechToText.stop();
  }

  // TODO: Implement text-to-speech
  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  // TODO: Implement sentiment analysis
  int analyzeSentiment(String text) {
    throw UnimplementedError('To be implemented in Phase 3');
  }
}

