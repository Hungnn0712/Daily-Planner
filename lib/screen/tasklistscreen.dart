import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/task.dart';
import 'addtaskscreen.dart';
import 'calendarscreen.dart';

class Tasklistscreen extends StatefulWidget {
  @override
  State<Tasklistscreen> createState() => _TaskListScreen();
}

class _TaskListScreen extends State<Tasklistscreen> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref().child('tasks');
  List<Task> tasks = []; // Danh sách công việc

  // Hàm để tải danh sách công việc từ Firebase
  void _loadTasks() async {
    try {
      final snapshot = await _databaseReference.once();

      // Kiểm tra xem dữ liệu có tồn tại không
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value;

        // Kiểm tra xem dữ liệu có phải là Map không
        if (data is Map) {
          setState(() {
            tasks = [];
            data.forEach((key, value) {
              if (value is Map) {
                final taskMap = Map<String, dynamic>.from(value);
                tasks.add(Task.fromJson(taskMap));
              } else {
                print('Giá trị không phải là Map: $value');
              }
            });
          });
        } else if (data is List) {
          setState(() {
            tasks = [];
            for (var item in data) {
              if (item is Map) {
                final taskMap = Map<String, dynamic>.from(item);
                tasks.add(Task.fromJson(taskMap));
              } else {
                print('Giá trị không phải là Map: $item');
              }
            }
          });
        } else {
          print('Dữ liệu không phải là Map hay List: $data');
          setState(() {
            tasks = [];
          });
        }
      } else {
        print('Không có dữ liệu nào trong snapshot.');
        setState(() {
          tasks = [];
        });
      }
    } catch (e) {
      print('Lỗi khi tải nhiệm vụ: $e');
    }
  }

  // Hàm để xóa công việc
  void deleteTask(int index) async {
    await _databaseReference.child(tasks[index].taskKey).remove();
    _loadTasks();
  }

  void addTask(String task) async {
    final newTaskRef = _databaseReference.push();
    await newTaskRef.set({'taskName': task});
    _loadTasks();
  }

  void editTask(int index, String newTask) async {
    await _databaseReference.child(tasks[index].taskKey).update({'taskName': newTask});
    _loadTasks();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Thành công':
        return Colors.green; // Màu xanh lá cho trạng thái thành công
      case 'Tạo mới':
        return Colors.blue; // Màu xanh dương cho trạng thái tạo mới
      case 'Thực hiện':
        return Colors.orange; // Màu cam cho trạng thái thực hiện
      case 'Kết thúc':
        return Colors.red; // Màu đỏ cho trạng thái kết thúc
      default:
        return Colors.grey; // Màu xám cho trạng thái không xác định
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Tải danh sách công việc khi khởi tạo
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark; // Kiểm tra chế độ tối
    final textColor = isDarkMode ? Colors.white : Colors.black; // Chọn màu chữ tương ứng

    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách Công việc'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Addtaskscreen()),
              ).then((value) {
                _loadTasks();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CalendarScreen(tasks: tasks,),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            flex: 5,
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: isDarkMode ? Colors.grey[850] : Colors.white, // Màu nền của card
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tasks[index].taskName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor, // Màu chữ
                          ),
                        ),
                        Text(
                          'Chủ trì: ${tasks[index].host}',
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor, // Màu chữ
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngày: ${tasks[index].date}, Giờ: ${tasks[index].startTime}',
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor, // Màu chữ
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(tasks[index].status),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Trạng thái: ${tasks[index].status}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Addtaskscreen(task: tasks[index]),
                        ),
                      ).then((value) {
                        _loadTasks();
                      });
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deleteTask(index);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
