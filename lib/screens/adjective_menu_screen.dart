import 'package:flutter/material.dart';
import 'adjective_list_screen.dart';

class AdjectiveMenuScreen extends StatelessWidget {
  final String level;

  const AdjectiveMenuScreen({super.key, required this.level});

  void _navigateTo(BuildContext context, String category, String title) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AdjectiveListScreen(
          category: category,
          title: title,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$level Adjectives', style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 16.0, right: 16.0, top: 16.0, 
          bottom: MediaQuery.of(context).padding.bottom + 16.0,
        ),
        children: [
          _buildChoiceCard(
            context: context,
            title: 'い (i) Adjective',
            subtitle: 'Kata sifat berakhiran "i"',
            icon: Icons.format_italic_rounded,
            onTap: () => _navigateTo(context, 'い Adjective $level', '$level - I Adjective'),
          ),
          _buildChoiceCard(
            context: context,
            title: 'な (na) Adjective',
            subtitle: 'Kata sifat berakhiran "na"',
            icon: Icons.title_rounded,
            onTap: () => _navigateTo(context, 'な adjective $level', '$level - Na Adjective'),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceCard({
    required BuildContext context, 
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required VoidCallback onTap
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12.0),
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
                    Text(title, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2.0),
                    Text(
                      subtitle, 
                      style: TextStyle(fontSize: 13.0, color: Theme.of(context).colorScheme.onSurfaceVariant)
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16.0, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}