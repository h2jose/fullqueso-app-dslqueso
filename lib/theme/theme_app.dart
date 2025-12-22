import 'package:ubiiqueso/theme/color.dart';
import 'package:flutter/material.dart';

ThemeData themeApp() {
  return ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
        primary: AppColor.primary,
        brightness: Brightness.light,
        onPrimary: AppColor.primary, // Background Appbar color
        primaryContainer: AppColor.primary, // background float button
        outline: AppColor.accent,
        onSurface: Colors.black, // Text global
        surface: Colors.white // background screen
    ),
    appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white, // Set your desired text color here
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: Colors.white, // Set your desired icon/text color here
      backgroundColor: AppColor.primary, // Set the background color of the button
    ),
  );
}