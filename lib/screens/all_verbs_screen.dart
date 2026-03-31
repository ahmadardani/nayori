import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/verb_model.dart';
import 'verb_quiz_screen.dart'; 

class AllVerbsScreen extends StatefulWidget {
  final String title;
  final List<String> jsonPaths;

  const AllVerbsScreen({super.key, required this.title, required this.jsonPaths});

  @override
  State<AllVerbsScreen> createState() => _AllVerbsScreenState();
}

class _AllVerbsScreenState extends State<AllVerbsScreen> {
  bool _isLoading = true;
  List<VerbData> _allVerbs = [];
  List<VerbData> _filteredVerbs = [];
  
  final TextEditingController _searchController = TextEditingController();
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
      List<VerbData> combinedVerbs = [];
      for (String path in widget.jsonPaths) {
        final String jsonString = await rootBundle.loadString(path);
        final result = await compute(parseVerbDataInBackground, jsonString);
        combinedVerbs.addAll(result.allVerbs);
      }

      setState(() {
        _allVerbs = combinedVerbs;
        _filteredVerbs = combinedVerbs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading verbs: $e");
      setState(() => _isLoading = false);
    }
  }

  void _filterVerbs(String query) {
    final trimmedQuery = query.toLowerCase();
    if (trimmedQuery.isEmpty) {
      setState(() => _filteredVerbs = _allVerbs);
      return;
    }
    setState(() {
      _filteredVerbs = _allVerbs
          .where((v) => v.kanji.contains(trimmedQuery) || v.meaning.toLowerCase().contains(trimmedQuery))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterVerbs,
                    decoration: InputDecoration(
                      hintText: 'Search verb or meaning...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterVerbs('');
                              },
                            )
                          : null,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                    ),
                  ),
                ),
                Expanded(child: _buildVerbList(_filteredVerbs)),
              ],
            ),
      floatingActionButton: (!_isLoading && _filteredVerbs.isNotEmpty)
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => VerbQuizScreen(
                      title: widget.title,
                      verbList: _filteredVerbs, 
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

  Widget _buildVerbList(List<VerbData> verbs) {
    if (verbs.isEmpty) {
      return const Center(child: Text('No verbs found.', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: MediaQuery.of(context).padding.bottom + 100.0, 
      ),
      itemCount: verbs.length,
      itemBuilder: (context, index) {
        final verb = verbs[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ExpansionTile(
            title: Text(verb.kanji, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            subtitle: Text(verb.meaning),
            childrenPadding: const EdgeInsets.all(16.0),
            children: [
              if (verb.dictionary.isNotEmpty) _buildFormRow('Dictionary', verb.dictionary),
              if (verb.masuForm.isNotEmpty) _buildFormRow('Masu Form', verb.masuForm),
              if (verb.naiForm.isNotEmpty) _buildFormRow('Nai Form', verb.naiForm),
              if (verb.taForm.isNotEmpty) _buildFormRow('Ta Form', verb.taForm),
              if (verb.nakattaForm.isNotEmpty) _buildFormRow('Nakatta Form', verb.nakattaForm),
              if (verb.teForm.isNotEmpty) _buildFormRow('Te Form', verb.teForm),
              if (verb.potential.isNotEmpty) _buildFormRow('Potential', verb.potential),
              if (verb.volitional.isNotEmpty) _buildFormRow('Volitional', verb.volitional),
              if (verb.teKudasai.isNotEmpty) _buildFormRow('Te Kudasai', verb.teKudasai),
              if (verb.teIru.isNotEmpty) _buildFormRow('Te Iru', verb.teIru),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormRow(String label, String formText) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            Row(
              children: [
                Text(formText, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTap: () => _speak(formText),
                  child: Icon(Icons.volume_up_rounded, color: Theme.of(context).colorScheme.primary, size: 20.0),
                )
              ],
            )
          ],
        ),
        const Divider(),
      ],
    );
  }
}