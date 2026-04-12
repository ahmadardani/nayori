import 'package:flutter/material.dart';
import 'all_verbs_screen.dart';

class VerbMenuScreen extends StatelessWidget {
  final String level; 

  const VerbMenuScreen({super.key, required this.level});

  void _navigateToVerbList(BuildContext context, String title, List<String> paths) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AllVerbsScreen(
          title: title,
          jsonPaths: paths,
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
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: bgColor,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          title: Text(
            '$level Verbs', 
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0, letterSpacing: -0.5)
          ),
          bottom: TabBar(
            indicatorWeight: 3.0,
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'Part 1'),
              Tab(text: 'Part 2'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              children: [
                _buildSectionLabel('Pilih Bentuk Kata Kerja', isDark),
                _buildFormChoiceCard(
                  context,
                  title: 'Plain Form (Biasa)',
                  subtitle: 'Bentuk Kasual (Kamus, Nai, Ta, Nakatta, Te)',
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: () => _navigateToVerbList(
                    context, 
                    '$level Verbs - Part 1 (Plain)', 
                    ['assets/$level-verbs/${level}_Verbs_C1.json'] 
                  ),
                ),
                _buildFormChoiceCard(
                  context,
                  title: 'Polite Form (Sopan)',
                  subtitle: 'Bentuk Formal (Masu, Masen, Mashita)',
                  icon: Icons.record_voice_over_rounded,
                  onTap: () => _navigateToVerbList(
                    context, 
                    '$level Verbs - Part 1 (Polite)', 
                    ['assets/$level-verbs/${level}_Verbs_P1.json']
                  ),
                ),
              ],
            ),

            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              children: [
                _buildSectionLabel('Pilih Bentuk Lanjutan', isDark),
                _buildFormChoiceCard(
                  context,
                  title: 'Plain Form (Biasa)',
                  subtitle: 'Bentuk Kasual Lanjutan (Potential, Volitional, dll)',
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: () => _navigateToVerbList(
                    context, 
                    '$level Verbs - Part 2 (Plain)', 
                    ['assets/$level-verbs/${level}_Verbs_C2.json']
                  ),
                ),
                _buildFormChoiceCard(
                  context,
                  title: 'Polite Form (Sopan)',
                  subtitle: 'Bentuk Formal Lanjutan',
                  icon: Icons.record_voice_over_rounded,
                  onTap: () => _navigateToVerbList(
                    context, 
                    '$level Verbs - Part 2 (Polite)', 
                    ['assets/$level-verbs/${level}_Verbs_P2.json']
                  ),
                ),
              ],
            ),
          ],
        ),
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

  Widget _buildFormChoiceCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
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
                      style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 14.0),
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