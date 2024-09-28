import 'package:flutter/material.dart';

class Task {
  String taskKey;  // Mã nhận diện duy nhất cho mỗi task
  String taskName;
  String date;
  String startTime;
  String endTime;
  String location;
  String host;
  String reviewer;
  String notes;
  String status;

  Task({
    required this.taskKey,
    required this.taskName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.host,
    required this.reviewer,
    required this.notes,
    required this.status,
  });

  // Chuyển đổi Task thành JSON để lưu trữ lên Firebase
  Map<String, dynamic> toJson() {
    return {
      'taskKey': taskKey,
      'taskName': taskName,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'host': host,
      'reviewer': reviewer,
      'notes': notes,
      'status': status,
    };
  }

  // Chuyển đổi JSON từ Firebase thành Task
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskKey: json['taskKey'] ?? '',
      taskName: json['taskName'] ?? '',
      date: json['date'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      location: json['location'] ?? '',
      host: json['host'] ?? '',
      reviewer: json['reviewer'] ?? '',
      notes: json['notes'] ?? '',
      status: json['status'] ?? '',
    );
  }

  // Phương thức chuyển đổi từ Map vào Task
  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      taskKey: map['taskKey'] ?? '', // Khôi phục mã nhiệm vụ
      taskName: map['taskName'] ?? '', // Khôi phục tên nhiệm vụ
      date: map['date'] ?? '', // Khôi phục ngày
      startTime: map['startTime'] ?? '', // Khôi phục giờ bắt đầu
      endTime: map['endTime'] ?? '', // Khôi phục giờ kết thúc
      location: map['location'] ?? '', // Khôi phục địa điểm
      host: map['host'] ?? '', // Khôi phục người tổ chức
      reviewer: map['reviewer'] ?? '', // Khôi phục người đánh giá
      notes: map['notes'] ?? '', // Khôi phục ghi chú
      status: map['status'] ?? 'new', // Giá trị mặc định cho status
    );
  }
}
