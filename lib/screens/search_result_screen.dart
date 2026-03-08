import 'package:flutter/material.dart';
import '../models/kanji_model.dart';

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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(data.kanji, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondaryContainer)),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: Text('Kanji Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                  ],
                ),
                const SizedBox(height: 20),
                Text(data.example, style: const TextStyle(fontSize: 20)),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Result for "${widget.query}"', 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
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
                top: 8, 
                bottom: MediaQuery.of(context).padding.bottom + 40, 
              ),
              itemCount: _filteredData.length,
              itemBuilder: (context, index) {
                final item = _filteredData[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    title: Text(item.example, style: const TextStyle(fontSize: 16)),
                    subtitle: Text('Kanji: ${item.kanji}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
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