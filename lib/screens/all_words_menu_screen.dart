import 'package:flutter/material.dart';
import '../models/kanji_model.dart';
import 'day_words_screen.dart';

class AllWordsMenuScreen extends StatelessWidget {
  final List<KanjiData> allData;
  final bool isPracticeMode; 

  const AllWordsMenuScreen({super.key, required this.allData, required this.isPracticeMode});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Text(
          isPracticeMode ? 'Practice Menu' : 'All Words',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0, letterSpacing: -0.5)
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 20.0, 
          right: 20.0, 
          top: 16.0, 
          bottom: MediaQuery.of(context).padding.bottom + 16.0
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              isPracticeMode ? 'Select Practice Package' : 'Select Vocabulary Module',
              style: TextStyle(
                fontSize: 16.0, 
                fontWeight: FontWeight.w700, 
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600
              ),
            ),
          ),
          _buildDayCard(context, 0, 'All Days (Mixed)', isPracticeMode ? 'Test all knowledge' : 'All vocabulary combined'),
          _buildDayCard(context, 1, 'Day 1', isPracticeMode ? 'Practice Day 1' : 'Beginner vocabulary part 1'),
          _buildDayCard(context, 2, 'Day 2', isPracticeMode ? 'Practice Day 2' : 'Beginner vocabulary part 2'),
          _buildDayCard(context, 3, 'Day 3', isPracticeMode ? 'Practice Day 3' : 'Beginner vocabulary part 3'),
          _buildDayCard(context, 4, 'Day 4', isPracticeMode ? 'Practice Day 4' : 'Intermediate vocabulary part 1'),
          _buildDayCard(context, 5, 'Day 5', isPracticeMode ? 'Practice Day 5' : 'Intermediate vocabulary part 2'),
        ],
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, int dayNumber, String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    
    final isAllDays = dayNumber == 0;
    final iconData = isAllDays 
        ? Icons.all_inclusive_rounded 
        : (isPracticeMode ? Icons.fitness_center_rounded : Icons.today_rounded);
    final iconColor = isAllDays ? Theme.of(context).colorScheme.primary : Colors.grey.shade600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => DayWordsScreen(
                dayNumber: dayNumber,
                allData: allData,
                isPracticeMode: isPracticeMode, 
              ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isAllDays ? Theme.of(context).colorScheme.primary.withOpacity(0.5) : borderColor, 
              width: isAllDays ? 1.5 : 1.0
            ),
          ),
          child: Row(
            children: [
              Icon(iconData, size: 28.0, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}