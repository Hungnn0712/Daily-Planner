import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _userName;
  String? get userId => _userId;
  String? get userName => _userName;

  void setUserId(String id) {
    _userId = id;
    notifyListeners();
  }
  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }
}
