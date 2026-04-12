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
      final String jsonString = await rootBundle.loadString('assets/grammar-points/n5/grammar-points.json');
      
      final result = await compute(parseGrammarN5DataInBackground, jsonString);
      setState(() {
        _grammarList = result;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading N5 Grammar JSON: $e'); 
      setState(() => _isLoading = false);
    }
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
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: const Text(
          'Grammar N5', 
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0, letterSpacing: -0.5)
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.only(
                left: 20.0, 
                right: 20.0, 
                top: 16.0, 
                bottom: MediaQuery.of(context).padding.bottom + 80.0, 
              ),
              itemCount: _grammarList.length,
              itemBuilder: (context, index) {
                final item = _grammarList[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
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
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: borderColor, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_stories_rounded, size: 24.0, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Text(
                              item.title, 
                              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, letterSpacing: -0.3)
                            ),
                          ),
                          Icon(Icons.arrow_forward_rounded, color: Colors.grey.shade400, size: 20.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}