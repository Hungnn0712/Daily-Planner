import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/task.dart';

class CalendarScreen extends StatefulWidget {
  final List<Task> tasks;

  CalendarScreen({required this.tasks});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('tasks');
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> _events = {};

  // Hàm để thêm sự kiện cho một ngày cụ thể
  void _addEventForDay(DateTime day, String event) {
    final normalizedDay = _normalizeDate(day);
    if (_events[normalizedDay] != null) {
      _events[normalizedDay]!.add(event);
    } else {
      _events[normalizedDay] = [event];
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Hàm trả về các sự kiện của một ngày cụ thể
  List<String> _getEventsForDay(DateTime day) {
    return _events[_normalizeDate(day)] ?? [];
  }

  void _listenToFirebaseChanges() {
    _database.onValue.listen((event) {
      if (event.snapshot.exists) {
        _events.clear();
        if (event.snapshot.value is List) {
          List<dynamic> tasksList = event.snapshot.value as List<dynamic>;
          for (var item in tasksList) {
            if (item != null) {
              Task task = Task.fromJson(Map<String, dynamic>.from(item));
              DateTime taskDate = DateFormat('dd/MM/yyyy').parse(task.date);
              _addEventForDay(taskDate, task.taskName);
            }
          }
        } else if (event.snapshot.value is Map) {
          Map<dynamic, dynamic> tasksMap = event.snapshot.value as Map<dynamic, dynamic>;
          tasksMap.forEach((key, value) {
            if (value != null) {
              Task task = Task.fromJson(Map<String, dynamic>.from(value));
              DateTime taskDate = DateFormat('dd/MM/yyyy').parse(task.date);
              _addEventForDay(taskDate, task.taskName);
            }
          });
        }
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _listenToFirebaseChanges();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark; // Kiểm tra chế độ tối
    final textColor = isDarkMode ? Colors.white : Colors.black;
    List<String> selectedDayEvents = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
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
          const SizedBox(height: 8.0),
          if (selectedDayEvents.isNotEmpty)
          Expanded(
            child: Container(decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1), // Bo tròn các góc
              border: Border( // Khung ngoài
                top: BorderSide( // Khung chỉ ở phía trên
                  color: isDarkMode ? Colors.white : Colors.black, // Màu của khung
                  width: 0.1, // Độ dày của khung
                ),
              ),
            ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // Đặt cuộn theo chiều ngang
                itemCount: selectedDayEvents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(10,0,0,0), // Khoảng cách giữa các item
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                        color: isDarkMode ? Colors.black.withOpacity(0.1) : Colors.white, // Bạn có thể thay đổi màu nền của item
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(11), // Khoảng cách bên trong container
                        child: Text(
                          selectedDayEvents[index],
                          style: TextStyle(fontSize: 20, color: isDarkMode ? Colors.white : Colors.black), // Thay đổi kiểu chữ và màu chữ
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm để xây dựng các dấu hiệu sự kiện (marker)
  Widget _buildEventsMarker(List events) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      width: 18,
      height: 18,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
