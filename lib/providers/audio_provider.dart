import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isNearCompletion = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  String _audioUrl = '';
  Timer? _completionTimer; // Timer để kiểm tra gần kết thúc

  // Getters
  String get audioUrl => _audioUrl;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  /// Khởi tạo audio mới
  Future<void> initAudio(String url) async {
    if (_audioUrl == url) return;
    _resetState();
    _audioUrl = url;
    _isLoading = true;
    notifyListeners();

    try {
      await _audioPlayer.setSourceUrl(url).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException("Kết nối quá lâu, vui lòng thử lại!"),
      );

      _setupListeners();
      _isLoading = false;
      _totalDuration = await _fetchDuration();
      _play();
    } catch (e) {
      _isLoading = false;
      print("Error initializing audio: $e");
    }
    notifyListeners();
  }

  /// Thiết lập listeners
  void _setupListeners() {
    _audioPlayer.onDurationChanged.listen((duration) {
      if (duration > Duration.zero) {
        _totalDuration = duration;
        notifyListeners();
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;

      // Gần kết thúc: còn 0.5 giây
      if (_totalDuration - _currentPosition <= const Duration(milliseconds: 500) &&
          !_isNearCompletion) {
        _isNearCompletion = true;
        _prepareForReplay();
      }
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      notifyListeners();
    });
  }

  /// Đưa về trạng thái ban đầu trước khi kết thúc
  Future<void> _prepareForReplay() async {
    await _audioPlayer.seek(Duration.zero);
    await _pause();
    _isPlaying = false;
    notifyListeners();
    print("Audio prepared for replay.");
  }

  /// Lấy thời lượng âm thanh an toàn
  Future<Duration> _fetchDuration() async {
    try {
      final duration = await _audioPlayer.getDuration();
      return duration ?? const Duration(minutes: 3);
    } catch (_) {
      return const Duration(minutes: 3);
    }
  }

  /// Phát và tạm dừng âm thanh
  void togglePlayPause() {
    if (_currentPosition == Duration.zero || _isNearCompletion) {
      _isNearCompletion = false;
      _play();
    } else if (_isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  Future<void> _play() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> _pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  /// Seek tiến/lùi
  Future<void> seek(int seconds) async {
    final newPosition = _currentPosition + Duration(seconds: seconds);
    if (newPosition >= Duration.zero && newPosition <= _totalDuration) {
      await _audioPlayer.seek(newPosition);
      notifyListeners();
    }
  }

  /// Reset trạng thái
  void _resetState() {
    _audioUrl = '';
    _isPlaying = false;
    _isLoading = false;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    _isNearCompletion = false;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _completionTimer?.cancel();
    super.dispose();
  }
}
