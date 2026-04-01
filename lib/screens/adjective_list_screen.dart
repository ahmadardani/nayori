import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/adjective_model.dart';
import 'adjective_quiz_screen.dart';

class AdjectiveListScreen extends StatefulWidget {
  final String category;
  final String title; 

  const AdjectiveListScreen({
    super.key,
    required this.category,
    required this.title,
  });

  @override
  State<AdjectiveListScreen> createState() => _AdjectiveListScreenState();
}

class _AdjectiveListScreenState extends State<AdjectiveListScreen> {
  bool _isLoading = true;
  List<AdjectiveData> _allAdjectives = [];
  Map<String, List<AdjectiveData>> _groupedAdjectives = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/adjectives/adjectives.json');
      final List<AdjectiveData> allData = await compute(parseAdjectiveDataInBackground, jsonString);

      final filteredData = allData.where((adj) => adj.category == widget.category).toList();

      Map<String, List<AdjectiveData>> tempGroups = {};
      for (var adj in filteredData) {
        if (!tempGroups.containsKey(adj.level)) {
          tempGroups[adj.level] = [];
        }
        tempGroups[adj.level]!.add(adj);
      }

      setState(() {
        _allAdjectives = filteredData;
        _groupedAdjectives = tempGroups;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading adjectives: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groupedAdjectives.isEmpty
              ? const Center(child: Text("Data belum tersedia.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 16.0,
                    bottom: MediaQuery.of(context).padding.bottom + 16.0,
                  ),
                  itemCount: _groupedAdjectives.keys.length + 1,
                  itemBuilder: (context, index) {

                    if (index == 0) {
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 1.0,
                        margin: const EdgeInsets.only(bottom: 24.0),
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          leading: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.all_inclusive_rounded, color: Theme.of(context).colorScheme.onPrimary),
                          ),
                          title: const Text('Semua Level (Campuran)', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                          subtitle: Text('${_allAdjectives.length} Kosakata Tersedia'),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => AdjectiveListDetailScreen(
                                  title: 'Semua Level',
                                  adjectives: _allAdjectives,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                        ),
                      );
                    }

                    final levelName = _groupedAdjectives.keys.elementAt(index - 1);
                    final adjectivesInLevel = _groupedAdjectives[levelName]!;

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 0.0,
                      margin: const EdgeInsets.only(bottom: 8.0),
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        leading: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Icon(Icons.style_rounded, color: Theme.of(context).colorScheme.onSecondaryContainer),
                        ),
                        title: Text(levelName, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                        subtitle: Text('${adjectivesInLevel.length} Kosakata'),
                        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => AdjectiveListDetailScreen(
                                title: levelName,
                                adjectives: adjectivesInLevel,
                              ),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class AdjectiveListDetailScreen extends StatefulWidget {
  final String title;
  final List<AdjectiveData> adjectives;

  const AdjectiveListDetailScreen({super.key, required this.title, required this.adjectives});

  @override
  State<AdjectiveListDetailScreen> createState() => _AdjectiveListDetailScreenState();
}

class _AdjectiveListDetailScreenState extends State<AdjectiveListDetailScreen> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("ja-JP");
    await flutterTts.setSpeechRate(0.45);
  }

  Future<void> _speak(String text) async {
    String textToSpeak = text.replaceAll(RegExp(r'\+\s*Noun', caseSensitive: false), '').trim();
    textToSpeak = textToSpeak.split('/').first.trim();
    await flutterTts.speak(textToSpeak);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: widget.adjectives.isEmpty
          ? const Center(child: Text("Data kosong.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: EdgeInsets.only(
                left: 16.0, right: 16.0, top: 16.0,
                bottom: MediaQuery.of(context).padding.bottom + 100.0, 
              ),
              itemCount: widget.adjectives.length,
              itemBuilder: (context, index) {
                final adj = widget.adjectives[index];
                return _buildAdjectiveCard(adj);
              },
            ),
      floatingActionButton: widget.adjectives.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => AdjectiveQuizScreen(
                      title: widget.title,
                      adjectiveList: widget.adjectives, 
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              icon: const Icon(Icons.fitness_center_rounded),
              label: const Text('Start Dojo', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildAdjectiveCard(AdjectiveData adj) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 0.0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        title: Text(
          adj.vocabulary,
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            adj.translation,
            style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.volume_up_rounded, color: Theme.of(context).colorScheme.primary),
          onPressed: () => _speak(adj.vocabulary),
          tooltip: 'Listen',
        ),
      ),
    );
  }
}