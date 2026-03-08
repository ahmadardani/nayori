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
      _filteredData = _allData;
    });
  }

  void _filterSearch(String query) {
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
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black, width: 2)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kanji: ${data.kanji}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(data.example, style: const TextStyle(fontSize: 20)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(color: Colors.black54, thickness: 1),
              ),
              const Text('Meaning & Reading', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text(data.readMeaning, style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 40),
            ],
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
              decoration: const InputDecoration(
                labelText: 'Search kanji or vocabulary...',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Colors.black, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _filteredData.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black26),
              itemBuilder: (context, index) {
                final item = _filteredData[index];
                return InkWell(
                  onTap: () => _showReadMeaning(item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.example, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Kanji: ${item.kanji}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
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