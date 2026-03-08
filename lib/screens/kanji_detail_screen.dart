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
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black, width: 2)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kanji: ${data.kanji}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(data.example, style: const TextStyle(fontSize: 20)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(color: Colors.black54, thickness: 1),
              ),
              const Text('Meaning & Reading', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text(data.readMeaning, style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail: $kanji')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 1.5)),
              color: Color(0xFFF5F5F5),
            ),
            child: Center(
              child: Text(kanji, style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w300)),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: dataList.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black26),
              itemBuilder: (context, index) {
                final item = dataList[index];
                return InkWell(
                  onTap: () => _showReadMeaning(context, item),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(item.example, style: const TextStyle(fontSize: 18)),
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