import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // static ThemeData lightTheme(ColorScheme? lightColorScheme) {
  //   ColorScheme scheme = lightColorScheme ??
  //       ColorScheme.fromSeed(seedColor: const Color(0xFFF47C7C));
  //   return ThemeData(
  //     colorScheme: scheme,
  //     scaffoldBackgroundColor: scheme.background,
  //     appBarTheme: const AppBarTheme(elevation: 0.0),
  //   );
  // }

  static ThemeData theme(ColorScheme? darkColorScheme, Brightness brightness) {
    ColorScheme scheme = darkColorScheme ??
        ColorScheme.fromSeed(
          seedColor: const Color(0xFFF47C7C),
          brightness: brightness,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      chipTheme: ChipThemeData(
        selectedColor: scheme.primaryContainer,
      ),
      textTheme: GoogleFonts.sourceSansProTextTheme(
        brightness == Brightness.dark
            ? ThemeData.dark().textTheme
            : ThemeData.light().textTheme,
      ),
      tabBarTheme: TabBarTheme(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: scheme.primary,
            width: 2.0,
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        elevation: 10.0,
        backgroundColor: scheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        circularTrackColor: scheme.primary.withOpacity(0.4),
      ),
    );
  }
}
