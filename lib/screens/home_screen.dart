import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'all_kanji_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nayori', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSquareButton(
                context, 
                'Search', 
                Icons.search, 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()))
              ),
              const SizedBox(height: 24),
              _buildSquareButton(
                context, 
                'All Kanji', 
                Icons.grid_view, 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllKanjiScreen()))
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquareButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              title.toUpperCase(), 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)
            ),
          ],
        ),
      ),
    );
  }
}