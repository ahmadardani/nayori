import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/verb_model.dart';

class AllVerbsScreen extends StatefulWidget {
  const AllVerbsScreen({super.key});

  @override
  State<AllVerbsScreen> createState() => _AllVerbsScreenState();
}

class _AllVerbsScreenState extends State<AllVerbsScreen> {
  bool _isLoading = true;
  List<VerbData> _n5Verbs = [];
  List<VerbData> _n5Filtered = [];
  List<VerbData> _n4Verbs = [];
  List<VerbData> _n4Filtered = [];
  
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
      final String n5String = await rootBundle.loadString('assets/N5_Verbs_C1.json');
      final n5Result = await compute(parseVerbDataInBackground, n5String);

      final String n4String = await rootBundle.loadString('assets/N4_Verbs_C1.json');
      final n4Result = await compute(parseVerbDataInBackground, n4String);

      setState(() {
        _n5Verbs = n5Result.allVerbs;
        _n5Filtered = _n5Verbs;
        
        _n4Verbs = n4Result.allVerbs;
        _n4Filtered = _n4Verbs;
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterVerbs(String query) {
    final trimmedQuery = query.toLowerCase();
    if (trimmedQuery.isEmpty) {
      setState(() {
        _n5Filtered = _n5Verbs;
        _n4Filtered = _n4Verbs;
      });
      return;
    }
    setState(() {
      _n5Filtered = _n5Verbs
          .where((v) => v.kanji.contains(trimmedQuery) || v.meaning.toLowerCase().contains(trimmedQuery))
          .toList();
      _n4Filtered = _n4Verbs
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('All Verbs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'N5 Verbs'),
              Tab(text: 'N4 Verbs'),
            ],
          ),
        ),
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
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildVerbList(_n5Filtered),
                        _buildVerbList(_n4Filtered),
                      ],
                    ),
                  ),
                ],
              ),
      ),
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
        bottom: MediaQuery.of(context).padding.bottom + 80.0,
      ),
      itemCount: verbs.length,
      itemBuilder: (context, index) {
        final verb = verbs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ExpansionTile(
            title: Text(verb.kanji, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            subtitle: Text(verb.meaning),
            childrenPadding: const EdgeInsets.all(16.0),
            children: [
              _buildFormRow('Dictionary', verb.dictionary),
              const Divider(),
              _buildFormRow('Nai Form', verb.naiForm),
              const Divider(),
              _buildFormRow('Ta Form', verb.taForm),
              const Divider(),
              _buildFormRow('Nakatta Form', verb.nakattaForm),
              const Divider(),
              _buildFormRow('Te Form', verb.teForm),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormRow(String label, String formText) {
    return Row(
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
    );
  }
}