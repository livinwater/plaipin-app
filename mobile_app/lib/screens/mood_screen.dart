import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Mood Screen
/// Mood tracker mini-app (Phase 2 - UI Shell with sample data)
class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int? _selectedMood;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Today's mood section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How are you feeling today?',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMoodButton('😢', 1, 'Sad'),
                            _buildMoodButton('😕', 2, 'Down'),
                            _buildMoodButton('😐', 3, 'Okay'),
                            _buildMoodButton('😊', 4, 'Good'),
                            _buildMoodButton('😄', 5, 'Great'),
                          ],
                        ),
                        if (_selectedMood != null) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Mood logging coming in Phase 4!'),
                                  ),
                                );
                              },
                              child: const Text('Log Mood'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Stats section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '7 Days',
                        '68%',
                        'Avg Mood',
                        AppTheme.primaryPink,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '15',
                        'Entries',
                        'This Month',
                        AppTheme.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Mood history (sample data)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Recent Mood History',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Sample mood entries
              _buildMoodHistoryItem('Today', '😊', 'Good', 'Feeling productive!', AppTheme.moodHappy),
              _buildMoodHistoryItem('Yesterday', '😄', 'Great', 'Amazing day with friends', AppTheme.moodExcited),
              _buildMoodHistoryItem('2 days ago', '😐', 'Okay', 'Busy work day', AppTheme.moodNeutral),
              _buildMoodHistoryItem('3 days ago', '😊', 'Good', 'Relaxing weekend', AppTheme.moodHappy),
              _buildMoodHistoryItem('4 days ago', '😕', 'Down', 'Feeling tired', AppTheme.moodSad),
              
              const SizedBox(height: 24),
              
              // Info banner
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.pastelYellow,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.darkGray),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '🚧 Full mood tracking with charts coming in Phase 4',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMoodButton(String emoji, int value, String label) {
    final isSelected = _selectedMood == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = value;
        });
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryPink : AppTheme.lightGray,
              shape: BoxShape.circle,
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppTheme.primaryPink.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? AppTheme.primaryPink : AppTheme.darkGray,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label1, String value, String label2, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label1,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label2,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMoodHistoryItem(String date, String emoji, String mood, String note, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      child: Card(
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          title: Row(
            children: [
              Text(
                mood,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Text(
                '• $date',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.darkGray,
                ),
              ),
            ],
          ),
          subtitle: Text(note),
        ),
      ),
    );
  }
}

