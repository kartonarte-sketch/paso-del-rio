import 'package:flutter/material.dart';

class AppColors {
  static const forest = Color(0xFF1B4332);
  static const leaf = Color(0xFF2D6A4F);
  static const mint = Color(0xFFD8F3DC);
  static const gold = Color(0xFFD4A017);
  static const cream = Color(0xFFFAF6F0);
  static const ink = Color(0xFF2C2C2C);
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.forest,
      primary: AppColors.forest,
      secondary: AppColors.gold,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 1,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.forest,
        indicatorColor: AppColors.mint,
        selectedIconTheme: IconThemeData(color: AppColors.forest),
        unselectedIconTheme: IconThemeData(color: Colors.white70),
        selectedLabelTextStyle: TextStyle(color: Colors.white),
        unselectedLabelTextStyle: TextStyle(color: Colors.white70),
      ),
    );
  }
}
