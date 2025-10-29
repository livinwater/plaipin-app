import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/companion_widget.dart';

/// Home Screen
/// Main screen with companion animation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _companionMood = 75;
  int _interactionCount = 42;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
                
                // Just the companion character - clean and centered
                CompanionWidget(
                  mood: _companionMood,
                  onTap: _onCompanionTap,
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
  
  void _onCompanionTap() {
    setState(() {
      _companionMood = (_companionMood + 5).clamp(0, 100);
      _interactionCount++;
    });
  }
}

