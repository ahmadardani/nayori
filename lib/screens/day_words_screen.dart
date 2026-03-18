import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_model.dart';
import '../models/kanji_model.dart';
import 'word_detail_screen.dart';
import 'dojo_quiz_screen.dart';

class DayWordsScreen extends StatefulWidget {
  final int dayNumber;
  final List<KanjiData> allData;
  final bool isDojoMode; 

  const DayWordsScreen({super.key, required this.dayNumber, required this.allData, required this.isDojoMode});

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
      final String jsonString = await rootBundle.loadString('assets/day${widget.dayNumber}.json');
      final WordParsedResult result = await compute(parseWordDataInBackground, jsonString);
      
      _allWords = result.allWords;
      _uniqueKanjis = result.uniqueKanjis;
      _filteredKanjis = _uniqueKanjis;
      
      await _checkMasteryStatus();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading day${widget.dayNumber}.json: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkMasteryStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const int sevenDaysInSeconds = 604800; 

    Map<String, bool> tempStatus = {};
    for (String kanji in _uniqueKanjis) {
      int? clearedTime = prefs.getInt('dojo_$kanji');
      if (clearedTime != null) {
        if (currentTime - clearedTime < sevenDaysInSeconds) {
          tempStatus[kanji] = true;
        } else {
          prefs.remove('dojo_$kanji');
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.isDojoMode ? 'Day ${widget.dayNumber} Dojo' : 'Day ${widget.dayNumber} Words')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _uniqueKanjis.isEmpty
              ? const Center(child: Text("Data not found or empty."))
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        widget.isDojoMode 
                            ? "Tap a kanji to start the DOJO Quiz." 
                            : "Tap a kanji to view vocabulary list.",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
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
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.only(
                          left: 12.0,
                          right: 12.0,
                          top: 8.0,
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

                          return Card(
                            elevation: isMastered ? 0.0 : 1.0,
                            color: isMastered ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : null,
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                final wordsForKanji = _allWords.where((w) => w.kanji == kanjiStr).toList();
                                
                                if (widget.isDojoMode) {
                                  final result = await Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => DojoQuizScreen(kanji: kanjiStr, wordList: wordsForKanji),
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