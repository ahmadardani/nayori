import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/kanji_model.dart';
import 'kanji_detail_screen.dart';

class AllKanjiScreen extends StatefulWidget {
  const AllKanjiScreen({super.key});

  @override
  State<AllKanjiScreen> createState() => _AllKanjiScreenState();
}

class _AllKanjiScreenState extends State<AllKanjiScreen> {
  List<KanjiData> _allData = [];
  List<String> _uniqueKanjiList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final List<dynamic> data = json.decode(response);
    final parsedData = data.map((json) => KanjiData.fromJson(json)).toList();
    
    final uniqueKanjis = parsedData.map((e) => e.kanji).toSet().toList();

    setState(() {
      _allData = parsedData;
      _uniqueKanjiList = uniqueKanjis;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Kanji')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _uniqueKanjiList.length,
        itemBuilder: (context, index) {
          final kanjiStr = _uniqueKanjiList[index];
          return InkWell(
            onTap: () {
              final kanjiSentences = _allData.where((k) => k.kanji == kanjiStr).toList();
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => KanjiDetailScreen(kanji: kanjiStr, dataList: kanjiSentences))
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Center(
                child: Text(kanjiStr, style: const TextStyle(fontSize: 32)),
              ),
            ),
          );
        },
      ),
    );
  }
}