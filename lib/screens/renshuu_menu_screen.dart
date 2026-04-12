import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/renshuu_model.dart';
import 'renshuu_quiz_screen.dart';

class RenshuuMenuScreen extends StatefulWidget {
  const RenshuuMenuScreen({super.key});

  @override
  State<RenshuuMenuScreen> createState() => _RenshuuMenuScreenState();
}

class _RenshuuMenuScreenState extends State<RenshuuMenuScreen> {
  bool _isLoading = true;
  List<RenshuuData> _allData = [];
  List<String> _chapters = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/renshuu/n5_renshuu_a.json');
      final result = await compute(parseRenshuuDataInBackground, jsonString);
      setState(() {
        _allData = result.allData;
        _chapters = result.uniqueChapters;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading Renshuu data: $e");
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
        title: const Text('Renshuu A', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0, letterSpacing: -0.5))
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
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                final chapter = _chapters[index];
                final chapterData = _allData.where((g) => g.chapter == chapter).toList();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => RenshuuQuizScreen(
                            chapter: chapter,
                            renshuuList: chapterData,
                          ),
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
                          Icon(Icons.history_edu_rounded, size: 28.0, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(chapter, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                                const SizedBox(height: 4.0),
                                Text('${chapterData.length} pola kalimat', style: TextStyle(fontSize: 14.0, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                              ],
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