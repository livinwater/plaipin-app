import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/journal_entry.dart';
import '../theme/app_theme.dart';
import '../services/cartesia_service.dart';

/// Journal Entry Detail Screen
/// Shows PlaiPin's full diary entry with audio playback
class JournalEntryDetail extends StatefulWidget {
  final JournalEntry entry;
  
  const JournalEntryDetail({
    super.key,
    required this.entry,
  });

  @override
  State<JournalEntryDetail> createState() => _JournalEntryDetailState();
}

class _JournalEntryDetailState extends State<JournalEntryDetail> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final CartesiaService _cartesiaService = CartesiaService();
  
  bool _isPlaying = false;
  bool _isLoading = false;
  double _playbackProgress = 0.0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  
  void _setupAudioPlayer() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
    
    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
          if (_duration.inMilliseconds > 0) {
            _playbackProgress = position.inMilliseconds / _duration.inMilliseconds;
          }
        });
      }
    });
    
    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    });
    
    // Listen for completion
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _playbackProgress = 0.0;
            _position = Duration.zero;
          });
        }
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });
  }
  
  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      // If not loaded yet, generate and load audio
      if (_audioPlayer.processingState == ProcessingState.idle) {
        await _loadAndPlayAudio();
      } else {
        await _audioPlayer.play();
      }
    }
  }
  
  Future<void> _loadAndPlayAudio() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Detect emotion from mood
      final emotion = _cartesiaService.detectEmotionFromMood(widget.entry.mood);
      
      // Generate speech with Cartesia
      final audioBytes = await _cartesiaService.generateSpeech(
        text: widget.entry.entryText,
        emotion: emotion,
        speed: 1.1, // Slightly faster for childlike voice
      );
      
      // Save to temporary file (fixes iOS/macOS audio error -11828)
      final tempDir = await getTemporaryDirectory();
      final audioFile = File('${tempDir.path}/plaipin_diary_${widget.entry.id}.wav');
      await audioFile.writeAsBytes(audioBytes);
      
      // Load audio from file
      await _audioPlayer.setAudioSource(
        AudioSource.file(audioFile.path),
      );
      
      // Start playing
      await _audioPlayer.play();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎵 PlaiPin is reading the diary!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load audio: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('EEEE, MMMM d, y');
    
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('PlaiPin\'s Diary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Text(
              dateFormatter.format(widget.entry.date),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 16),
            
            // Mood card with PlaiPin avatar
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // PlaiPin avatar placeholder
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.pastelPink,
                            Color(int.parse(widget.entry.moodColor.replaceFirst('#', '0xFF'))),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryPink.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '🎀', // PlaiPin emoji with yellow bow
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Feeling ${widget.entry.mood}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.entry.moodEmoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.entry.activities.length} activities today',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Audio player (if available)
            if (widget.entry.hasAudio) _buildAudioPlayer(),
            
            const SizedBox(height: 24),
            
            // Diary entry text
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_stories, color: AppTheme.primaryPink, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Today\'s Adventure',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.entry.entryText,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Activities section
            if (widget.entry.activities.isNotEmpty) _buildActivitiesSection(),
            
            const SizedBox(height: 16),
            
            // Highlights section
            if (widget.entry.highlights.isNotEmpty) _buildHighlightsSection(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAudioPlayer() {
    return Card(
      elevation: 3,
      color: AppTheme.pastelPink.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Play/Pause button
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPink.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: _togglePlayback,
                        ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Listen to PlaiPin\'s diary',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _duration.inSeconds > 0
                            ? '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}'
                            : 'Tap to generate',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Icon(
                  Icons.headphones,
                  color: AppTheme.primaryPink,
                  size: 28,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _playbackProgress,
                minHeight: 6,
                backgroundColor: Colors.white,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActivitiesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppTheme.primaryPurple, size: 24),
                const SizedBox(width: 8),
                Text(
                  'What I Did Today',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.entry.activities.map((activity) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.pastelPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      activity,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHighlightsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stars, color: AppTheme.moodHappy, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Best Moments',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.entry.highlights.map((highlight) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.pastelYellow.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      highlight,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
