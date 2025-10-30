/// Journal Entry Model
/// 
/// Represents a daily diary entry from PlaiPin's perspective
class JournalEntry {
  final String id;
  final DateTime date;
  final String entryText; // PlaiPin's diary in first person
  final String mood; // happy, excited, tired, curious, etc.
  final List<String> activities; // What PlaiPin did today
  final List<String> highlights; // Special moments
  final String? audioUrl; // Cached TTS audio URL (optional)
  final int durationSeconds; // Audio duration
  
  JournalEntry({
    required this.id,
    required this.date,
    required this.entryText,
    required this.mood,
    required this.activities,
    required this.highlights,
    this.audioUrl,
    this.durationSeconds = 0,
  });
  
  // Get mood emoji
  String get moodEmoji {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'excited':
        return '🤩';
      case 'tired':
        return '😴';
      case 'curious':
        return '🤔';
      case 'proud':
        return '🌟';
      case 'peaceful':
        return '😌';
      default:
        return '💭';
    }
  }
  
  // Get mood color (as hex string)
  String get moodColor {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '#FFD93D';
      case 'excited':
        return '#FF6B9D';
      case 'tired':
        return '#9D6BFF';
      case 'curious':
        return '#6BB6FF';
      case 'proud':
        return '#FFB3D9';
      case 'peaceful':
        return '#B3FFD9';
      default:
        return '#BDBDBD';
    }
  }
  
  // Check if entry has audio
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;
  
  // Format duration for display
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
