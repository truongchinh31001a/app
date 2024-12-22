import 'dart:async';
import 'package:app/services/shared_state.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SharedState sharedState = SharedState();

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isNearCompletion = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  String _audioUrl = '';
  Timer? _completionTimer;

  // Getters
  String get audioUrl => _audioUrl;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  AudioProvider() {
    sharedState.activeMediaNotifier.addListener(_handleActiveMediaChange);
  }

  /// Khởi tạo audio mới
  Future<void> initAudio(String url) async {
    if (_audioUrl == url)
      return; // Nếu audio URL không thay đổi, không cần khởi tạo lại

    _resetState();
    sharedState.setActiveMedia('audio'); // Đặt trạng thái là audio khi khởi tạo
    _audioUrl = url;
    _isLoading = true;
    notifyListeners();

    try {
      await _audioPlayer.setSourceUrl(url).timeout(
            const Duration(seconds: 20),
            onTimeout: () =>
                throw TimeoutException("Kết nối quá lâu, vui lòng thử lại!"),
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

  /// Thiết lập các sự kiện lắng nghe cho AudioPlayer
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
      if (_totalDuration - _currentPosition <=
              const Duration(milliseconds: 500) &&
          !_isNearCompletion) {
        _isNearCompletion = true;
        _prepareForReplay();
      }
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      sharedState.setActiveMedia(null); // Clear trạng thái khi audio hoàn thành
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
    if (_isPlaying) {
      _pause();
      sharedState.setActiveMedia(null); // Clear trạng thái khi tạm dừng
    } else {
      sharedState.setActiveMedia('audio'); // Đặt trạng thái là audio
      _play();
    }
  }

  /// Phát âm thanh
  Future<void> _play() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  /// Tạm dừng âm thanh
  Future<void> _pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  /// Lắng nghe thay đổi trạng thái từ SharedState
  Future<void> _handleActiveMediaChange() async {
    if (sharedState.activeMedia != 'audio' && _isPlaying) {
      _pause(); // Tự động dừng nếu media khác (video) đang phát
    }
  }

  /// Seek đến một vị trí mới
  Future<void> seek(int seconds) async {
    final newPosition = _currentPosition + Duration(seconds: seconds);
    if (newPosition >= Duration.zero && newPosition <= _totalDuration) {
      await _audioPlayer.seek(newPosition);
      notifyListeners();
    }
  }

  /// Reset trạng thái của AudioProvider
  void _resetState() {
    _audioUrl = '';
    _isPlaying = false;
    _isLoading = false;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    _isNearCompletion = false;
  }

  /// Dọn dẹp tài nguyên
  @override
  void dispose() {
    sharedState.activeMediaNotifier.removeListener(_handleActiveMediaChange);
    _audioPlayer.dispose();
    _completionTimer?.cancel();
    super.dispose();
  }
}
