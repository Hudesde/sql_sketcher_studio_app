import 'package:flutter/material.dart';

/// Provider para manejar el estado del SQL generado
class SqlProvider extends ChangeNotifier {
  String _sqlCode = '';

  /// Agregué un campo para almacenar la API Key
  String apiKey = '';

  String get sqlCode => _sqlCode;

  void setSqlCode(String code) {
    _sqlCode = code;
    notifyListeners();
  }

  void clear() {
    _sqlCode = '';
    notifyListeners();
  }
}
