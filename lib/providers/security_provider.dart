import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityProvider with ChangeNotifier {
  bool _isUnlocked = false; // Trạng thái mở khóa
  DateTime? _expirationTime; // Thời gian hết hạn
  int? _visitorId; // ID của người dùng đã quét QR
  String? _language; // Ngôn ngữ từ API
  Timer? _timer; // Timer để tự động khóa
  bool _shouldShowSuccess = false; // Trạng thái hiển thị success

  bool get isUnlocked => _isUnlocked;
  int? get visitorId => _visitorId;
  String? get language => _language;
  DateTime? get expirationTime => _expirationTime;
  bool get shouldShowSuccess => _shouldShowSuccess;

  void setShouldShowSuccess(bool value) {
    _shouldShowSuccess = value;
    notifyListeners();
  }

  /// Lưu trạng thái vào SharedPreferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isUnlocked', _isUnlocked);
    prefs.setString('expirationTime', _expirationTime?.toIso8601String() ?? '');
    prefs.setInt('visitorId', _visitorId ?? -1);
    prefs.setString('language', _language ?? '');
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
    _language = prefs.getString('language');

    // Kiểm tra trạng thái hết hạn
    checkExpiration();
  }

  /// Mở khóa ứng dụng
  void unlock({
    required DateTime expirationTime,
    required int visitorId,
    required String language,
  }) {
    _isUnlocked = true;
    _expirationTime = expirationTime;
    _visitorId = visitorId;
    _language = language;

    print('Unlock called: isUnlocked=$_isUnlocked, visitorId=$_visitorId, language=$_language');
    _startExpirationTimer();
    _saveState();
    notifyListeners();
  }

  /// Khóa ứng dụng
  void lock() {
    _isUnlocked = false;
    _expirationTime = null;
    _visitorId = null;
    _language = null;
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
    _language = null;
    _timer?.cancel();
    _shouldShowSuccess = true;

    print('Resetting security state');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

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

  /// Xóa trạng thái thành công (dành cho UI sau khi logout)
  void clearSuccessState() {
    _shouldShowSuccess = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy Timer khi không cần thiết
    super.dispose();
  }
}
