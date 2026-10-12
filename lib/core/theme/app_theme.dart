import 'package:flutter/material.dart';

abstract final class AppColors {
  static const midnight = Color(0xFF071323);
  static const navy = Color(0xFF14253F);
  static const ocean = Color(0xFF183D52);
  static const teal = Color(0xFF35B7A5);
  static const gold = Color(0xFFF0B94F);
  static const ivory = Color(0xFFF6F4ED);
  static const white = Color(0xFFFFFFFF);
  static const muted = Color(0xFF91A1BB);
  static const darkMuted = Color(0xFF667896);
  static const dividerDark = Color(0xFF26364D);
  static const dividerLight = Color(0xFFE6E6E3);
}

abstract final class AppTheme {
  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: brightness,
      primary: AppColors.gold,
      secondary: AppColors.teal,
      surface: isDark ? AppColors.navy : AppColors.white,
      error: const Color(0xFFE57373),
    );
    final textColor = isDark ? AppColors.white : AppColors.navy;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.midnight : AppColors.ivory,
      fontFamily: 'NotoNaskhArabic',
      textTheme: Typography.material2021().black.apply(
        bodyColor: textColor,
        displayColor: textColor,
        fontFamily: 'NotoNaskhArabic',
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.midnight : AppColors.ivory,
        foregroundColor: textColor,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.navy : AppColors.white,
        elevation: isDark ? 0 : 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.midnight : AppColors.white,
        indicatorColor: isDark
            ? const Color(0xFF1D2838)
            : const Color(0xFFFFF8EC),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontFamily: 'NotoNaskhArabic',
            fontSize: 12,
            color: states.contains(WidgetState.selected)
                ? AppColors.gold
                : (isDark ? AppColors.muted : AppColors.darkMuted),
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.navy : AppColors.white,
        contentTextStyle: TextStyle(color: textColor),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.midnight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.white
              : AppColors.muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.teal
              : (isDark ? AppColors.dividerDark : AppColors.dividerLight);
        }),
      ),
    );
  }
}
