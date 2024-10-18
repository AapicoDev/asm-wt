import 'package:flutter/material.dart';

// Instantiate new  theme data
final ThemeData asthaTutorialTheme = _asthaTutorialTheme();

//Define Base theme for app
ThemeData _asthaTutorialTheme() {
// We'll just overwrite whatever's already there using ThemeData.light()
  final ThemeData base = ThemeData.light();

  // Make changes to light() theme
  return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      colorScheme: base.colorScheme.copyWith(
        primary: const Color.fromRGBO(18, 33, 61, 1),
        onPrimary: Colors.white,
        secondary: const Color.fromRGBO(18, 50, 155, 1),
        // onSecondary: const Color.fromRGBO(85, 105, 187, 1),
        onSecondary: const Color.fromRGBO(255, 204, 0, 1),
        onSurface: const Color.fromRGBO(17, 159, 154, 1),

        background: Colors.green,
        onBackground: Colors.red,
        tertiary: Color.fromRGBO(245, 245, 245, 1),
        onTertiary: Color.fromRGBO(166, 167, 170, 1),
      ),
      textTheme: _asthaTutorialTextTheme(base.textTheme),
      elevatedButtonTheme: _elevatedButtonTheme(base.elevatedButtonTheme),
      textButtonTheme: _textButtonThem(base.textButtonTheme),
      inputDecorationTheme: _inputDecorationTheme(base.inputDecorationTheme));
}

// Outside of _asthaTutorialTheme function  create another function

TextTheme _asthaTutorialTextTheme(TextTheme base) => base.copyWith(
// This'll be our appbars title
      titleLarge: base.titleLarge!.copyWith(
          fontFamily: "Kanit Heavy",
          fontSize: 20,
          color: Color.fromARGB(255, 0, 0, 0)),
// for widgets heading/title
      headlineLarge: base.headlineLarge!.copyWith(
        fontFamily: "Kanit",
        fontSize: 18,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
// for sub-widgets heading/title
      headlineMedium: base.headlineMedium!.copyWith(
        fontFamily: "Kanit",
        fontSize: 16,
        color: Colors.black,
      ),
      headlineSmall: base.headlineSmall!.copyWith(
        fontFamily: "Kanit",
        fontSize: 14,
        color: Colors.black,
      ),
// for widgets contents/paragraph
      bodyMedium: base.bodyMedium!.copyWith(
          fontFamily: "Kanit Light", fontSize: 14, color: Colors.black),
// for sub-widgets contents/paragraph
      bodySmall: base.bodySmall!.copyWith(
          fontFamily: "Kanit Light", fontSize: 11, color: Colors.black),
    );

ElevatedButtonThemeData _elevatedButtonTheme(ElevatedButtonThemeData base) =>
    ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          const Color.fromRGBO(85, 105, 187, 1),
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
    );

TextButtonThemeData _textButtonThem(TextButtonThemeData base) =>
    TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.grey),
      ),
    );

InputDecorationTheme _inputDecorationTheme(InputDecorationTheme base) =>
    const InputDecorationTheme(
// Label color for the input widget
      labelStyle: TextStyle(color: Colors.black),
// Define border of input form while focused on
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: 1.0,
          color: Colors.black,
          style: BorderStyle.solid,
        ),
      ),
    );
