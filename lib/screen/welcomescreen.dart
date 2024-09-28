import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'loginscreen.dart';

class Welcomescreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo hoặc tên ứng dụng
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Daily Planner',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Nút Đăng nhập
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Loginscreen()),
                );
              },
              child: Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}