import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/kanji_model.dart';
import 'search_screen.dart';
import 'all_kanji_screen.dart';
import 'all_words_menu_screen.dart'; 
import 'renshuu_menu_screen.dart';
import 'grammar_n5_menu_screen.dart';
import 'adjective_list_screen.dart';
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
      final String jsonString = await rootBundle.loadString('assets/kanji/data.json');
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
        title: const Text('Nayori', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search',
            onPressed: () => Navigator.push(
              context, 
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => SearchScreen(allData: _allData),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16.0, 
              right: 16.0, 
              top: 24.0, 
              bottom: MediaQuery.of(context).padding.bottom + 40.0
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle('Grammar', Icons.translate_rounded),
                _buildMenuCard(
                  context: context,
                  title: 'Renshuu A',
                  subtitle: 'Latihan pola kalimat per bab',
                  icon: Icons.history_edu_rounded,
                  onTap: () => _navigateTo(context, const RenshuuMenuScreen()),
                ),
                _buildMenuCard(
                  context: context,
                  title: 'Grammar Points N5',
                  subtitle: 'Penjelasan tata bahasa & kuis',
                  icon: Icons.auto_stories_rounded,
                  onTap: () => _navigateTo(context, const GrammarN5MenuScreen()),
                ),
                const SizedBox(height: 32),

                _buildSectionTitle('Adjectives', Icons.style_rounded),
                _buildExpandableAdjectiveCard(context, 'N5 Adjectives', 'I Adjective', 'Na Adjective'),
                _buildExpandableAdjectiveCard(context, 'N4 Adjectives', 'I Adjective', 'Na Adjective'),
                const SizedBox(height: 32),

                _buildSectionTitle('Verbs', Icons.transform_rounded),
                _buildMenuCard(
                  context: context,
                  title: 'N5 Verbs',
                  subtitle: 'Pelajari kata kerja N5 (Part 1 & 2)',
                  icon: Icons.sync_alt_rounded,
                  onTap: () => _navigateTo(context, const VerbMenuScreen(level: 'N5')),
                ),
                _buildMenuCard(
                  context: context,
                  title: 'N4 Verbs',
                  subtitle: 'Pelajari kata kerja N4 (Part 1 & 2)',
                  icon: Icons.sync_alt_rounded,
                  onTap: () => _navigateTo(context, const VerbMenuScreen(level: 'N4')),
                ),
                const SizedBox(height: 32),

                _buildSectionTitle('Kanji & Vocabulary', Icons.font_download_rounded),
                _buildMenuCard(
                  context: context,
                  title: 'All Kanji',
                  subtitle: 'Lihat daftar lengkap kanji',
                  icon: Icons.grid_view_rounded,
                  onTap: () => _navigateTo(context, AllKanjiScreen(allData: _allData, uniqueKanjis: _uniqueKanjis)),
                ),
                _buildMenuCard(
                  context: context,
                  title: 'All Words',
                  subtitle: 'Pelajari kosakata hari per hari',
                  icon: Icons.menu_book_rounded,
                  onTap: () => _navigateTo(context, AllWordsMenuScreen(allData: _allData, isDojoMode: false)),
                ),
                _buildMenuCard(
                  context: context,
                  title: 'Dojo',
                  subtitle: 'Latihan dan uji ingatanmu',
                  icon: Icons.fitness_center_rounded,
                  onTap: () => _navigateTo(context, AllWordsMenuScreen(allData: _allData, isDojoMode: true)),
                ),
              ],
            ),
          ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context, 
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20.0, 
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context, 
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required VoidCallback onTap
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(icon, size: 24.0, color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600)),
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
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableAdjectiveCard(BuildContext context, String title, String iAdjLabel, String naAdjLabel) {
    final String levelPrefix = title.contains('N5') ? 'N5' : 'N4';

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        leading: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(Icons.category_rounded, size: 24.0, color: Theme.of(context).colorScheme.onTertiaryContainer),
        ),
        title: Text(title, style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600)),
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 32.0),
            title: Text(iAdjLabel, style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.arrow_forward_rounded, size: 20),
            onTap: () => _navigateTo(context, AdjectiveListScreen(
              category: 'い Adjective $levelPrefix', 
              title: '$levelPrefix - I Adjective',
            )),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 32.0),
            title: Text(naAdjLabel, style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.arrow_forward_rounded, size: 20),
            onTap: () => _navigateTo(context, AdjectiveListScreen(
              category: 'な Adjective $levelPrefix', 
              title: '$levelPrefix - Na Adjective',
            )),
          ),
        ],
      ),
    );
  }
}