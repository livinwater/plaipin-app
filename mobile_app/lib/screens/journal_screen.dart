import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../theme/app_theme.dart';
import 'journal_entry_detail.dart';

/// Journal Screen
/// PlaiPin's diary with calendar view
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Mock journal entries for demo
  late Map<DateTime, List<JournalEntry>> _entries;
  
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMockEntries();
  }
  
  void _loadMockEntries() {
    final now = DateTime.now();
    _entries = {
      DateTime(now.year, now.month, now.day): [
        JournalEntry(
          id: '1',
          date: DateTime(now.year, now.month, now.day),
          mood: 'happy',
          entryText: 'Today was amazing! I spent 15 minutes in the Japanese study room with my friend. We practiced hiragana together - I\'m getting so good at this! Then I visited the marketplace and got a cute yellow ribbon! I wore it all day and felt super stylish. Can\'t wait for tomorrow\'s adventure! 🌟',
          activities: [
            'Practiced Japanese for 15 minutes',
            'Visited the store and bought a yellow ribbon',
            'Equipped my new accessory',
          ],
          highlights: [
            'Mastered 10 new hiragana characters!',
            'Got my first accessory - the yellow ribbon!',
          ],
          audioUrl: 'mock://audio/today.mp3',
          durationSeconds: 45,
        ),
      ],
      DateTime(now.year, now.month, now.day - 1): [
        JournalEntry(
          id: '2',
          date: DateTime(now.year, now.month, now.day - 1),
          mood: 'excited',
          entryText: 'What an exciting day! I joined my first language challenge today. It\'s a 30-day Spanish challenge and I\'m so pumped! I practiced for 20 minutes and learned lots of new words. The community chat is so friendly - everyone is helping each other. This is going to be fun! 💪',
          activities: [
            'Joined Spanish learning challenge',
            'Practiced for 20 minutes',
            'Chatted with language learners',
          ],
          highlights: [
            'Joined my first challenge!',
            'Made 3 new friends in the Spanish group',
          ],
          audioUrl: 'mock://audio/yesterday.mp3',
          durationSeconds: 52,
        ),
      ],
      DateTime(now.year, now.month, now.day - 2): [
        JournalEntry(
          id: '3',
          date: DateTime(now.year, now.month, now.day - 2),
          mood: 'curious',
          entryText: 'Today I explored the marketplace! So many cool items to collect. I saw the mood tracker and it looks super helpful. I also checked out different language challenges - there are so many languages to learn! I\'m thinking about trying French next. The explore page is my new favorite place! 🔍',
          activities: [
            'Explored the marketplace',
            'Browsed language challenges',
            'Checked profile stats',
          ],
          highlights: [
            'Discovered 12 new challenges to try!',
          ],
          audioUrl: 'mock://audio/2days.mp3',
          durationSeconds: 38,
        ),
      ],
      DateTime(now.year, now.month, now.day - 5): [
        JournalEntry(
          id: '4',
          date: DateTime(now.year, now.month, now.day - 5),
          mood: 'proud',
          entryText: 'Big milestone today! I reached a 5-day streak in my Korean challenge. Every day I\'m learning new words and phrases. Today I learned how to introduce myself in Korean. The feeling when you understand something new is just... wow! I\'m so proud of myself! 🎉',
          activities: [
            'Korean practice session',
            'Achieved 5-day streak',
            'Learned self-introduction',
          ],
          highlights: [
            'Hit 5-day streak milestone!',
            'Can introduce myself in Korean now!',
          ],
          audioUrl: 'mock://audio/5days.mp3',
          durationSeconds: 41,
        ),
      ],
    };
  }
  
  List<JournalEntry> _getEntriesForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _entries[normalizedDay] ?? [];
  }
  
  bool _hasEntryForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _entries.containsKey(normalizedDay);
  }

  @override
  Widget build(BuildContext context) {
    final selectedEntries = _selectedDay != null ? _getEntriesForDay(_selectedDay!) : [];
    final hasSelectedEntry = selectedEntries.isNotEmpty;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.pastelPink.withOpacity(0.3),
              AppTheme.pastelPurple.withOpacity(0.2),
              AppTheme.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Journal',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, y').format(_focusedDay),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Custom Calendar Grid
              Expanded(
                child: _buildCustomCalendar(),
              ),
              
              // Preview card when day is selected
              if (hasSelectedEntry)
                _buildPreviewCard(selectedEntries.first),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCustomCalendar() {
    // Get first day of month and number of days
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          // Week day headers
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.darkGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          
          // Calendar grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 42, // 6 weeks max
              itemBuilder: (context, index) {
                final dayNumber = index - startWeekday + 1;
                
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox.shrink();
                }
                
                final date = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
                final isToday = _isSameDay(date, DateTime.now());
                final isSelected = _isSameDay(date, _selectedDay);
                final hasEntry = _hasEntryForDay(date);
                final entry = hasEntry ? _getEntriesForDay(date).first : null;
                
                return _buildDayCell(
                  dayNumber,
                  date,
                  isToday: isToday,
                  isSelected: isSelected,
                  hasEntry: hasEntry,
                  entry: entry,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDayCell(
    int day,
    DateTime date, {
    required bool isToday,
    required bool isSelected,
    required bool hasEntry,
    JournalEntry? entry,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = date;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day number
            Text(
              '$day',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppTheme.primaryPink : AppTheme.black,
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            
            // Entry indicator box - always show, empty or with emoji
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: hasEntry && entry != null
                    ? Color(int.parse(entry.moodColor.replaceFirst('#', '0xFF')))
                        .withOpacity(0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryPink
                      : hasEntry
                          ? Colors.transparent
                          : AppTheme.mediumGray.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: hasEntry && entry != null
                  ? Center(
                      child: Text(
                        entry.moodEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPreviewCard(JournalEntry entry) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JournalEntryDetail(entry: entry),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Mood emoji
                Text(
                  entry.moodEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d').format(entry.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.darkGray,
                        ),
                      ),
                      Text(
                        'Feeling ${entry.mood}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow indicator
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.primaryPink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

