import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  Color _themeColor = Colors.blue;
  String _fontFamily = 'Roboto';

  bool get isDarkMode => _isDarkMode;
  Color get themeColor => _themeColor;
  String get fontFamily => _fontFamily;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setThemeColor(Color color) {
    _themeColor = color;
    notifyListeners();
  }

  void setFontFamily(String font) {
    _fontFamily = font;
    notifyListeners();
  }

  ThemeData get themeData {
    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: _themeColor,
      fontFamily: _fontFamily,
    );
  }
}
