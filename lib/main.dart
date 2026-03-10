import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
final ValueNotifier<Color> colorNotifier = ValueNotifier(Colors.teal);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  
  final isDarkStr = prefs.getString('theme_mode');
  if (isDarkStr == 'dark') {
    themeNotifier.value = ThemeMode.dark;
  } else if (isDarkStr == 'light') {
    themeNotifier.value = ThemeMode.light;
  }

  final colorValue = prefs.getInt('theme_color');
  if (colorValue != null) {
    colorNotifier.value = Color(colorValue);
  }

  runApp(const NayoriApp());
}

class NayoriApp extends StatelessWidget {
  const NayoriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeNotifier, colorNotifier]),
      builder: (context, _) {
        final currentMode = themeNotifier.value;
        final currentColor = colorNotifier.value;

        return MaterialApp(
          title: 'Nayori',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: currentColor,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              scrolledUnderElevation: 2,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: currentColor,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
            ),
          ),
          themeMode: currentMode, 
          home: const MainScreen(),
        );
      },
    );
  }
}