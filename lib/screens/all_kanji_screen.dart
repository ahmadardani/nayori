import 'package:flutter/material.dart';
import '../models/kanji_model.dart';
import 'kanji_detail_screen.dart';

class AllKanjiScreen extends StatelessWidget {
  final List<KanjiData> allData;
  final List<String> uniqueKanjis;

  const AllKanjiScreen({super.key, required this.allData, required this.uniqueKanjis});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Kanji')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: uniqueKanjis.length,
        itemBuilder: (context, index) {
          final kanjiStr = uniqueKanjis[index];
          return Card(
            elevation: 1,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                final kanjiSentences = allData.where((k) => k.kanji == kanjiStr).toList();
                Navigator.push(
                  context, 
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => KanjiDetailScreen(kanji: kanjiStr, dataList: kanjiSentences),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: Center(
                child: Text(
                  kanjiStr, 
                  style: TextStyle(fontSize: 32, color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}