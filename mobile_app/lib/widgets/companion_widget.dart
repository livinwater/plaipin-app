import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

/// Companion Widget
/// Displays the animated companion character
class CompanionWidget extends StatelessWidget {
  final int mood;
  final VoidCallback? onTap;

  const CompanionWidget({
    super.key,
    required this.mood,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with Lottie animation in Phase 2
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: _getMoodColor(),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            _getMoodIcon(),
            size: 80,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getMoodColor() {
    if (mood >= 70) return Colors.green;
    if (mood >= 40) return Colors.yellow;
    return Colors.red;
  }

  IconData _getMoodIcon() {
    if (mood >= 70) return Icons.sentiment_very_satisfied;
    if (mood >= 40) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }
}

