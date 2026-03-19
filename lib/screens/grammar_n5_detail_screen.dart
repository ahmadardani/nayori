import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart'; 
import '../models/grammar_n5_model.dart';
import 'grammar_n5_quiz_screen.dart';

class GrammarN5DetailScreen extends StatefulWidget {
  final GrammarN5Data data;

  const GrammarN5DetailScreen({super.key, required this.data});

  @override
  State<GrammarN5DetailScreen> createState() => _GrammarN5DetailScreenState();
}

class _GrammarN5DetailScreenState extends State<GrammarN5DetailScreen> {
  String _markdownContent = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMarkdown();
  }

  Future<void> _loadMarkdown() async {
    try {
      final String content = await rootBundle.loadString(widget.data.explanationFile);
      setState(() {
        _markdownContent = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _markdownContent = 'Failed to load explanation.\n$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24.0, 
                right: 24.0, 
                top: 24.0, 
                bottom: MediaQuery.of(context).padding.bottom + 100.0
              ),
              child: MarkdownBody(
                data: _markdownContent,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(fontSize: 16.0, height: 1.6, color: Theme.of(context).colorScheme.onSurface),
                  h1: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  h3: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600),
                  h3Padding: const EdgeInsets.only(top: 16.0), 
                  listBullet: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => GrammarN5QuizScreen(data: widget.data),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Start Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}