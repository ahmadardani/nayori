import 'package:flutter/material.dart';
import '../models/kanji_model.dart';
import 'day_words_screen.dart';

class AllWordsMenuScreen extends StatelessWidget {
  final List<KanjiData> allData;

  const AllWordsMenuScreen({super.key, required this.allData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Words'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDayCard(context, 1, 'Day 1', 'Beginner vocabulary part 1'),
          const SizedBox(height: 12),
          _buildDayCard(context, 2, 'Day 2', 'Beginner vocabulary part 2'),
          const SizedBox(height: 12),
          _buildDayCard(context, 3, 'Day 3', 'Beginner vocabulary part 3'),
          const SizedBox(height: 12),
          _buildDayCard(context, 4, 'Day 4', 'Intermediate vocabulary part 1'),
          const SizedBox(height: 12),
          _buildDayCard(context, 5, 'Day 5', 'Intermediate vocabulary part 2'),
        ],
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, int dayNumber, String title, String subtitle) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => DayWordsScreen(
                dayNumber: dayNumber,
                allData: allData,
              ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.today_rounded, size: 26, color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}