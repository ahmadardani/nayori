import 'package:flutter/material.dart';
import '../models/kanji_model.dart';
import 'kanji_detail_screen.dart';

class SearchResultScreen extends StatefulWidget {
  final List<KanjiData> allData;
  final String query;

  const SearchResultScreen({super.key, required this.allData, required this.query});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  List<KanjiData> _filteredData = [];

  @override
  void initState() {
    super.initState();
    _filterData();
  }

  void _filterData() {
    final String trimmedQuery = widget.query.toLowerCase();
    
    _filteredData = widget.allData
        .where((item) => item.exampleLower.contains(trimmedQuery) || item.kanji.contains(trimmedQuery))
        .take(100) 
        .toList();
  }

  void _showReadMeaning(BuildContext context, KanjiData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); 
                        
                        final kanjiSentences = widget.allData.where((k) => k.kanji == data.kanji).toList();
                        
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => KanjiDetailScreen(kanji: data.kanji, dataList: kanjiSentences),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1.0),
                        ),
                        child: Text(
                          data.kanji, 
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            color: Theme.of(context).colorScheme.onSecondaryContainer
                          )
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: Text('Kanji Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3))),
                  ],
                ),
                const SizedBox(height: 20),
                Text(data.example, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(height: 32),
                Text('Reading & Meaning', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(data.readMeaning, style: const TextStyle(fontSize: 16, height: 1.5)),
              ],
            ),
          ),
        );
      },
    );
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
        title: Text(
          'Search Result for "${widget.query}"', 
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18.0, letterSpacing: -0.5)
        ),
      ),
      body: _filteredData.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('No results found.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.only(
                top: 16.0, left: 20.0, right: 20.0,
                bottom: MediaQuery.of(context).padding.bottom + 80.0, 
              ),
              itemCount: _filteredData.length,
              itemBuilder: (context, index) {
                final item = _filteredData[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: borderColor, width: 1.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    title: Text(item.example, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('Kanji: ${item.kanji}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    ),
                    trailing: const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.grey),
                    onTap: () {
                      FocusScope.of(context).unfocus(); 
                      _showReadMeaning(context, item);
                    },
                  ),
                );
              },
            ),
    );
  }
}