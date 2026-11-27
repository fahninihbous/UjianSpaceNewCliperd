import 'package:flutter/material.dart';

class SpaceTheme {
  // Warna dasar Dark Mode pekat seperti referensi
  static const Color spaceBg = Color(0xFF0B0B0C);
  static const Color surfaceCard = Color(0xFF1A1A1D);
  static const Color surfaceElevated = Color(0xFF26262A);
  static const Color borderSubtle = Color(0xFF2E2E32);
  
  // Warna Aksen & Teks
  static const Color accentAmber = Color(0xFFFDF5D2); // Krem pastel utama
  static const Color accentCyan = Color(0xFF38BDF8);
  static const Color textMuted = Color(0xFF8E8E93);
  static const Color cardTextDark = Color(0xFF141416); // Teks gelap di atas kartu pastel

  // Palet warna kartu pastel (seperti di referensi gambar)
  static const List<Color> pastelCards = [
    Color(0xFFFDF5D2), // Krem / Kuning Muda
    Color(0xFFFBE4E6), // Merah Muda Pastel
    Color(0xFFDDF1FA), // Biru Muda Pastel
    Color(0xFFE3F6E8), // Hijau Mint Pastel
  ];

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: spaceBg,
      colorScheme: base.colorScheme.copyWith(
        primary: accentAmber,
        onPrimary: cardTextDark,
        secondary: accentCyan,
        surface: surfaceCard,
        onSurface: Colors.white,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: spaceBg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCard,
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: accentAmber, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cardTextDark,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}