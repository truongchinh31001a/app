import 'package:flutter/material.dart';

class DetailsManager with ChangeNotifier {
  String? _currentType; // 'story' hoặc 'artifact'
  Map<String, dynamic>? _currentData;

  String? get currentType => _currentType;
  Map<String, dynamic>? get currentData => _currentData;

  bool get hasAudio =>
      _currentData?['audioUrl'] != null && _currentData!['audioUrl'] != '';
  bool get hasVideo =>
      _currentData?['videoUrl'] != null && _currentData!['videoUrl'] != '';

  void setDetails(String type, Map<String, dynamic> data) {
    _currentType = type;
    _currentData = data;
    notifyListeners();
  }

  void clearDetails() {
    _currentType = null;
    _currentData = null;
    notifyListeners();
  }
}
