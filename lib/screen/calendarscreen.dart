import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/task.dart';

class CalendarScreen extends StatefulWidget {
  final List<Task> tasks; // Thêm biến tasks

  CalendarScreen({required this.tasks}); // Thay đổi constructor để nhận tasks

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('tasks');
  List<Task> tasks = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> _events = {};

  // Hàm để thêm sự kiện cho một ngày cụ thể
  void _addEventForDay(DateTime day, String event) {
    final normalizedDay = _normalizeDate(day);
    if (_events[normalizedDay] != null) {
      _events[normalizedDay]!.add(event); // Nếu đã có sự kiện cho ngày này, thêm vào danh sách
    } else {
      _events[normalizedDay] = [event]; // Nếu chưa có sự kiện, khởi tạo danh sách
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  // Hàm trả về các sự kiện của một ngày cụ thể
  List<String> _getEventsForDay(DateTime day) {
    return _events[_normalizeDate(day)] ?? []; // So sánh chỉ phần ngày
  }
  Future<void> _loadTasksFromFirebase() async {
    DataSnapshot snapshot = await _database.get();
    if (snapshot.exists) {
      // Kiểm tra xem snapshot.value có null hay không
      if (snapshot.value == null) {
        print("Không có dữ liệu trong snapshot.");
        return; // Thoát hàm nếu không có dữ liệu
      }

      // Kiểm tra xem snapshot.value có phải là một List hay không
      if (snapshot.value is List) {
        print("Dữ liệu là list");
        List<dynamic> tasksList = snapshot.value as List<dynamic>;
        for (var item in tasksList) {
          // Kiểm tra item có null hay không trước khi chuyển đổi
          if (item != null) {
            Task task = Task.fromJson(Map<String, dynamic>.from(item));

            // Lấy ngày của task và thêm sự kiện vào lịch
            DateTime taskDate = DateFormat('dd/MM/yyyy').parse(task.date);
            _addEventForDay(taskDate, task.taskName);
          }
        }
      } else if (snapshot.value is Map) {
        Map<dynamic, dynamic> tasksMap = snapshot.value as Map<dynamic, dynamic>;
        tasksMap.forEach((key, value) {
          // Kiểm tra value có null hay không trước khi chuyển đổi
          if (value != null) {
            Task task = Task.fromJson(Map<String, dynamic>.from(value));

            // Lấy ngày của task và thêm sự kiện vào lịch
            DateTime taskDate = DateFormat('dd/MM/yyyy').parse(task.date);
            _addEventForDay(taskDate, task.taskName);
          }
        });
      }

      setState(() {}); // Cập nhật lại UI sau khi tải dữ liệu
    } else {
      print("Snapshot không tồn tại.");
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _loadTasksFromFirebase();
      // _addEventForDay(DateTime(2024, 9, 29), 'Lịch họp công việc');
      // _addEventForDay(DateTime(2024, 9, 29), 'Lịch họp công việc khác');
      //_addEventForDay(DateTime(2024, 9, 28), 'Lịch họp công việc');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        eventLoader: _getEventsForDay,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        // Hiển thị sự kiện dưới mỗi ngày
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(events),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  // Hàm để xây dựng các dấu hiệu sự kiện (marker)
  Widget _buildEventsMarker(List events) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green, // Màu của marker
        shape: BoxShape.circle,
      ),
      width: 18,
      height: 18,
      child: Center(
        child: Text(
          '${events.length}', // Số lượng sự kiện trong ngày
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
