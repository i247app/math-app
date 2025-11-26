import 'package:flutter/material.dart';
import 'package:math_ai_app/data/models/user/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  String? _userClass;

  String? get userClass => _userClass;

  void setUserClass(String userClass) {
    _userClass = userClass;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  String get userName => _user?.name ?? 'Guest';
  String get userEmail => _user?.email ?? '';
  String get userPhone => _user?.phone ?? '';
}
