import 'dart:async';
import 'package:app/services/shared_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoProvider with ChangeNotifier {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  final SharedState sharedState = SharedState();

  int? _sourceId; // ID của nguồn phát (kiểu int)
  String? _sourceType; // Loại nguồn phát (e.g., "artifact", "story")

  VideoProvider() {
    sharedState.activeMediaNotifier.addListener(_handleActiveMediaChange);
  }

  // Getters
  VideoPlayerController? get controller => _controller;
  int? get sourceId => _sourceId; // Getter cho ID (kiểu int)
  String? get sourceType => _sourceType; // Getter cho Type
  bool get isPlaying => _controller?.value.isPlaying ?? false;
  bool get isLoading => _isLoading;
  bool get showControls => _showControls;

  /// Khởi tạo video mới
  Future<void> initVideo({
    required String url,
    required int id, // ID nguồn phát (int)
    required String type, // Loại nguồn phát
  }) async {
    if (_controller != null &&
        _controller!.dataSource == url &&
        _sourceId == id) {
      return; // Tránh khởi tạo lại cùng một URL và ID
    }

    disposeVideo(); // Dọn dẹp controller cũ trước khi khởi tạo mới

    _resetState();

    _sourceId = id; // Lưu ID nguồn
    _sourceType = type; // Lưu loại nguồn
    _isLoading = true;
    notifyListeners();

    _controller = VideoPlayerController.network(url);

    try {
      await _controller!.initialize();
      _isLoading = false;
      _controller!.setLooping(false);

      // Lắng nghe các thay đổi trạng thái của video
      _controller!.addListener(() {
        if (_controller?.value.isInitialized == true) {
          notifyListeners();
        }
      });

      // Tự động phát video sau khi khởi tạo thành công
      await _controller!.play();
      sharedState.setActiveMedia('video'); // Đặt trạng thái là 'video'

      // Bắt đầu đếm ngược ẩn controls
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
      sharedState.setActiveMedia(null); // Xóa trạng thái nếu video tạm dừng
    } else {
      sharedState.setActiveMedia('video'); // Đặt trạng thái là 'video'
      _controller!.play();
    }

    _startHideControlsTimer();
    notifyListeners();
  }

  /// Hiển thị hoặc ẩn controls
  void toggleControls({bool? show}) {
    if (show != null) {
      _showControls = show;
    } else {
      _showControls = !_showControls;
    }

    if (_showControls) {
      _startHideControlsTimer();
    }

    notifyListeners();
  }

  /// Lắng nghe trạng thái media từ `SharedState`
  void _handleActiveMediaChange() {
    if (sharedState.activeMedia != 'video' && isPlaying) {
      _controller?.pause();
      notifyListeners();
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
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (position > _controller!.value.duration) return;

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

  /// Reset trạng thái
  void _resetState() {
    _sourceId = null;
    _sourceType = null;
    _isLoading = false;
    _showControls = true;
    _hideControlsTimer?.cancel();
    _controller?.dispose();
    _controller = null;
  }

  /// Dọn dẹp tài nguyên
  void disposeVideo() {
    sharedState.setActiveMedia(null); // Xóa trạng thái active media
    sharedState.activeMediaNotifier.removeListener(_handleActiveMediaChange);
    _hideControlsTimer?.cancel();
    _controller?.removeListener(() {}); // Xóa tất cả listener
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    disposeVideo(); // Dọn dẹp toàn bộ tài nguyên khi dispose provider
    super.dispose();
  }
}
