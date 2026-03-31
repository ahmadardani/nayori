import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/adjective_model.dart';

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
  Map<String, List<AdjectiveData>> _groupedAdjectives = {};
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadData();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("ja-JP");
    await flutterTts.setSpeechRate(0.45);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
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
        _groupedAdjectives = tempGroups;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading adjectives: $e");
      setState(() => _isLoading = false);
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groupedAdjectives.isEmpty
              ? const Center(child: Text("Data belum tersedia.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: MediaQuery.of(context).padding.bottom + 24.0,
                  ),
                  itemCount: _groupedAdjectives.keys.length,
                  itemBuilder: (context, index) {
                    final levelName = _groupedAdjectives.keys.elementAt(index);
                    final adjectives = _groupedAdjectives[levelName]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 16.0, bottom: 8.0),
                          child: Text(
                            levelName,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        ...adjectives.map((adj) => _buildAdjectiveCard(adj)).toList(),
                      ],
                    );
                  },
                ),
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