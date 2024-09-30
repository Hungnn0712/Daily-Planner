
import 'package:dailyplanner/mainpage.dart';
import 'package:dailyplanner/screen/loginscreen.dart';
import 'package:dailyplanner/screen/tasklistscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/ThemeProvider.dart';
import 'model/UserProvider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  debugDisableShadows = true;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: themeProvider.themeData,
          debugShowCheckedModeBanner: false,
          home: MainPage(),
        );
      },
    );
  }
}
