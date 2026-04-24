import 'package:flutter/material.dart';
import '../models/kanji_model.dart';
import 'all_words_menu_screen.dart'; 
import 'renshuu_menu_screen.dart';
import 'compound_verb_menu_screen.dart';
import 'sentence_quiz_screen.dart';
import 'verb_menu_screen.dart';
import 'adjective_menu_screen.dart';

class PracticeScreen extends StatelessWidget {
  final List<KanjiData> allData;

  const PracticeScreen({super.key, required this.allData});

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
    final cardColor = Theme.of(context).colorScheme.surface;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        title: const Text('Practice', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22.0, letterSpacing: -0.5)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20.0, right: 20.0, top: 16.0, 
          bottom: MediaQuery.of(context).padding.bottom + 40.0
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Practice Arena',
              style: TextStyle(
                fontSize: 28.0, fontWeight: FontWeight.w900,
                letterSpacing: -0.5, color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Test your memory and skills with various quizzes.',
              style: TextStyle(fontSize: 15.0, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
            const SizedBox(height: 32.0),

            _buildFSOListCard(
              context: context,
              title: 'Vocab Practice',
              subtitle: 'Daily vocabulary memory test',
              icon: Icons.menu_book_rounded,
              cardColor: cardColor, borderColor: borderColor,
              onTap: () => _navigateTo(context, AllWordsMenuScreen(allData: allData, isPracticeMode: true)),
            ),
            _buildFSOListCard(
              context: context,
              title: 'Verbs Practice',
              subtitle: 'Verb conjugation drills',
              icon: Icons.transform_rounded,
              cardColor: cardColor, borderColor: borderColor,
              onTap: () => _showLevelPicker(context, 'Verbs', cardColor, borderColor),
            ),
            _buildFSOListCard(
              context: context,
              title: 'Adjectives Practice',
              subtitle: 'Adjective form change drills',
              icon: Icons.style_rounded,
              cardColor: cardColor, borderColor: borderColor,
              onTap: () => _showLevelPicker(context, 'Adjectives', cardColor, borderColor),
            ),
            _buildFSOListCard(
              context: context,
              title: 'Jidoushi & Tadoushi',
              subtitle: 'Sentence translation and particles practice',
              icon: Icons.compare_arrows_rounded,
              cardColor: cardColor, borderColor: borderColor,
              onTap: () => _navigateTo(context, const SentenceQuizScreen()),
            ),
            _buildFSOListCard(
              context: context,
              title: 'Compound Verbs',
              subtitle: 'Compound verb comprehension quiz',
              icon: Icons.extension_rounded,
              cardColor: cardColor, borderColor: borderColor,
              onTap: () => _navigateTo(context, const CompoundVerbMenuScreen()),
            ),
            _buildFSOListCard(
              context: context,
              title: 'Renshuu A',
              subtitle: 'Sentence pattern practice per chapter',
              icon: Icons.history_edu_rounded,
              cardColor: cardColor, borderColor: borderColor,
              onTap: () => _navigateTo(
                context, 
                const RenshuuMenuScreen(
                  title: 'Renshuu A', 
                  jsonAssetPath: 'assets/renshuu/n5_renshuu_a.json'
                )
              ),
            ),
            _buildFSOListCard(
              context: context,
              title: 'Renshuu B',
              subtitle: 'Sentence practice per chapter',
              icon: Icons.edit_note_rounded,
              cardColor: cardColor, borderColor: borderColor,
              onTap: () => _navigateTo(
                context, 
                const RenshuuMenuScreen(
                  title: 'Renshuu B', 
                  jsonAssetPath: 'assets/renshuu/n5_renshuu_b.json'
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFSOListCard({required BuildContext context, required String title, required String subtitle, required IconData icon, required Color cardColor, required Color borderColor, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: cardColor,
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
                    Text(subtitle, style: TextStyle(fontSize: 14.0, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
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

  void _showLevelPicker(BuildContext context, String type, Color cardColor, Color borderColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Select $type Level', style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                const SizedBox(height: 24.0),
                ListTile(
                  title: const Text('Level N5', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_rounded, size: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: borderColor, width: 1.0),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateTo(context, type == 'Verbs' ? const VerbMenuScreen(level: 'N5') : const AdjectiveMenuScreen(level: 'N5'));
                  },
                ),
                const SizedBox(height: 12.0),
                ListTile(
                  title: const Text('Level N4', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_rounded, size: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: borderColor, width: 1.0),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateTo(context, type == 'Verbs' ? const VerbMenuScreen(level: 'N4') : const AdjectiveMenuScreen(level: 'N4'));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}