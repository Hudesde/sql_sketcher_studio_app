import 'package:flutter/material.dart';

/// Provider para manejar el estado del usuario autenticado
class UserProvider extends ChangeNotifier {
  String? _userId;
  String? _userName;
  String? _email;

  String? get userId => _userId;
  String? get userName => _userName;
  String? get email => _email;

  void setUser({required String userId, String? userName, String? email}) {
    _userId = userId;
    _userName = userName;
    _email = email;
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    _userName = null;
    _email = null;
    notifyListeners();
  }
}
