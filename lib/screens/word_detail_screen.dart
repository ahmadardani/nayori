import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:url_launcher/url_launcher.dart'; 
import 'package:flutter_tts/flutter_tts.dart'; // Package suara
import '../models/word_model.dart';
import '../models/kanji_model.dart';
import 'search_result_screen.dart';

class WordDetailScreen extends StatefulWidget {
  final String kanji;
  final List<WordData> wordList;
  final List<KanjiData> allData; 

  const WordDetailScreen({super.key, required this.kanji, required this.wordList, required this.allData});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  // Menginisialisasi mesin suara dan mengaturnya ke bahasa Jepang
  Future<void> _initTts() async {
    await flutterTts.setLanguage("ja-JP");
    await flutterTts.setSpeechRate(0.45); // Sedikit diperlambat agar pelafalannya jelas
  }

  // Fungsi untuk mengucapkan teks
  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _launchGoogleImages(String query) async {
    final url = Uri.parse('https://www.google.com/search?tbm=isch&q=$query');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  void _showWordMeaning(BuildContext context, WordData data) {
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dibungkus Expanded agar tidak nabrak rentetan ikon di sebelahnya
                    Expanded(
                      child: Text(data.foundInCharacters, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // TOMBOL BARU: Suara (Text to Speech)
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded),
                          tooltip: 'Listen to pronunciation',
                          onPressed: () => _speak(data.foundInCharacters),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded),
                          tooltip: 'Copy',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: data.foundInCharacters));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${data.foundInCharacters} copied to clipboard'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              )
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.image_search_rounded), 
                          tooltip: 'See visual in Google Images',
                          onPressed: () => _launchGoogleImages(data.foundInCharacters),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search_rounded),
                          tooltip: 'Search this word',
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => SearchResultScreen(allData: widget.allData, query: data.foundInCharacters),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),
                Text(
                  'Reading', 
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 4),
                Text(data.foundInReading, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                Text(
                  'Meaning', 
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 4),
                Text(data.foundInMeaning, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    flutterTts.stop(); // Matikan suara kalau layar ditutup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Words with ${widget.kanji}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  widget.kanji, 
                  style: TextStyle(
                    fontSize: 80, 
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.onPrimaryContainer
                  )
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.wordList.length,
              itemBuilder: (context, index) {
                final item = widget.wordList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    title: Text(item.foundInCharacters, style: const TextStyle(fontSize: 18)),
                    trailing: const Icon(Icons.info_outline_rounded, color: Colors.grey),
                    onTap: () => _showWordMeaning(context, item),
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