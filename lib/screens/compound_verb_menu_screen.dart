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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        title: const Text('Compound Verbs', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0, letterSpacing: -0.5)),
        actions: [
          if (!_isLoading && _verbs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.sports_esports_rounded),
              tooltip: 'Start Practice',
              onPressed: _navigateToQuiz,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.only(
                left: 20.0, 
                right: 20.0, 
                top: 16.0, 
                bottom: MediaQuery.of(context).padding.bottom + 40.0
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Practice & Review',
                    style: TextStyle(
                      fontSize: 16.0, 
                      fontWeight: FontWeight.w700, 
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600
                    ),
                  ),
                ),
                InkWell(
                  onTap: _navigateToQuiz,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    margin: const EdgeInsets.only(bottom: 32.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.keyboard_rounded, size: 32.0, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Typing Practice', 
                                style: TextStyle(
                                  fontSize: 16.0, 
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                  letterSpacing: -0.3
                                )
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Type the Japanese translation', 
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant, 
                                  height: 1.3
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_rounded, size: 20.0, color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ),
                ),
                
                ..._verbs.map((verb) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: borderColor, width: 1.0),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        title: Text(
                          verb.pattern,
                          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            verb.meaning,
                            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                        children: verb.examples.map((example) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: borderColor, width: 1.0))
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(example.japanese, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
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
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(example.indonesian, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}