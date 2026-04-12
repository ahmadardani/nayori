import 'package:flutter/material.dart';
import '../models/kanji_model.dart';
import 'search_screen.dart';
import 'all_kanji_screen.dart';
import 'grammar_n5_menu_screen.dart';

class LibraryScreen extends StatelessWidget {
  final List<KanjiData> allData;
  final List<String> uniqueKanjis;

  const LibraryScreen({super.key, required this.allData, required this.uniqueKanjis});

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
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: const Text('Nayori', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22.0, letterSpacing: -0.5)),
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
              'Library',
              style: TextStyle(
                fontSize: 28.0, fontWeight: FontWeight.w900,
                letterSpacing: -0.5, color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Pilih modul untuk mulai membaca dan menghafal materi.',
              style: TextStyle(fontSize: 15.0, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
            const SizedBox(height: 24.0),

            _buildSearchCard(
              context: context, 
              title: 'Cari Materi', 
              subtitle: 'Pencarian cepat kosakata atau kanji',
              icon: Icons.search_rounded, 
              cardColor: cardColor, 
              borderColor: borderColor,
              onTap: () => _navigateTo(context, SearchScreen(allData: allData)),
            ),
            const SizedBox(height: 24.0),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 1.1,
              children: [
                _buildFSOModuleCard(
                  context: context, title: 'Grammar N5', icon: Icons.translate_rounded,
                  cardColor: cardColor, borderColor: borderColor,
                  onTap: () => _navigateTo(context, const GrammarN5MenuScreen()),
                ),
                _buildFSOModuleCard(
                  context: context, title: 'Kanji & Words', icon: Icons.font_download_rounded,
                  cardColor: cardColor, borderColor: borderColor,
                  onTap: () => _navigateTo(context, AllKanjiScreen(allData: allData, uniqueKanjis: uniqueKanjis)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard({required BuildContext context, required String title, required String subtitle, required IconData icon, required Color cardColor, required Color borderColor, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: borderColor, width: 1.0),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4.0, offset: const Offset(0, 2))
          ]
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 4.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(7.0)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(icon, size: 36.0, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                        const SizedBox(height: 4.0),
                        Text(subtitle, style: TextStyle(fontSize: 14.0, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: Colors.grey.shade400, size: 20.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFSOModuleCard({required BuildContext context, required String title, required IconData icon, required Color cardColor, required Color borderColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: borderColor, width: 1.0),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4.0, offset: const Offset(0, 2))
          ]
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 4.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(7.0)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32.0, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16.0),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}