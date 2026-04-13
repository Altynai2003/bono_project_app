import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const BonoApp());
}

class BonoApp extends StatelessWidget {
  const BonoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Тигүүчү Цех',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F6F9), // Дизайндагы боз фон
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A89DC), // Дизайндагы көк түс
          primary: const Color(0xFF4A89DC),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Заманбап шрифт катары калтырабыз
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A89DC),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          toolbarHeight: 60,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A89DC), width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF4A89DC),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
