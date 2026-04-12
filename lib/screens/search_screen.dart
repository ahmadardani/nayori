import 'package:flutter/material.dart';
import '../models/kanji_model.dart';
import 'search_result_screen.dart'; 

class SearchScreen extends StatefulWidget {
  final List<KanjiData> allData;

  const SearchScreen({super.key, required this.allData});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            SearchResultScreen(allData: widget.allData, query: query),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: const Text('Search', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0, letterSpacing: -0.5)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Align(
          alignment: const Alignment(0, -0.4), 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.translate_rounded, 
                size: 80, 
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5)
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _performSearch(), 
                decoration: InputDecoration(
                  hintText: 'Enter a word or kanji...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: borderColor, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: borderColor, width: 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    elevation: 0,
                  ),
                  child: const Text('Search', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}