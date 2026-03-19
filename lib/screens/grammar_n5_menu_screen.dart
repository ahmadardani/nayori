import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/grammar_n5_model.dart';
import 'grammar_n5_detail_screen.dart';

class GrammarN5MenuScreen extends StatefulWidget {
  const GrammarN5MenuScreen({super.key});

  @override
  State<GrammarN5MenuScreen> createState() => _GrammarN5MenuScreenState();
}

class _GrammarN5MenuScreenState extends State<GrammarN5MenuScreen> {
  bool _isLoading = true;
  List<GrammarN5Data> _grammarList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

Future<void> _loadData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/grammars/n5/grammars.json');
      
      final result = await compute(parseGrammarN5DataInBackground, jsonString);
      setState(() {
        _grammarList = result;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading N5 Grammar: $e'); 
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grammar N5')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.only(
                left: 16.0, 
                right: 16.0, 
                top: 16.0, 
                bottom: MediaQuery.of(context).padding.bottom + 80.0, 
              ),
              itemCount: _grammarList.length,
              itemBuilder: (context, index) {
                final item = _grammarList[index];

                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 1.0,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    leading: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Icon(Icons.auto_stories_rounded, color: Theme.of(context).colorScheme.onSecondaryContainer),
                    ),
                    title: Text(item.title, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                    subtitle: Text(item.meaningId, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => GrammarN5DetailScreen(data: item),
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