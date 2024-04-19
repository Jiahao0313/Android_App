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
          backgroundColor: MaterialStatePropertyAll(Colors.white),
          foregroundColor: MaterialStatePropertyAll(Color(0xFF018301)),
          side: MaterialStatePropertyAll(
            BorderSide(color: Colors.green),
          )),
    ),
    appBarTheme: AppBarTheme(),
    tabBarTheme: TabBarTheme(
      labelColor: Color(0xFF018301),
      unselectedLabelColor: Colors.black,
      indicatorColor: Color(0xFF018301),
      indicatorSize: TabBarIndicatorSize.tab,
      labelPadding: EdgeInsets.symmetric(vertical: 8),
    ),
    listTileTheme: ListTileThemeData(iconColor: Color(0xFF018301)),
    cardTheme: CardTheme(surfaceTintColor: Colors.white, elevation: 10),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.robotoCondensed(
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.robotoCondensed(
          fontWeight: FontWeight.bold, color: Colors.black),
      displaySmall: GoogleFonts.robotoCondensed(
          fontWeight: FontWeight.bold, color: Colors.black),
      headlineLarge: GoogleFonts.robotoCondensed(
          fontWeight: FontWeight.bold, color: Color(0xFF018301)),
      headlineMedium: GoogleFonts.robotoCondensed(
          fontWeight: FontWeight.bold, color: Colors.black),
      headlineSmall: GoogleFonts.robotoCondensed(
          fontWeight: FontWeight.bold, color: Colors.black),
      titleLarge: GoogleFonts.robotoCondensed(
          fontWeight: FontWeight.bold, color: Color(0xFF018301)),
      titleMedium: GoogleFonts.robotoCondensed(
          fontWeight: FontWeight.bold, color: Color(0xFF018301)),
      titleSmall: GoogleFonts.robotoCondensed(
          fontWeight: FontWeight.bold, color: Colors.black),
      bodyLarge: GoogleFonts.robotoCondensed(
          fontWeight: FontWeight.normal, color: Colors.black),
      bodyMedium: GoogleFonts.robotoCondensed(
          fontWeight: FontWeight.normal, color: Colors.black),
      bodySmall: GoogleFonts.robotoCondensed(
          fontWeight: FontWeight.normal, color: Colors.black),
      labelLarge: GoogleFonts.robotoCondensed(
          fontWeight: FontWeight.normal, color: Colors.black),
      labelMedium: GoogleFonts.robotoCondensed(
          fontWeight: FontWeight.normal, color: Colors.black),
      labelSmall: GoogleFonts.robotoCondensed(
          fontWeight: FontWeight.normal, color: Colors.black),
    ),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith();
}
