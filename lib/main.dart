import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const NayoriApp());
}

class NayoriApp extends StatelessWidget {
  const NayoriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nayori',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.black,
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.0,
          centerTitle: false,
          shape: Border(bottom: BorderSide(color: Colors.black, width: 1.5)),
        ),
        
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          elevation: 8.0,
          type: BottomNavigationBarType.fixed,
        ),
        
        // Perbaikan ada di baris ini: CardTheme diubah menjadi CardThemeData
        cardTheme: const CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0.0,
          margin: EdgeInsets.zero,
        ),
        
        dialogTheme: const DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: Colors.white,
        ),
      ),
      home: const MainScreen(),
    );
  }
}