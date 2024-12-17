import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoProvider with ChangeNotifier {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  // Getters
  VideoPlayerController? get controller => _controller;
  bool get isPlaying => _controller?.value.isPlaying ?? false;
  bool get isLoading => _isLoading;
  bool get showControls => _showControls;

  /// Khởi tạo video
  Future<void> initVideo(String url) async {
    if (_controller != null && _controller!.dataSource == url) return; // Tránh khởi tạo lại

    _isLoading = true;
    notifyListeners();

    _controller?.dispose(); // Dọn sạch controller cũ nếu có
    _controller = VideoPlayerController.network(url);

    try {
      await _controller!.initialize();
      _isLoading = false;
      _controller!.setLooping(false);
      _controller!.addListener(() {
        notifyListeners();
      });
      _startHideControlsTimer();
    } catch (e) {
      _isLoading = false;
      debugPrint("Lỗi khởi tạo VideoPlayer: $e");
    }

    notifyListeners();
  }

  /// Play/Pause video
  void togglePlayPause() {
    if (_controller == null) return;

    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    _startHideControlsTimer();
    notifyListeners();
  }

  /// Hiển thị hoặc ẩn controls
  void toggleControls() {
    _showControls = !_showControls;
    notifyListeners();

    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  /// Tự động ẩn controls sau 3 giây
  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      _showControls = false;
      notifyListeners();
    });
  }

  /// Seek đến vị trí cụ thể
  void seekTo(Duration position) {
    if (_controller == null || position > _controller!.value.duration) return;

    _controller!.seekTo(position);
    _startHideControlsTimer();
  }

  /// Xoay màn hình vào chế độ fullscreen
  Future<void> enterFullScreen() async {
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } catch (e) {
      debugPrint("Lỗi khi vào fullscreen: $e");
    }
  }

  /// Thoát fullscreen và trở về màn hình dọc
  Future<void> exitFullScreen() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (e) {
      debugPrint("Lỗi khi thoát fullscreen: $e");
    }
    notifyListeners();
  }

  /// Dọn dẹp tài nguyên
  void disposeVideo() {
    _hideControlsTimer?.cancel();
    _controller?.dispose();
  }
}
