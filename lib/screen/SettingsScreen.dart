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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Mode Switch
            SwitchListTile(
              title: Text('Dark Mode'),
              value: Provider.of<ThemeProvider>(context).isDarkMode,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),

            SizedBox(height: 20),
            Text('Font Style'),
            DropdownButton<String>(
              value: Provider.of<ThemeProvider>(context).fontFamily,
              items: [
                DropdownMenuItem(
                  child: Text('Roboto'),
                  value: 'Roboto',
                ),
                DropdownMenuItem(
                  child: Text('Arial'),
                  value: 'Arial',
                ),
                DropdownMenuItem(
                  child: Text('Times New Roman'),
                  value: 'Times New Roman',
                ),
              ],
              onChanged: (font) {
                Provider.of<ThemeProvider>(context, listen: false).setFontFamily(font!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
