import 'package:flutter/material.dart';

enum ThemeOption {
  background,
  text,
  shadow,
}

final lightTheme = {
  ThemeOption.background: Color(0xFF81B3FE),
  ThemeOption.text: Colors.white,
  ThemeOption.shadow: Colors.black,
};

final darkTheme = {
  ThemeOption.background: Colors.black,
  ThemeOption.text: Colors.white,
  ThemeOption.shadow: Color(0xFF174EA6),
};

getColors(BuildContext context) {
  return Theme.of(context).brightness == Brightness.light
      ? lightTheme
      : darkTheme;
}
