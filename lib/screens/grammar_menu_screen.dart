import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/grammar_model.dart';
import 'grammar_quiz_screen.dart';

class GrammarMenuScreen extends StatefulWidget {
  const GrammarMenuScreen({super.key});

  @override
  State<GrammarMenuScreen> createState() => _GrammarMenuScreenState();
}

class _GrammarMenuScreenState extends State<GrammarMenuScreen> {
  bool _isLoading = true;
  List<GrammarData> _allGrammar = [];
  List<String> _chapters = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/grammar.json');
      final result = await compute(parseGrammarDataInBackground, jsonString);
      setState(() {
        _allGrammar = result.allGrammar;
        _chapters = result.uniqueChapters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grammar Dojo')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.only(
                left: 16.0, 
                right: 16.0, 
                top: 16.0, 
                bottom: MediaQuery.of(context).padding.bottom + 80.0, 
              ),
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                final chapter = _chapters[index];
                final chapterData = _allGrammar.where((g) => g.chapter == chapter).toList();

                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.edit_note_rounded, color: Theme.of(context).colorScheme.onSecondaryContainer),
                    ),
                    title: Text(chapter, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    subtitle: Text('${chapterData.length} challenges'),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => GrammarQuizScreen(
                            chapter: chapter,
                            grammarList: chapterData,
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