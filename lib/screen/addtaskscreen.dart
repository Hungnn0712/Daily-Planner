import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/task.dart';

class Addtaskscreen extends StatefulWidget {
  final Task? task;
  const Addtaskscreen({super.key, this.task});

  @override
  State<Addtaskscreen> createState() => _AddtaskscreenState();
}

class _AddtaskscreenState extends State<Addtaskscreen> {
  final TextEditingController taskController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController hostController = TextEditingController();
  String selectedDay = 'Thứ 2';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();
  String selectedStatus = 'Tạo mới';
  String selectedReviewer = 'Thanh Ngân';

  List<String> daysOfWeek = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
  List<String> statuses = ['Tạo mới', 'Thực hiện', 'Thành công', 'Kết thúc'];
  List<String> reviewers = ['Thanh Ngân', 'Hữu Nghĩa'];

  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref().child('tasks');
  Future<int> _getNextTaskKey() async {
    DataSnapshot snapshot = await databaseRef.get();
    if (snapshot.exists) {
      // Kiểm tra kiểu dữ liệu và xử lý nếu không phải là Map
      if (snapshot.value is Map) {
        Map<dynamic, dynamic> tasks = snapshot.value as Map<dynamic, dynamic>;
        List<int> keys = tasks.keys.map((key) => int.tryParse(key) ?? 0).toList();
        keys.sort(); // Sắp xếp các key để lấy giá trị lớn nhất
        return keys.isNotEmpty ? keys.last + 1 : 1; // Cộng thêm 1 vào key lớn nhất
      } else if (snapshot.value is List) {
        // Nếu dữ liệu là List
        List<dynamic> tasks = snapshot.value as List<dynamic>;
        return tasks.length + 1; // Trả về số thứ tự mới dựa trên độ dài của List
      } else {
        // Dữ liệu không hợp lệ
        throw Exception('Dữ liệu không hợp lệ: Không phải là Map hoặc List');
      }
    }
    return 1; // Nếu không có task nào, bắt đầu từ 1
  }

