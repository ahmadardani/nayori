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
                Text(data.example, style: const TextStyle(fontSize: 28.0, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        title: Text('Kanji Details: $kanji', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0, letterSpacing: -0.5))
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1.0)
              ),
              child: Center(
                child: Text(
                  kanji, 
                  style: TextStyle(
                    fontSize: 80, 
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.primary
                  )
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(
                left: 20.0, right: 20.0, top: 8.0,
                bottom: MediaQuery.of(context).padding.bottom + 24.0
              ),
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                final item = dataList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: borderColor, width: 1.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    title: Text(item.example, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
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