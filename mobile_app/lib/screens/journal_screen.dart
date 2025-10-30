import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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
  CalendarFormat _calendarFormat = CalendarFormat.month;
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
    
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.pastelPink, AppTheme.pastelPurple],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPink.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🎀', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PlaiPin\'s Diary',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Daily adventures & memories',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.darkGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.pastelPink,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_entries.length} entries',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryPink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Calendar
            Card(
              margin: const EdgeInsets.all(16),
              child: TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppTheme.pastelPink,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.primaryPink,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppTheme.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                eventLoader: (day) {
                  return _hasEntryForDay(day) ? ['entry'] : [];
                },
              ),
            ),
            
            // Selected day's entries
            Expanded(
              child: selectedEntries.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: selectedEntries.length,
                      itemBuilder: (context, index) {
                        return _buildEntryCard(selectedEntries[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEntryCard(JournalEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JournalEntryDetail(entry: entry),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Mood indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(int.parse(entry.moodColor.replaceFirst('#', '0xFF'))).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.moodEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Feeling ${entry.mood}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(entry.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.darkGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Audio indicator
                  if (entry.hasAudio)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.pastelPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.headphones, size: 14, color: AppTheme.primaryPurple),
                          const SizedBox(width: 4),
                          Text(
                            entry.formattedDuration,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Preview text
              Text(
                entry.entryText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              const SizedBox(height: 12),
              
              // Activities count
              Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.primaryPurple),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.activities.length} activities',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.stars, size: 16, color: AppTheme.moodHappy),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.highlights.length} highlights',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.darkGray),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_stories_outlined,
                size: 50,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Entry Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'PlaiPin will write about this day\nwhen you have some activities!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

