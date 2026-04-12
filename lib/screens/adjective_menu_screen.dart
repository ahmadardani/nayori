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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Text(
          '$level Adjectives', 
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0, letterSpacing: -0.5)
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 20.0, right: 20.0, top: 16.0, 
          bottom: MediaQuery.of(context).padding.bottom + 16.0,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Pilih Kategori',
              style: TextStyle(
                fontSize: 16.0, 
                fontWeight: FontWeight.w700, 
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600
              ),
            ),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Row(
            children: [
              Icon(icon, size: 28.0, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle, 
                      style: TextStyle(fontSize: 14.0, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: Colors.grey.shade400, size: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}