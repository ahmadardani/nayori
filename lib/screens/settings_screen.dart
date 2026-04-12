import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  final List<Color> availableColors = const [
    Colors.teal,
    Colors.blue,
    Colors.deepPurple,
    Colors.pink,
    Colors.orange,
    Colors.green,
  ];

  Future<void> _saveThemeMode(bool isDark) async {
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', isDark ? 'dark' : 'light');
  }

  Future<void> _saveColor(Color color) async {
    colorNotifier.value = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_color', color.value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22.0, letterSpacing: -0.5)),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 20.0, 
          right: 20.0, 
          top: 16.0, 
          bottom: MediaQuery.of(context).padding.bottom + 40.0
        ),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (_, ThemeMode currentMode, __) {
                bool isDarkMode = currentMode == ThemeMode.dark || 
                             (currentMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
                
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, 
                      color: Theme.of(context).colorScheme.onPrimaryContainer
                    ),
                  ),
                  title: const Text('Dark Mode', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                  subtitle: Text('Enable dark theme', style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  value: isDarkMode,
                  onChanged: (value) => _saveThemeMode(value),
                );
              },
            ),
          ),
          const SizedBox(height: 12.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(Icons.color_lens_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Theme Color', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                          const SizedBox(height: 2.0),
                          Text('Choose your accent color', style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  height: 48.0,
                  child: ValueListenableBuilder<Color>(
                    valueListenable: colorNotifier,
                    builder: (_, Color currentColor, __) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: availableColors.length,
                        itemBuilder: (context, index) {
                          final color = availableColors[index];
                          final isSelected = currentColor.value == color.value;
                          return GestureDetector(
                            onTap: () => _saveColor(color),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12.0),
                              width: 48.0,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3.0) : null,
                              ),
                              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24.0) : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  icon: Icon(Icons.menu_book_rounded, size: 48.0, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Nayori', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Text(
                    'A minimalist and open-source Japanese learning application.\n\nBuilt with Flutter.',
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              );
            },
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('About Nayori', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                        const SizedBox(height: 2.0),
                        Text('Version 1.0.0', style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 20.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}