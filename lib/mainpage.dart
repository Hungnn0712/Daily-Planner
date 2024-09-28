import 'package:dailyplanner/screen/SettingsScreen.dart';
import 'package:dailyplanner/screen/StatisticalScreen.dart';
import 'package:dailyplanner/screen/calendarscreen.dart';
import 'package:dailyplanner/screen/tasklistscreen.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'const/color.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Chỉ số cho màn hình hiện tại

  // Danh sách các widget cho các màn hình
  final List<Widget> _pages = [
    Tasklistscreen(),
    TaskStatisticsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cập nhật chỉ số màn hình hiện tại
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem chế độ hiện tại là sáng hay tối
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: Container(
        height: 60,
        color: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.white, // Đổ màu đen nhẹ cho chế độ tối
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0),
          child: GNav(
            gap: 8,
            hoverColor: Colors.grey[100]!,
            backgroundColor: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.8), // Màu nền cho chế độ tối
            activeColor: Colors.white,
            iconSize: 24,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: Duration(milliseconds: 400),
            tabBackgroundColor: Color(dart_green),
            color: Color(dart_green),
            tabs: const [
              GButton(
                icon: Icons.work,
                text: 'Công việc',
              ),
              GButton(
                icon: Icons.calendar_month,
                text: 'Thống kê',
              ),
              GButton(
                icon: Icons.settings,
                text: 'Cài đặt',
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }
}
