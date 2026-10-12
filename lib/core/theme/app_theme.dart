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

  // Surface & Accent Tokens
  static const cardDark = Color(0xFF12223A);
  static const cardLight = Color(0xFFFFFFFF);
  static const goldGlow = Color(0x3DF0B94F);
  static const tealGlow = Color(0x3335B7A5);

  // Gradients
  static const prayerCardGradientDark = LinearGradient(
    colors: [Color(0xFF142742), Color(0xFF1A3961), Color(0xFF10253E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const prayerCardGradientLight = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF4F8FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const goldGradient = LinearGradient(
    colors: [Color(0xFFF7C967), Color(0xFFE6A734)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const tealGradient = LinearGradient(
    colors: [Color(0xFF39C9B5), Color(0xFF239789)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
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
      surface: isDark ? AppColors.cardDark : AppColors.cardLight,
      error: const Color(0xFFE57373),
    );
    final textColor = isDark ? AppColors.white : AppColors.navy;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.midnight : AppColors.ivory,
      fontFamily: 'NotoNaskhArabic',
      splashFactory: InkSparkle.splashFactory,
      textTheme: Typography.material2021().black.apply(
        bodyColor: textColor,
        displayColor: textColor,
        fontFamily: 'NotoNaskhArabic',
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.midnight : AppColors.ivory,
        foregroundColor: textColor,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.cardDark : AppColors.white,
        elevation: isDark ? 0 : 2,
        shadowColor: isDark ? Colors.black38 : const Color(0x12000000),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 1,
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
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.bold
                : FontWeight.normal,
            color: states.contains(WidgetState.selected)
                ? AppColors.gold
                : (isDark ? AppColors.muted : AppColors.darkMuted),
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: isDark ? AppColors.navy : AppColors.white,
        contentTextStyle: TextStyle(color: textColor, fontFamily: 'NotoNaskhArabic'),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.midnight,
          textStyle: const TextStyle(
            fontFamily: 'NotoNaskhArabic',
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
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
