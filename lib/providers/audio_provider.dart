import 'dart:async';
import 'package:app/services/shared_state.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioProvider with ChangeNotifier {
  final SharedState sharedState = SharedState();

  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isNearCompletion = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  String _audioUrl = '';
  int? _sourceId; // ID nguồn phát
  String? _sourceType; // Loại nguồn phát
  Timer? _completionTimer;

  // Getters
  String get audioUrl => _audioUrl;
  int? get sourceId => _sourceId;
  String? get sourceType => _sourceType;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  AudioProvider() {
    sharedState.activeMediaNotifier.addListener(_handleActiveMediaChange);
  }

  /// Khởi tạo audio mới
  Future<void> initAudio({
    required String url,
    required int id,
    required String type,
  }) async {
    if (_audioUrl == url) return; // Nếu URL không thay đổi, không cần khởi tạo lại

    disposeAudio(); // Hủy tài nguyên cũ trước khi khởi tạo mới

    _resetState();
    _audioPlayer = AudioPlayer();
    sharedState.setActiveMedia('audio');
    _audioUrl = url;
    _sourceId = id;
    _sourceType = type;
    _isLoading = true;
    notifyListeners();

    try {
      await _audioPlayer!.setSourceUrl(url).timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw TimeoutException("Kết nối quá lâu."),
          );

      _setupListeners();
      _isLoading = false;
      _totalDuration = await _fetchDuration();
      await _play();
    } catch (e) {
      _isLoading = false;
      debugPrint("Error initializing audio: $e");
    }
    notifyListeners();
  }

  /// Thiết lập sự kiện lắng nghe
  void _setupListeners() {
    _audioPlayer?.onDurationChanged.listen((duration) {
      if (duration > Duration.zero) {
        _totalDuration = duration;
        notifyListeners();
      }
    });

    _audioPlayer?.onPositionChanged.listen((position) {
      _currentPosition = position;
      if (_totalDuration - _currentPosition <= const Duration(milliseconds: 500) &&
          !_isNearCompletion) {
        _isNearCompletion = true;
        _prepareForReplay();
      }
      notifyListeners();
    });

    _audioPlayer?.onPlayerComplete.listen((_) {
      _isPlaying = false;
      sharedState.setActiveMedia(null);
      notifyListeners();
    });
  }

  /// Đưa về trạng thái ban đầu trước khi kết thúc
  Future<void> _prepareForReplay() async {
    if (_audioPlayer == null) return;
    await _audioPlayer!.seek(Duration.zero);
    await _pause();
    _isPlaying = false;
    notifyListeners();
    debugPrint("Audio prepared for replay.");
  }

  /// Lấy thời lượng âm thanh
  Future<Duration> _fetchDuration() async {
    try {
      final duration = await _audioPlayer?.getDuration();
      return duration ?? const Duration(minutes: 3);
    } catch (e) {
      debugPrint("Error fetching duration: $e");
      return const Duration(minutes: 3);
    }
  }

  /// Phát và tạm dừng âm thanh
  void togglePlayPause() {
    if (_audioPlayer == null) return;

    if (_isPlaying) {
      _pause();
      sharedState.setActiveMedia(null);
    } else {
      sharedState.setActiveMedia('audio');
      _play();
    }
  }

  /// Phát âm thanh
  Future<void> _play() async {
    if (_audioPlayer == null) return;
    try {
      await _audioPlayer!.resume();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  /// Tạm dừng âm thanh
  Future<void> _pause() async {
    if (_audioPlayer == null) return;
    try {
      await _audioPlayer!.pause();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error pausing audio: $e");
    }
  }

  /// Lắng nghe thay đổi trạng thái từ SharedState
  Future<void> _handleActiveMediaChange() async {
    if (sharedState.activeMedia != 'audio' && _isPlaying) {
      _pause();
    }
  }

  /// Seek đến vị trí mới
  Future<void> seek(int seconds) async {
    if (_audioPlayer == null) return;
    final newPosition = _currentPosition + Duration(seconds: seconds);
    if (newPosition >= Duration.zero && newPosition <= _totalDuration) {
      try {
        await _audioPlayer?.seek(newPosition);
        notifyListeners();
      } catch (e) {
        debugPrint("Error seeking audio: $e");
      }
    }
  }

  /// Hủy AudioPlayer và các tài nguyên liên quan
  void disposeAudio() {
    sharedState.activeMediaNotifier.removeListener(_handleActiveMediaChange);
    _audioPlayer?.dispose();
    _completionTimer?.cancel();
    _resetState();
    _audioPlayer = null;
  }

  /// Reset trạng thái
  void _resetState() {
    _audioUrl = '';
    _sourceId = null;
    _sourceType = null;
    _isPlaying = false;
    _isLoading = false;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    _isNearCompletion = false;
  }

  /// Dọn dẹp tài nguyên
  @override
  void dispose() {
    disposeAudio();
    super.dispose();
  }
}
