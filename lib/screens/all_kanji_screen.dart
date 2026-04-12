import 'package:flutter/material.dart';
import '../models/kanji_model.dart';
import 'kanji_detail_screen.dart';

class AllKanjiScreen extends StatefulWidget {
  final List<KanjiData> allData;
  final List<String> uniqueKanjis;

  const AllKanjiScreen({super.key, required this.allData, required this.uniqueKanjis});

  @override
  State<AllKanjiScreen> createState() => _AllKanjiScreenState();
}

class _AllKanjiScreenState extends State<AllKanjiScreen> {
  List<String> _filteredKanjis = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredKanjis = widget.uniqueKanjis;
  }

  void _filterKanji(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredKanjis = widget.uniqueKanjis;
      });
      return;
    }
    setState(() {
      _filteredKanjis = widget.uniqueKanjis
          .where((k) => k.contains(query))
          .toList();
    });
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        title: const Text('All Kanji', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0, letterSpacing: -0.5))
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterKanji,
              decoration: InputDecoration(
                hintText: 'Search kanji...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterKanji('');
                        },
                      )
                    : null,
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
                contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 8.0,
                bottom: MediaQuery.of(context).padding.bottom + 80.0,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: _filteredKanjis.length,
              itemBuilder: (context, index) {
                final kanjiStr = _filteredKanjis[index];
                return InkWell(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    final kanjiSentences = widget.allData.where((k) => k.kanji == kanjiStr).toList();
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => KanjiDetailScreen(kanji: kanjiStr, dataList: kanjiSentences),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: borderColor, width: 1.0),
                    ),
                    child: Center(
                      child: Text(
                        kanjiStr,
                        style: TextStyle(fontSize: 32.0, color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}