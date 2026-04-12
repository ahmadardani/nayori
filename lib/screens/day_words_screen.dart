import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_model.dart';
import '../models/kanji_model.dart';
import 'word_detail_screen.dart';
import 'practice_quiz_screen.dart'; 

class DayWordsScreen extends StatefulWidget {
  final int dayNumber;
  final List<KanjiData> allData;
  final bool isPracticeMode; 

  const DayWordsScreen({super.key, required this.dayNumber, required this.allData, required this.isPracticeMode});

  @override
  State<DayWordsScreen> createState() => _DayWordsScreenState();
}

class _DayWordsScreenState extends State<DayWordsScreen> {
  bool _isLoading = true;
  List<WordData> _allWords = [];
  List<String> _uniqueKanjis = [];
  List<String> _filteredKanjis = [];
  final TextEditingController _searchController = TextEditingController();
  
  Map<String, bool> _masteredStatus = {};

  @override
  void initState() {
    super.initState();
    _loadDayData();
  }

  Future<void> _loadDayData() async {
    try {
      List<WordData> combinedWords = [];
      
      if (widget.dayNumber == 0) {
        for (int i = 1; i <= 5; i++) {
          final String jsonString = await rootBundle.loadString('assets/kanji/day$i.json');
          final WordParsedResult result = await compute(parseWordDataInBackground, jsonString);
          combinedWords.addAll(result.allWords);
        }
      } else {
        final String jsonString = await rootBundle.loadString('assets/kanji/day${widget.dayNumber}.json');
        final WordParsedResult result = await compute(parseWordDataInBackground, jsonString);
        combinedWords.addAll(result.allWords);
      }
      
      _allWords = combinedWords;
      _uniqueKanjis = combinedWords.map((e) => e.kanji).toSet().toList();
      _filteredKanjis = _uniqueKanjis;
      
      await _checkMasteryStatus();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkMasteryStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const int sevenDaysInSeconds = 604800; 

    Map<String, bool> tempStatus = {};
    for (String kanji in _uniqueKanjis) {
      int? clearedTime = prefs.getInt('practice_$kanji');
      if (clearedTime != null) {
        if (currentTime - clearedTime < sevenDaysInSeconds) {
          tempStatus[kanji] = true;
        } else {
          prefs.remove('practice_$kanji');
          tempStatus[kanji] = false;
        }
      } else {
        tempStatus[kanji] = false;
      }
    }
    setState(() {
      _masteredStatus = tempStatus;
    });
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    String appBarTitle = widget.dayNumber == 0 
        ? (widget.isPracticeMode ? 'All Days Quiz' : 'All Days Words') 
        : (widget.isPracticeMode ? 'Day ${widget.dayNumber} Quiz' : 'Day ${widget.dayNumber} Words');

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        title: Text(appBarTitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0, letterSpacing: -0.5))
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _uniqueKanjis.isEmpty
              ? const Center(child: Text("Data not found or empty."))
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Text(
                        widget.isPracticeMode 
                            ? "Select a Kanji to start the vocabulary quiz." 
                            : "Select a Kanji to view the vocabulary list.",
                        style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: borderColor, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: borderColor, width: 1.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.only(
                          left: 20.0,
                          right: 20.0,
                          top: 16.0,
                          bottom: MediaQuery.of(context).padding.bottom + 80.0,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                        ),
                        itemCount: _filteredKanjis.length,
                        itemBuilder: (context, index) {
                          final kanjiStr = _filteredKanjis[index];
                          final isMastered = _masteredStatus[kanjiStr] ?? false;

                          return InkWell(
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              final wordsForKanji = _allWords.where((w) => w.kanji == kanjiStr).toList();
                              
                              if (widget.isPracticeMode) {
                                final result = await Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => PracticeQuizScreen(kanji: kanjiStr, wordList: wordsForKanji),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                                
                                if (result == true) {
                                  _checkMasteryStatus();
                                }
                              } else {
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
                              }
                            },
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isMastered ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: isMastered ? Theme.of(context).colorScheme.primary.withOpacity(0.5) : borderColor, width: 1.0),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      kanjiStr,
                                      style: TextStyle(fontSize: 32.0, color: Theme.of(context).colorScheme.primary),
                                    ),
                                  ),
                                  if (isMastered)
                                    const Positioned(
                                      right: 4.0,
                                      top: 4.0,
                                      child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 16.0),
                                    ),
                                ],
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