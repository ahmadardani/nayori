import 'package:flutter/material.dart';
import 'verb_menu_screen.dart';
import 'verb_pair_quiz_screen.dart';

class VerbLevelMenuScreen extends StatelessWidget {
  const VerbLevelMenuScreen({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
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
        title: const Text('Verbs Practice', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0, letterSpacing: -0.5)),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 20.0, right: 20.0, top: 16.0,
          bottom: MediaQuery.of(context).padding.bottom + 16.0,
        ),
        children: [
          _buildSectionLabel('Conjugation Drills', isDark),
          _buildChoiceCard(
            context: context,
            title: 'Level N5 (All Verbs)',
            subtitle: 'Latihan konjugasi kata kerja N5',
            icon: Icons.looks_5_rounded,
            onTap: () => _navigateTo(context, const VerbMenuScreen(level: 'N5')),
          ),
          _buildChoiceCard(
            context: context,
            title: 'Level N4 (All Verbs)',
            subtitle: 'Latihan konjugasi kata kerja N4',
            icon: Icons.looks_4_rounded,
            onTap: () => _navigateTo(context, const VerbMenuScreen(level: 'N4')),
          ),
          const SizedBox(height: 16.0),
          _buildSectionLabel('Jidoushi & Tadoushi Pairs', isDark),
          _buildChoiceCard(
            context: context,
            title: 'Level N5 Pairs',
            subtitle: 'Tebak pasangan kata kerja N5',
            icon: Icons.compare_arrows_rounded,
            onTap: () => _navigateTo(context, const VerbPairQuizScreen(level: 'N5')),
          ),
          _buildChoiceCard(
            context: context,
            title: 'Level N4 Pairs',
            subtitle: 'Tebak pasangan kata kerja N4',
            icon: Icons.compare_arrows_rounded,
            onTap: () => _navigateTo(context, const VerbPairQuizScreen(level: 'N4')),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600
        ),
      ),
    );
  }

  Widget _buildChoiceCard({required BuildContext context, required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
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