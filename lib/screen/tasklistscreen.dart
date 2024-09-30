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
  void _loadTasks() {
    _databaseReference.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;

      // Kiểm tra xem dữ liệu có tồn tại không
      if (data != null) {
        // Kiểm tra xem dữ liệu có phải là Map không
        if (data is Map) {
          setState(() {
            tasks = []; // Xóa danh sách cũ
            data.forEach((key, value) {
              if (value is Map) {
                final taskMap = Map<String, dynamic>.from(value);
                tasks.add(Task.fromJson(taskMap));
              } else {
                print('Giá trị không phải là Map: $value');
              }
            });
            tasks.sort((a, b) => a.position.compareTo(b.position));
          });
        } else if (data is List) {
          setState(() {
            tasks = []; // Xóa danh sách cũ
            for (var item in data) {
              if (item is Map) {
                final taskMap = Map<String, dynamic>.from(item);
                tasks.add(Task.fromJson(taskMap));
              } else {
                print('Giá trị không phải là Map: $item');
              }
            }
            tasks.sort((a, b) => a.position.compareTo(b.position));
          });
        } else {
          print('Dữ liệu không phải là Map hay List: $data');
          setState(() {
            tasks = []; // Xóa danh sách cũ
          });
        }
      } else {
        print('Không có dữ liệu nào trong snapshot.');
        setState(() {
          tasks = []; // Xóa danh sách cũ
        });
      }
    }, onError: (error) {
      print('Lỗi khi lắng nghe dữ liệu: $error');
    });
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
  void reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final task = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, task);

      // Cập nhật vị trí trong Firebase
      reorderTasksInFirebase();
    });
  }
  void reorderTasksInFirebase() {
    // Lặp qua danh sách tasks và cập nhật vị trí mới của từng task lên Firebase
    for (int index = 0; index < tasks.length; index++) {
      final task = tasks[index];
      // Cập nhật vị trí mới lên Firebase
      FirebaseDatabase.instance
          .ref()
          .child('tasks/${task.taskKey}') // taskKey là id của task trong Firebase
          .update({
        'position': index, // Cập nhật vị trí mới
      });
    }
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
            flex: 8,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0), // Bo tròn góc dưới bên trái
                  bottomRight: Radius.circular(0), // Bo tròn góc dưới bên phải
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Màu bóng
                    offset: Offset(2, 2), // Vị trí của bóng
                    blurRadius: 8, // Độ mờ của bóng
                    spreadRadius: 2, // Kích thước bóng
                  ),
                ],
              ),
              child: CalendarScreen(tasks: tasks,),
            ),
          ),
          Expanded(
            flex: 6,
            child: ReorderableListView(
              padding: const EdgeInsets.all(10),
              children: [
                for (int index = 0; index < tasks.length; index++)
                  Container(
                    key: ValueKey(tasks[index].taskKey),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(8), // Bo tròn góc
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // Màu bóng
                          offset: Offset(0, 0), // Bóng đổ về góc dưới phải
                          blurRadius: 10, // Độ mờ của bóng
                          spreadRadius: 6, // Bán kính của bóng
                        ),
                      ],
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Card(
                      elevation: 0, // Đặt bằng 0 để không dùng đổ bóng mặc định của Card
                      color: Colors.transparent, // Để màu nền của Container hiển thị
                      // shape: RoundedRectangleBorder(
                      //   side: BorderSide(
                      //     color: isDarkMode ? Colors.white : Colors.black, // Màu khung (viền)
                      //     width: 0, // Độ dày khung
                      //   ),
                      //   borderRadius: BorderRadius.circular(8), // Bo tròn góc
                      // ),
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
                              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(tasks[index].status),
                                borderRadius: BorderRadius.circular(4),
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
                    ),
                  ),
              ],
              onReorder: (oldIndex, newIndex) {
                reorderTasks(oldIndex, newIndex);
              },
            ),
          )

        ],
      ),
    );
  }
}
