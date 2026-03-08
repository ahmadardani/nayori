import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/kanji_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<KanjiData> _allData = [];
  List<KanjiData> _filteredData = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _allData = data.map((json) => KanjiData.fromJson(json)).toList();
    });
  }

  void _filterSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() => _filteredData = []);
      return;
    }
    
    setState(() {
      _filteredData = _allData
          .where((item) => item.example.toLowerCase().contains(query.toLowerCase()) || 
                           item.kanji.contains(query))
          .toList();
    });
  }

  void _showReadMeaning(KanjiData data) {
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
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSearch,
              decoration: InputDecoration(
                hintText: 'Enter a word or kanji...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterSearch('');
                      },
                    )
                  : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _searchController.text.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.manage_search_rounded, size: 80, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text('Start typing to search', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  )
                : _filteredData.isEmpty
                    ? const Center(child: Text('No results found.'))
                    : ListView.builder(
                        itemCount: _filteredData.length,
                        itemBuilder: (context, index) {
                          final item = _filteredData[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: ListTile(
                              title: Text(item.example, style: const TextStyle(fontSize: 16)),
                              subtitle: Text('Kanji: ${item.kanji}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                              onTap: () => _showReadMeaning(item),
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