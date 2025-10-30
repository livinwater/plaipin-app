import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import '../services/cartesia_service.dart';

/// Utility to test Cartesia voice integration
/// Run this from the home screen or anywhere to verify setup
class CartesiaTest {
  static Future<void> testCartesiaConnection(BuildContext context) async {
    final cartesiaService = CartesiaService();
    final audioPlayer = AudioPlayer();
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Testing Cartesia connection...'),
          ],
        ),
      ),
    );
    
    try {
      // Test with a simple message
      final audioBytes = await cartesiaService.generateSpeech(
        text: 'Hi! I\'m PlaiPin and my voice works! This is so exciting!',
        emotion: 'excited',
        speed: 1.1,
      );
      
      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final audioFile = File('${tempDir.path}/plaipin_test.wav');
      await audioFile.writeAsBytes(audioBytes);
      
      // Load and play audio
      await audioPlayer.setAudioSource(AudioSource.file(audioFile.path));
      audioPlayer.play();
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show success with play option
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Success!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cartesia voice is working!'),
                const SizedBox(height: 8),
                Text(
                  'Generated ${(audioBytes.length / 1024).toStringAsFixed(2)} KB of audio',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  '🎵 Playing test audio now!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  audioPlayer.stop();
                  audioPlayer.dispose();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Dispose audio player
      audioPlayer.dispose();
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Error'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Failed to connect to Cartesia:'),
                const SizedBox(height: 8),
                Text(
                  '$e',
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please check:\n'
                  '• CARTESIA key is set in .env\n'
                  '• AVERY_VOICE key is set in .env\n'
                  '• Keys are valid',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
