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
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (_, ThemeMode currentMode, __) {
                bool isDark = currentMode == ThemeMode.dark || 
                             (currentMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
                
                return SwitchListTile(
                  title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Enable dark theme for the application'),
                  secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                  value: isDark,
                  onChanged: (value) => _saveThemeMode(value),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('Theme Color', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                  SizedBox(
                    height: 50,
                    child: ValueListenableBuilder<Color>(
                      valueListenable: colorNotifier,
                      builder: (_, Color currentColor, __) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          itemCount: availableColors.length,
                          itemBuilder: (context, index) {
                            final color = availableColors[index];
                            final isSelected = currentColor.value == color.value;
                            return GestureDetector(
                              onTap: () => _saveColor(color),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                                width: 44,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: isSelected ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3) : null,
                                ),
                                child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
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
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('About Nayori', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Version 1.0.0'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    icon: Icon(Icons.menu_book_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
                    title: const Text('Nayori'),
                    content: const Text(
                      'A minimalist and open-source Japanese learning application.\n\nBuilt with Flutter.',
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}