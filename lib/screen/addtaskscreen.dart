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
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();
  String selectedStatus = 'Tạo mới';
  String selectedReviewer = 'Thanh Ngân';

  List<String> statuses = ['Tạo mới', 'Thực hiện', 'Thành công', 'Kết thúc'];
  List<String> reviewers = ['Thanh Ngân', 'Hữu Nghĩa'];

  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref().child('tasks');
  Future<int> _getNextTaskKey() async {
    DataSnapshot snapshot = await databaseRef.parent!.child('lastTaskKey').get();

    if (snapshot.exists) {
      int lastKey = snapshot.value as int;
      await databaseRef.parent!.child('lastTaskKey').set(lastKey + 1); // Cập nhật khóa cuối cùng
      return lastKey + 1; // Trả về khóa tiếp theo
    }

    await databaseRef.parent!.child('lastTaskKey').set(1); // Khởi tạo nếu không tồn tại
    return 1; // Nếu không có task nào, bắt đầu từ 1
  }


  // Hàm lưu công việc mới lên Firebase
  Future<void> _addTask() async {
    print("Bắt đầu thêm công việc..."); // In ra để kiểm tra

    try {
      int newTaskKey = widget.task?.taskKey != null
          ? int.parse(widget.task!.taskKey)
          : await _getNextTaskKey(); // Lấy taskKey tiếp theo
      DatabaseEvent event = await databaseRef.once();
      DataSnapshot snapshot = event.snapshot; // Lấy DataSnapshot từ DatabaseEvent
      int position = (snapshot.value as Map<dynamic, dynamic>?)?.length ?? 0;
      position += 1; // Position sẽ bằng số lượng nhiệm vụ hiện tại + 1

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
        position: position,
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
              onPressed: () async {
                await _addTask(); // Gọi hàm thêm hoặc cập nhật công việc
                Navigator.pop(context); // Quay lại trang task list sau khi thêm/cập nhật thành công
              },
              child: Text(widget.task != null ? 'Cập nhật Công việc' : 'Thêm Công việc mới'),
            ),
          ],
        ),
      ),
    );
  }
}
