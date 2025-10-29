import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
// import 'package:lottie/lottie.dart';

/// Companion Widget
/// Displays the animated companion character
/// Phase 2: Using animated gradient circles, will add Lottie in polish phase
class CompanionWidget extends StatefulWidget {
  final int mood;
  final VoidCallback? onTap;

  const CompanionWidget({
    super.key,
    required this.mood,
    this.onTap,
  });

  @override
  State<CompanionWidget> createState() => _CompanionWidgetState();
}

class _CompanionWidgetState extends State<CompanionWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with Lottie animation later
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.getMoodGradient(widget.mood),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getMoodColor(widget.mood).withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow effect
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                
                // Inner companion face
                Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Eyes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildEye(),
                          const SizedBox(width: 20),
                          _buildEye(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Mouth based on mood
                      Icon(
                        _getMoodIcon(),
                        size: 40,
                        color: AppTheme.getMoodColor(widget.mood),
                      ),
                    ],
                  ),
                ),
                
                // Tap indicator
                if (_isPressed)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEye() {
    return Container(
      width: 12,
      height: 18,
      decoration: BoxDecoration(
        color: AppTheme.black,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  IconData _getMoodIcon() {
    if (widget.mood >= 80) return Icons.sentiment_very_satisfied;
    if (widget.mood >= 60) return Icons.sentiment_satisfied;
    if (widget.mood >= 40) return Icons.sentiment_neutral;
    if (widget.mood >= 20) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_very_dissatisfied;
  }
}

