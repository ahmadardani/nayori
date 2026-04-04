import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import '../models/compound_verb_model.dart';
import 'compound_verb_quiz_screen.dart';

class CompoundVerbMenuScreen extends StatefulWidget {
  const CompoundVerbMenuScreen({super.key});

  @override
  State<CompoundVerbMenuScreen> createState() => _CompoundVerbMenuScreenState();
}

class _CompoundVerbMenuScreenState extends State<CompoundVerbMenuScreen> {
  List<CompoundVerbData> _verbs = [];
  bool _isLoading = true;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadData();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("ja-JP");
    await _flutterTts.setSpeechRate(0.45);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _loadData() async {
    final String response = await rootBundle.loadString('assets/compound_verbs.json'); 
    setState(() {
      _verbs = parseCompoundVerbs(response);
      _isLoading = false;
    });
  }

  void _navigateToQuiz() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CompoundVerbQuizScreen(
          verbDataList: _verbs,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compound Verbs'),
        actions: [
          if (!_isLoading && _verbs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.sports_esports_rounded),
              tooltip: 'Start Quiz',
              onPressed: _navigateToQuiz,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.only(
                left: 16.0, 
                right: 16.0, 
                top: 16.0, 
                bottom: MediaQuery.of(context).padding.bottom + 40.0
              ),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0, left: 4.0),
                  child: Text(
                    'Latihan & Materi',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(bottom: 24.0),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: InkWell(
                    onTap: _navigateToQuiz,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Icon(Icons.keyboard_rounded, size: 28.0, color: Theme.of(context).colorScheme.onPrimaryContainer),
                          const SizedBox(width: 20.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mulai Latihan Mengetik', 
                                  style: TextStyle(
                                    fontSize: 18.0, 
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  )
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Ketik bahasa Jepangnya dari terjemahan', 
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8), 
                                    height: 1.3
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 18.0, color: Theme.of(context).colorScheme.onPrimaryContainer),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0, left: 4.0),
                  child: Text(
                    'Review Compound Verbs',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
                ..._verbs.map((verb) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: ExpansionTile(
                      title: Text(
                        verb.pattern,
                        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        verb.meaning,
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
                      ),
                      children: verb.examples.map((example) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(example.japanese, style: const TextStyle(fontSize: 16.0)),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.volume_up_rounded, color: Theme.of(context).colorScheme.primary, size: 20.0),
                                onPressed: () => _speak(example.japanese),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(example.indonesian, style: TextStyle(color: Colors.grey.shade600)),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}