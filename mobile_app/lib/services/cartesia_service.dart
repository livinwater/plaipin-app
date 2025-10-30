import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Cartesia TTS Service
/// Handles text-to-speech using Cartesia Sonic-3 API
class CartesiaService {
  static const String _baseUrl = 'https://api.cartesia.ai';
  static const String _apiVersion = '2025-04-16';
  
  final String _apiKey;
  final String _voiceId;
  
  CartesiaService({
    String? apiKey,
    String? voiceId,
  })  : _apiKey = apiKey ?? dotenv.env['CARTESIA'] ?? '',
        _voiceId = voiceId ?? dotenv.env['AVERY_VOICE'] ?? '';

  /// Generate speech from text using Cartesia Sonic-3
  /// Returns audio data as bytes (WAV format)
  Future<Uint8List> generateSpeech({
    required String text,
    String emotion = 'happy',
    double speed = 1.1,
    double volume = 1.0,
    String language = 'en',
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('Cartesia API key not found in .env file');
    }
    
    if (_voiceId.isEmpty) {
      throw Exception('Voice ID not found in .env file');
    }

    final url = Uri.parse('$_baseUrl/tts/bytes');
    
    // Add expressiveness to text (replace common patterns with laughter)
    final expressiveText = _makeTextExpressive(text);
    
    final requestBody = {
      'model_id': 'sonic-3',
      'transcript': expressiveText,
      'voice': {
        'mode': 'id',
        'id': _voiceId,
      },
      'output_format': {
        'container': 'wav',
        'encoding': 'pcm_s16le',
        'sample_rate': 44100,
      },
      'generation_config': {
        'emotion': emotion,
        'speed': speed,
        'volume': volume,
      },
      'language': language,
    };

    final response = await http.post(
      url,
      headers: {
        'Cartesia-Version': _apiVersion,
        'X-API-Key': _apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception(
        'Failed to generate speech: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Make text more expressive by adding nonverbalisms
  String _makeTextExpressive(String text) {
    return text
        .replaceAll('haha', '[laughter]')
        .replaceAll('hehe', '[laughter]')
        .replaceAll('ha ha', '[laughter]')
        .replaceAll('he he', '[laughter]');
  }

  /// Detect emotion from mood string
  String detectEmotionFromMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return 'happy';
      case 'excited':
        return 'excited';
      case 'tired':
        return 'content';
      case 'curious':
        return 'curious';
      case 'proud':
        return 'triumphant';
      case 'peaceful':
        return 'peaceful';
      default:
        return 'happy';
    }
  }

  /// Test connection to Cartesia API
  Future<bool> testConnection() async {
    try {
      await generateSpeech(
        text: 'Hello! This is PlaiPin testing my voice!',
        emotion: 'happy',
      );
      return true;
    } catch (e) {
      print('Cartesia connection test failed: $e');
      return false;
    }
  }
}
