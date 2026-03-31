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
    return Scaffold(
      appBar: AppBar(title: const Text('Renshuu A')),
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
                final chapterData = _allData.where((g) => g.chapter == chapter).toList();

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
                      child: Icon(Icons.history_edu_rounded, color: Theme.of(context).colorScheme.onSecondaryContainer),
                    ),
                    title: Text(chapter, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                    subtitle: Text('${chapterData.length} pola kalimat'),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
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
                  ),
                );
              },
            ),
    );
  }
}