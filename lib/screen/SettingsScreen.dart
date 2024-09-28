import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/ThemeProvider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: SwitchListTile(
          title: Text('Dark Mode'),
          value: Provider.of<ThemeProvider>(context).isDarkMode,
          onChanged: (value) {
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
        ),
      ),
    );
  }
}
