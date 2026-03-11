import 'package:flutter/material.dart';
import '../models/word_model.dart';
import 'word_detail_screen.dart';

class Day1WordsScreen extends StatefulWidget {
  final List<WordData> allWords;
  final List<String> uniqueKanjis;

  const Day1WordsScreen({super.key, required this.allWords, required this.uniqueKanjis});

  @override
  State<Day1WordsScreen> createState() => _Day1WordsScreenState();
}

class _Day1WordsScreenState extends State<Day1WordsScreen> {
  List<String> _filteredKanjis = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredKanjis = widget.uniqueKanjis;
  }

  void _filterKanji(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredKanjis = widget.uniqueKanjis;
      });
      return;
    }
    setState(() {
      _filteredKanjis = widget.uniqueKanjis
          .where((k) => k.contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Day 1 Kanji')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterKanji,
              decoration: InputDecoration(
                hintText: 'Search kanji...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterKanji('');
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 0,
                bottom: MediaQuery.of(context).padding.bottom + 40,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredKanjis.length,
              itemBuilder: (context, index) {
                final kanjiStr = _filteredKanjis[index];
                return Card(
                  elevation: 1,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      final wordsForKanji = widget.allWords.where((w) => w.kanji == kanjiStr).toList();
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => WordDetailScreen(kanji: kanjiStr, wordList: wordsForKanji),
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
          ),
        ],
      ),
    );
  }
}