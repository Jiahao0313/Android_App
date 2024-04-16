import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class CustomThemes {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: const Color(0xFF018301),
    canvasColor: Colors.white,
    navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        indicatorColor: const Color(0x77F77600),
        shadowColor: Colors.black,
        elevation: 16,
        overlayColor: const MaterialStatePropertyAll(Color(0xFFF77600)),
        labelTextStyle: MaterialStatePropertyAll(TextStyle(
            color: const Color(0xFF018301),
            fontWeight: FontWeight.w800,
            fontSize: 12,
            fontFamily: GoogleFonts.robotoCondensed().fontFamily)),
        iconTheme: const MaterialStatePropertyAll(IconThemeData(
            color: Color(0xFF018301),
            weight: 100,
            opticalSize: 20,
            grade: -25))),
    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle:
            MaterialStatePropertyAll(TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: MaterialStatePropertyAll(Color(0xFFF77600)),
        foregroundColor: MaterialStatePropertyAll(Colors.white),
      ),
    ),
    textButtonTheme: const TextButtonThemeData(
      style: ButtonStyle(
        textStyle:
            MaterialStatePropertyAll(TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: MaterialStatePropertyAll(Color(0xFFF77600)),
        foregroundColor: MaterialStatePropertyAll(Colors.white),
      ),
    ),
    outlinedButtonTheme: const OutlinedButtonThemeData(
      style: ButtonStyle(
        textStyle:
            MaterialStatePropertyAll(TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: MaterialStatePropertyAll(Color(0xFFF77600)),
        foregroundColor: MaterialStatePropertyAll(Colors.white),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.robotoCondensed(fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.robotoCondensed(fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.robotoCondensed(fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.robotoCondensed(fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.robotoCondensed(fontWeight: FontWeight.bold),
      headlineSmall: GoogleFonts.robotoCondensed(fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.robotoCondensed(fontWeight: FontWeight.bold),
      titleMedium: GoogleFonts.robotoCondensed(fontWeight: FontWeight.bold),
      titleSmall: GoogleFonts.robotoCondensed(fontWeight: FontWeight.bold),
      bodyLarge: GoogleFonts.robotoCondensed(fontWeight: FontWeight.normal),
      bodyMedium: GoogleFonts.robotoCondensed(fontWeight: FontWeight.normal),
      bodySmall: GoogleFonts.robotoCondensed(fontWeight: FontWeight.normal),
      labelLarge: GoogleFonts.robotoCondensed(fontWeight: FontWeight.normal),
      labelMedium: GoogleFonts.robotoCondensed(fontWeight: FontWeight.normal),
      labelSmall: GoogleFonts.robotoCondensed(fontWeight: FontWeight.normal),
    ),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith();
}