  // Hàm lưu công việc mới lên Firebase
  Future<void> _addTask() async {
    print("Bắt đầu thêm công việc..."); // In ra để kiểm tra

    try {
      int newTaskKey = widget.task?.taskKey != null
          ? int.parse(widget.task!.taskKey)
          : await
      _getNextTaskKey(); // Lấy taskKey tiếp theo

      Task newTask = Task(
        taskKey: newTaskKey.toString(),
        taskName: taskController.text,
        date: DateFormat('dd/MM/yyyy').format(selectedDate),
        startTime: selectedStartTime.format(context),
        endTime: selectedEndTime.format(context),
        location: locationController.text,
        host: hostController.text,
        reviewer: selectedReviewer,
        notes: noteController.text,
        status: selectedStatus,
      );

      if (widget.task != null) {
        await databaseRef.child(newTaskKey.toString()).update(newTask.toJson());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Công việc đã được cập nhật thành công')));
      } else {
        await databaseRef.child(newTaskKey.toString()).set(newTask.toJson());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Công việc đã được thêm thành công')));
      }

      print("Thêm công việc thành công!"); // In ra khi thêm thành công
    } catch (e) {
      print("Lỗi khi thêm công việc: $e"); // In lỗi ra console
    }
  }
  // Hàm để hiển thị DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: selectedDate,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Hàm để hiển thị TimePicker cho thời gian bắt đầu
  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedStartTime,
    );
    if (picked != null && picked != selectedStartTime) {
      setState(() {
        selectedStartTime = picked;
      });
    }
  }

  // Hàm để hiển thị TimePicker cho thời gian kết thúc
  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedEndTime,
    );
    if (picked != null && picked != selectedEndTime) {
      setState(() {
        selectedEndTime = picked;
      });
    }
  }
  @override
  void initState() {
    super.initState();

    // Nếu có task được truyền vào, điền thông tin vào các controller
    if (widget.task != null) {
      taskController.text = widget.task!.taskName;

      // Đảm bảo các thuộc tính có thể null
      locationController.text = widget.task!.location ?? '';
      noteController.text = widget.task!.notes ?? '';
      hostController.text = widget.task!.host ?? '';
      selectedReviewer = widget.task!.reviewer ?? selectedReviewer;
      selectedStatus = widget.task!.status ?? selectedStatus;

      // Thiết lập ngày từ định dạng string sang DateTime
      selectedDate = DateFormat('dd/MM/yyyy').parse(widget.task!.date);

      // Thiết lập thời gian bắt đầu
      if (widget.task!.startTime != null) {
        try {
          var startTimeParts = widget.task!.startTime.replaceAll(RegExp(r'\s+'), '').toUpperCase();
          if (startTimeParts.endsWith('AM') || startTimeParts.endsWith('PM')) {
            startTimeParts = startTimeParts.substring(0, startTimeParts.length - 2); // Bỏ AM/PM
          }
          var timeParts = startTimeParts.split(':');
          selectedStartTime = TimeOfDay(
            hour: int.parse(timeParts[0]) % 24, // Đảm bảo là số trong khoảng 0-23
            minute: int.parse(timeParts[1]),
          );
        } catch (e) {
          print("Error parsing start time: $e");
        }
      }

      // Thiết lập thời gian kết thúc
      if (widget.task!.endTime != null) {
        try {
          var endTimeParts = widget.task!.endTime.replaceAll(RegExp(r'\s+'), '').toUpperCase();
          if (endTimeParts.endsWith('AM') || endTimeParts.endsWith('PM')) {
            endTimeParts = endTimeParts.substring(0, endTimeParts.length - 2); // Bỏ AM/PM
          }
          var timeParts = endTimeParts.split(':');
          selectedEndTime = TimeOfDay(
            hour: int.parse(timeParts[0]) % 24, // Đảm bảo là số trong khoảng 0-23
            minute: int.parse(timeParts[1]),
          );
        } catch (e) {
          print("Error parsing end time: $e");
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Công việc mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Ngày
            DropdownButtonFormField(
              value: selectedDay,
              items: daysOfWeek.map((String day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDay = newValue!;
                });
              },
              decoration: InputDecoration(labelText: 'Thứ ngày'),
            ),
            SizedBox(height: 10),

            // Nội dung công việc
            TextField(
              controller: taskController,
              decoration: InputDecoration(labelText: 'Nội dung công việc'),
            ),
            SizedBox(height: 10),

            // Ngày
            ListTile(
              title: Text("Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 10),

            // Thời gian
            ListTile(
              title: Text("Thời gian: ${selectedStartTime.format(context)} -> ${selectedEndTime.format(context)}"),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                await _selectStartTime(context);
                await _selectEndTime(context);
              },
            ),
            SizedBox(height: 10),

            // Địa điểm
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Địa điểm'),
            ),
            SizedBox(height: 10),

            // Chủ trì
            TextField(
              controller: hostController,
              decoration: InputDecoration(labelText: 'Chủ trì'),
            ),
            SizedBox(height: 10),

            // Ghi chú
            TextField(
              controller: noteController,
              decoration: InputDecoration(labelText: 'Ghi chú'),
            ),
            SizedBox(height: 10),

            // Trạng thái công việc
            DropdownButtonFormField(
              value: selectedStatus,
              items: statuses.map((String status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedStatus = newValue!;
                });
              },
              decoration: InputDecoration(labelText: 'Trạng thái công việc'),
            ),
            SizedBox(height: 10),

            // Người kiểm duyệt
            DropdownButtonFormField(
              value: selectedReviewer,
              items: reviewers.map((String reviewer) {
                return DropdownMenuItem(
                  value: reviewer,
                  child: Text(reviewer),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedReviewer = newValue!;
                });
              },
              decoration: InputDecoration(labelText: 'Người kiểm duyệt'),
            ),
            SizedBox(height: 20),

            // Nút thêm công việc
            ElevatedButton(
              onPressed:(){
                _addTask();
              },
              child: Text('Thêm công việc'),
            ),
          ],
        ),
      ),
    );
  }
}
