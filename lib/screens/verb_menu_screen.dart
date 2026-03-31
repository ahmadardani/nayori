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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('$level Verbs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Part 1'),
              Tab(text: 'Part 2'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0, left: 4.0),
                  child: Text(
                    'Pilih Bentuk Kata Kerja',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
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
              padding: const EdgeInsets.all(16.0),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0, left: 4.0),
                  child: Text(
                    'Pilih Bentuk Kata Kerja',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
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

  Widget _buildFormChoiceCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28.0, color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle, 
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.3),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18.0, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}