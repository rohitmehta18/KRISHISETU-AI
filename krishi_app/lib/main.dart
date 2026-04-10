import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const KrishiApp());
}

class KrishiApp extends StatefulWidget {
  const KrishiApp({super.key});

  static _KrishiAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_KrishiAppState>()!;

  @override
  State<KrishiApp> createState() => _KrishiAppState();
}

class _KrishiAppState extends State<KrishiApp> {
  bool isDark = true;

  void toggleTheme() => setState(() => isDark = !isDark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Krishi App',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      darkTheme: _buildDarkTheme(),
      theme: _buildLightTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF060E08),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF39FF14),
        secondary: Color(0xFF00C853),
        surface: Color(0xFF0D1F14),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0D1F14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: const Color(0xFF39FF14).withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: const Color(0xFF39FF14).withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF39FF14), width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFF7CB98A)),
        prefixIconColor: const Color(0xFF39FF14),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF0F7F1),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1B7A3E),
        secondary: Color(0xFF2ECC71),
        surface: Color(0xFFFFFFFF),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: const Color(0xFF1B7A3E).withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: const Color(0xFF1B7A3E).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1B7A3E), width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFF4A8C5C)),
        prefixIconColor: const Color(0xFF1B7A3E),
      ),
    );
  }
}
