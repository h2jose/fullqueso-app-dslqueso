import 'package:flutter/material.dart';


const colorList = <Color>[
  Color(0xFF0F065A),
  Color(0xFFD32F2F),
  Color(0xFFFFEBEE),
  Color(0xFFFFCDD2),
  Color(0xFFEF9A9A),
  Color(0xFFE57373),
  Color(0xFFEF5350),
  Colors.red,
  Color(0xFFE53935),
  Color(0xFFD32F2F),
  Color(0xFFC62828),
  Color(0xFFB71C1C),
  Color(0xFFAA0000),
];

class AppTheme {
  final int selectedColor;

  AppTheme({this.selectedColor = 0})
      : assert(selectedColor >= 0, 'Selected color must be >= 0'),
        assert(selectedColor < colorList.length,
            'Selected color must be <= ${colorList.length - 1}');

  ThemeData getTheme() {
    final Color primaryColor = colorList[selectedColor];

    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryColor,
        secondary: primaryColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
    );
  }
}




// const colorList = <Color>[
//   Color(0xFF002A68),
//   Color(0xFFD32F2F),
//   Color(0xFFFFEBEE),
//   Color(0xFFFFCDD2),
//   Color(0xFFEF9A9A),
//   Color(0xFFE57373),
//   Color(0xFFEF5350),
//   Colors.red,
//   Color(0xFFE53935),
//   Color(0xFFD32F2F),
//   Color(0xFFC62828),
//   Color(0xFFB71C1C),
//   Color(0xFFAA0000),
// ];