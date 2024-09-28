import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import thư viện fl_chart
import '../model/task.dart'; // Đảm bảo import lớp Task

class TaskStatisticsScreen extends StatefulWidget {
  @override
  _TaskStatisticsScreenState createState() => _TaskStatisticsScreenState();
}

class TaskStatistics {
  final DatabaseReference _tasksRef = FirebaseDatabase.instance.ref().child('tasks');

  // Lắng nghe thay đổi từ Firebase và cập nhật theo thời gian thực
  void listenToTaskStatistics(Function(Map<String, int>) onUpdate) {
    _tasksRef.onValue.listen((event) {
      Map<String, int> counts = {
        'Thành công': 0,
        'Thực hiện': 0,
        'Tạo mới': 0,
        'Kết thúc': 0,
      };

      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        if (snapshot.value is List) {
          print("Dữ liệu là list");
          List<dynamic> tasksList = snapshot.value as List<dynamic>;
          for (var item in tasksList) {
            if (item != null) {
              Task task = Task.fromMap(Map<String, dynamic>.from(item));
              if (counts.containsKey(task.status)) {
                counts[task.status] = counts[task.status]! + 1;
              }
            }
          }
        } else if (snapshot.value is Map) {
          Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          data.forEach((key, value) {
            Task task = Task.fromMap(Map<String, dynamic>.from(value));
            if (counts.containsKey(task.status)) {
              counts[task.status] = counts[task.status]! + 1;
            }
          });
        }
      }

      // Gọi hàm callback để cập nhật dữ liệu
      onUpdate(counts);
    });
  }
}

class _TaskStatisticsScreenState extends State<TaskStatisticsScreen> {
  Map<String, int> taskCounts = {
    'Thành công': 0,
    'Thực hiện': 0,
    'Tạo mới': 0,
    'Kết thúc': 0,
  };

  @override
  void initState() {
    super.initState();
    TaskStatistics taskStatistics = TaskStatistics();
    // Lắng nghe thay đổi và cập nhật UI khi dữ liệu thay đổi
    taskStatistics.listenToTaskStatistics((updatedCounts) {
      setState(() {
        taskCounts = updatedCounts;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark; // Kiểm tra chế độ tối
    final textColor = isDarkMode ? Colors.white : Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: Text('Thống Kê Công Việc'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Các thẻ thông tin công việc
            Card(
              elevation: 2,
              child: ListTile(
                title: Text('Công Việc Đã Hoàn Thành'),
                subtitle: Text('${taskCounts['Thành công']} công việc'),
                leading: Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 2,

              child: ListTile(
                title: Text('Công Việc Mới Tạo'),
                subtitle: Text('${taskCounts['Tạo mới']} công việc'),
                leading: Icon(Icons.new_releases, color: Colors.blue),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              child: ListTile(
                title: Text('Công Việc Đang Thực Hiện'),
                subtitle: Text('${taskCounts['Thực hiện']} công việc'),
                leading: Icon(Icons.sync, color: Colors.orange),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              child: ListTile(
                title: Text('Công Việc Đang Kết Thúc'),
                subtitle: Text('${taskCounts['Kết thúc']} công việc'),
                leading: Icon(Icons.east_sharp, color: Colors.red),
              ),
            ),

            // Thêm biểu đồ hình tròn
            SizedBox(height: 30),
            Text('Biểu Đồ Thống Kê Công Việc', style: TextStyle(fontSize: 20)),
            SizedBox(height: 40),
            Container(
              height: 250, // Chỉnh sửa chiều cao của biểu đồ
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: taskCounts['Thành công']!.toDouble(),
                      title: 'Thành công: ${taskCounts['Thành công']}',
                      color: Colors.green,
                      radius: 120,
                    ),
                    PieChartSectionData(
                      value: taskCounts['Tạo mới']!.toDouble(),
                      title: 'Tạo mới: ${taskCounts['Tạo mới']}',
                      color: Colors.blue,
                      radius: 120,
                    ),
                    PieChartSectionData(
                      value: taskCounts['Thực hiện']!.toDouble(),
                      title: 'Thực hiện: ${taskCounts['Thực hiện']}',
                      color: Colors.orange,
                      radius: 120,
                    ),
                    PieChartSectionData(
                      value: taskCounts['Kết thúc']!.toDouble(),
                      title: 'Kết thúc: ${taskCounts['Kết thúc']}',
                      color: Colors.red,
                      radius: 120,
                    ),
                  ],
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
