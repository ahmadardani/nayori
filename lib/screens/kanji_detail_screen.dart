import 'package:flutter/material.dart';
import '../models/kanji_model.dart';

class KanjiDetailScreen extends StatelessWidget {
  final String kanji;
  final List<KanjiData> dataList;

  const KanjiDetailScreen({super.key, required this.kanji, required this.dataList});

  void _showReadMeaning(BuildContext context, KanjiData data) {
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
                Text(data.example, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                const Divider(height: 32),
                Text(
                  'Reading & Meaning', 
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 8),
                Text(data.readMeaning, style: const TextStyle(fontSize: 16, height: 1.5)),
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
      appBar: AppBar(title: Text('Kanji Details: $kanji')),
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
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                final item = dataList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    title: Text(item.example, style: const TextStyle(fontSize: 16)),
                    trailing: const Icon(Icons.menu_book_rounded, color: Colors.grey),
                    onTap: () => _showReadMeaning(context, item),
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