import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Keuangan Pribadi',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),

      // 2. Tema Gelap (Dark Mode)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),

      // 3. Perintah untuk mendeteksi sistem HP
      themeMode: ThemeMode.system,
      home: HomeScreen(), // Aplikasi langsung membuka halaman utama
      debugShowCheckedModeBanner: false,
    );
  }
}
