import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/kanji_model.dart';
import 'library_screen.dart';
import 'practice_screen.dart'; 
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> screens = [
      LibraryScreen(allData: _allData, uniqueKanjis: _uniqueKanjis),
      PracticeScreen(allData: _allData), 
      const SettingsScreen(),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: borderColor, width: 1.0)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
          elevation: 0,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant), 
              selectedIcon: Icon(Icons.auto_stories_rounded, color: Theme.of(context).colorScheme.primary), 
              label: 'Library'
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant), 
              selectedIcon: Icon(Icons.fitness_center_rounded, color: Theme.of(context).colorScheme.primary), 
              label: 'Practice' 
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant), 
              selectedIcon: Icon(Icons.settings_rounded, color: Theme.of(context).colorScheme.primary), 
              label: 'Settings'
            ),
          ],
        ),
      ),
    );
  }
}