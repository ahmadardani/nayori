import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/word_model.dart';
import '../models/kanji_model.dart';
import 'word_detail_screen.dart';

class DayWordsScreen extends StatefulWidget {
  final int dayNumber;
  final List<KanjiData> allData;

  const DayWordsScreen({super.key, required this.dayNumber, required this.allData});

  @override
  State<DayWordsScreen> createState() => _DayWordsScreenState();
}

class _DayWordsScreenState extends State<DayWordsScreen> {
  bool _isLoading = true;
  List<WordData> _allWords = [];
  List<String> _uniqueKanjis = [];
  List<String> _filteredKanjis = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDayData();
  }

  Future<void> _loadDayData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/day${widget.dayNumber}.json');
      final WordParsedResult result = await compute(parseWordDataInBackground, jsonString);
      
      setState(() {
        _allWords = result.allWords;
        _uniqueKanjis = result.uniqueKanjis;
        _filteredKanjis = _uniqueKanjis;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading day${widget.dayNumber}.json: $e");
      setState(() => _isLoading = false);
    }
  }

  void _filterKanji(String query) {
    if (query.isEmpty) {
      setState(() => _filteredKanjis = _uniqueKanjis);
      return;
    }
    setState(() {
      _filteredKanjis = _uniqueKanjis.where((k) => k.contains(query)).toList();
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
      appBar: AppBar(title: Text('Day ${widget.dayNumber} Words')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _uniqueKanjis.isEmpty
              ? const Center(child: Text("Data not found or empty."))
              : Column(
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
                                final wordsForKanji = _allWords.where((w) => w.kanji == kanjiStr).toList();
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => WordDetailScreen(
                                      kanji: kanjiStr, 
                                      wordList: wordsForKanji, 
                                      allData: widget.allData
                                    ),
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