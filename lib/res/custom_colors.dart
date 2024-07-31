import 'package:flutter/material.dart';

class Palette {
  static const Color firebaseNavy = Color(0xFF2C384A);
  static const Color autoShareBlue = Color(0xFF1EB5EA);
  static const Color autoShareLightGrey = Color(0xFFDCDCDC);
  static const Color autoShareDarkGrey = Color(0xFFA9A9A9);
  static const Color autoShareDarkBlue = Color(0xFF4285F4);
}

MaterialColor buildMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}