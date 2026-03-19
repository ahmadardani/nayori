import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/kanji_model.dart';
import 'search_screen.dart';
import 'all_kanji_screen.dart';
import 'all_words_menu_screen.dart'; 
import 'grammar_menu_screen.dart'; 
import 'grammar_n5_menu_screen.dart';
import 'all_verbs_screen.dart'; 
import 'verb_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<KanjiData> _allData = [];
  List<String> _uniqueKanjis = [];

  @override
  void initState() {
    super.initState();
    _loadDataOnce();
  }

  Future<void> _loadDataOnce() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data.json');
      final KanjiParsedResult result = await compute(parseKanjiDataInBackground, jsonString);
      
      setState(() {
        _allData = result.allData;
        _uniqueKanjis = result.uniqueKanjis;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('Nayori', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView( 
        padding: EdgeInsets.only(
          left: 16.0, 
          right: 16.0, 
          top: 16.0, 
          bottom: MediaQuery.of(context).padding.bottom + 32.0
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8.0), 
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              _buildMenuCard(
                context, 
                'Search', 
                'Find specific kanji or vocabulary',
                Icons.search_rounded, 
                () => Navigator.push(
                  context, 
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => SearchScreen(allData: _allData),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                )
              ),
              const SizedBox(height: 12.0),
              _buildMenuCard(
                context, 
                'All Kanji', 
                'View the complete list of kanji',
                Icons.grid_view_rounded, 
                () => Navigator.push(
                  context, 
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => AllKanjiScreen(allData: _allData, uniqueKanjis: _uniqueKanjis),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                )
              ),
              const SizedBox(height: 32.0),
              const Text(
                'Vocabulary & Grammar', 
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12.0),
              _buildMenuCard(
                context, 
                'All Words', 
                'Learn vocabulary day by day',
                Icons.menu_book_rounded, 
                () => Navigator.push(
                  context, 
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => AllWordsMenuScreen(allData: _allData, isDojoMode: false),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                )
              ),
              const SizedBox(height: 12.0),
              _buildMenuCard(
                context, 
                'Dojo', 
                'Practice and test your memory',
                Icons.fitness_center_rounded, 
                () => Navigator.push(
                  context, 
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => AllWordsMenuScreen(allData: _allData, isDojoMode: true),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                )
              ),
              const SizedBox(height: 12.0),
              _buildMenuCard(
                context, 
                'Grammar', 
                'Sentence translation challenge',
                Icons.translate_rounded, 
                () => Navigator.push(
                  context, 
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const GrammarMenuScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                )
              ),
              const SizedBox(height: 12.0),
              _buildMenuCard(
                context, 
                'Grammar N5', 
                'Learn N5 grammar points & quiz',
                Icons.auto_stories_rounded, 
                () => Navigator.push(
                  context, 
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const GrammarN5MenuScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                )
              ),
              const SizedBox(height: 32.0),
              const Text(
                'Verbs', 
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12.0),
              _buildMenuCard(
                context, 
                'All Verbs', 
                'View all verb conjugations',
                Icons.view_list_rounded, 
                () => Navigator.push(
                  context, 
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const AllVerbsScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                )
              ),
              const SizedBox(height: 12.0),
              _buildMenuCard(
                context, 
                'Verb Conjugator', 
                'Practice verb conjugations',
                Icons.transform_rounded, 
                () => Navigator.push(
                  context, 
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const VerbMenuScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                )
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1.0, 
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, size: 26.0, color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2.0),
                    Text(
                      subtitle, 
                      style: TextStyle(
                        fontSize: 13.0, 
                        color: Theme.of(context).colorScheme.onSurfaceVariant
                      )
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}