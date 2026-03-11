import 'package:flutter/material.dart';
import '../models/word_model.dart';

class WordDetailScreen extends StatelessWidget {
  final String kanji;
  final List<WordData> wordList;

  const WordDetailScreen({super.key, required this.kanji, required this.wordList});

  void _showWordMeaning(BuildContext context, WordData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.foundInCharacters, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Divider(height: 32),
                Text(
                  'Reading', 
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 4),
                Text(data.foundInReading, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                Text(
                  'Meaning', 
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 4),
                Text(data.foundInMeaning, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Words with $kanji')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  kanji, 
                  style: TextStyle(
                    fontSize: 80, 
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.onPrimaryContainer
                  )
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: wordList.length,
              itemBuilder: (context, index) {
                final item = wordList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    title: Text(item.foundInCharacters, style: const TextStyle(fontSize: 18)),
                    trailing: const Icon(Icons.info_outline_rounded, color: Colors.grey),
                    onTap: () => _showWordMeaning(context, item),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}