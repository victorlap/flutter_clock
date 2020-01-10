import 'package:flutter/material.dart';

enum ThemeOption {
  background,
  background2,
  background3,
  background4,
  text,
}

final lightTheme = {
//  ThemeOption.background: Colors.black,
//  ThemeOption.background2: Colors.black,
//  ThemeOption.background3: Colors.black,
//  ThemeOption.background4: Colors.black,
  ThemeOption.background: Color(0xff40255c),
  ThemeOption.background2: Color(0xff3017a2),
  ThemeOption.background3: Color(0xfffe00c1),
  ThemeOption.background4: Color(0xffb00085),
  ThemeOption.text: Colors.white,
};

final darkTheme = {
  ThemeOption.background: Color(0xff20122d),
  ThemeOption.background2: Color(0xff170b51),
  ThemeOption.background3: Color(0xff7f0060),
  ThemeOption.background4: Color(0xff580042),
  ThemeOption.text: Colors.grey[600],
};

getColors(BuildContext context) {
  return Theme.of(context).brightness == Brightness.light
      ? lightTheme
      : darkTheme;
}
