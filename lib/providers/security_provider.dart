import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityProvider with ChangeNotifier {
  bool _isUnlocked = false; // Trạng thái mở khóa
  DateTime? _expirationTime; // Thời gian hết hạn
  int? _visitorId; // ID của người dùng đã quét QR
  Timer? _timer; // Timer để tự động khóa

  bool get isUnlocked => _isUnlocked;
  int? get visitorId => _visitorId;

  /// Lưu trạng thái vào SharedPreferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isUnlocked', _isUnlocked);
    prefs.setString('expirationTime', _expirationTime?.toIso8601String() ?? '');
    prefs.setInt('visitorId', _visitorId ?? -1);
  }

  /// Khôi phục trạng thái từ SharedPreferences
  Future<void> restoreState() async {
    final prefs = await SharedPreferences.getInstance();
    _isUnlocked = prefs.getBool('isUnlocked') ?? false;

    final expirationTimeStr = prefs.getString('expirationTime');
    if (expirationTimeStr != null && expirationTimeStr.isNotEmpty) {
      _expirationTime = DateTime.parse(expirationTimeStr);
    }

    _visitorId = prefs.getInt('visitorId') != -1 ? prefs.getInt('visitorId') : null;

    // Kiểm tra trạng thái hết hạn
    checkExpiration();
  }

  /// Mở khóa ứng dụng
  void unlock({required DateTime expirationTime, required int visitorId}) {
    _isUnlocked = true;
    _expirationTime = expirationTime;
    _visitorId = visitorId;

    print('Unlock called: isUnlocked=$_isUnlocked, visitorId=$_visitorId');
    _startExpirationTimer();
    _saveState();
    notifyListeners();
  }

  /// Khóa ứng dụng
  void lock() {
    _isUnlocked = false;
    _expirationTime = null;
    _visitorId = null;
    _timer?.cancel();

    print('Locking due to expiration');
    _saveState();
    notifyListeners();
  }

  /// Đặt lại trạng thái bảo mật
  Future<void> reset() async {
    _isUnlocked = false;
    _expirationTime = null;
    _visitorId = null;
    _timer?.cancel();

    print('Resetting security state');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa toàn bộ dữ liệu trong SharedPreferences

    notifyListeners();
  }

  /// Kiểm tra trạng thái hết hạn
  void checkExpiration() {
    if (_expirationTime != null && DateTime.now().isAfter(_expirationTime!)) {
      lock(); // Khóa nếu đã hết hạn
    } else {
      _startExpirationTimer(); // Cài đặt lại Timer nếu còn thời gian
    }
  }

  /// Bắt đầu Timer để tự động khóa khi hết hạn
  void _startExpirationTimer() {
    _timer?.cancel();

    if (_expirationTime != null) {
      final duration = _expirationTime!.difference(DateTime.now());
      if (duration.isNegative) {
        lock(); // Hết hạn ngay lập tức nếu thời gian đã qua
      } else {
        _timer = Timer(duration, () {
          lock();
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy Timer khi không cần thiết
    super.dispose();
  }
}
