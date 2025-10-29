import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../theme/app_theme.dart';

/// Home Screen
/// Main screen with companion animation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _companionMood = 75;
  int _interactionCount = 42;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient background like Zepeto
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.pastelBlue.withOpacity(0.3),
              AppTheme.pastelPurple.withOpacity(0.2),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // 3D Rabbit Model - clean and centered
                Container(
                  height: 400,
                  width: 400,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryPink.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      ModelViewer(
                        src: 'assets/models/rabbit.glb',
                        alt: 'Buddy the Companion',
                        autoRotate: true,
                        autoRotateDelay: 0,
                        cameraControls: true,
                        touchAction: TouchAction.panY,
                        interactionPrompt: InteractionPrompt.none,
                        loading: Loading.eager,
                        ar: false,
                      ),
                      // Debug indicator
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '3D Model Loading...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Companion Name
                Text(
                  'Buddy',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Mood badge - subtle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.getMoodGradient(_companionMood),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getMoodText(_companionMood),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                const Spacer(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _getMoodText(int mood) {
    if (mood >= 80) return 'Very Happy';
    if (mood >= 60) return 'Happy';
    if (mood >= 40) return 'Neutral';
    if (mood >= 20) return 'Sad';
    return 'Very Sad';
  }
}

