import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class AudioWidget extends StatelessWidget {
  final String audioUrl;
  final int id; // ID của media (story hoặc artifact), kiểu `int`
  final String type; // Loại media: 'artifact' hoặc 'story'

  const AudioWidget({
    Key? key,
    required this.audioUrl,
    required this.id,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    if (audioProvider.audioUrl != audioUrl || audioProvider.sourceId != id) {
      // Khởi tạo audio với id và type nếu URL hoặc ID không khớp
      Future.microtask(() {
        audioProvider.initAudio(
          url: audioUrl,
          id: id,
          type: type,
        );
      });
    }

    return SizedBox(
      height: 180, // Chiều cao cố định
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (audioProvider.isLoading) ...[
              // Hiển thị trạng thái đang tải
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              const Text("Đang tải âm thanh..."),
            ] else if (audioProvider.totalDuration == Duration.zero) ...[
              // Khi dữ liệu chưa sẵn sàng
              const SizedBox(height: 20),
              const Text("Đang cập nhật dữ liệu âm thanh..."),
            ] else ...[
              // Thanh tiến trình
              Slider(
                value: audioProvider.currentPosition.inSeconds
                    .clamp(0, audioProvider.totalDuration.inSeconds)
                    .toDouble(),
                min: 0,
                max: audioProvider.totalDuration.inSeconds.toDouble(),
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
                onChanged: (value) {
                  // Tua đến vị trí mới
                  final diff = (value.toInt() - audioProvider.currentPosition.inSeconds);
                  audioProvider.seek(diff);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(audioProvider.currentPosition),
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text(
                    _formatDuration(audioProvider.totalDuration),
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nút tua lại 10 giây
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.blue),
                    onPressed: () => audioProvider.seek(-10),
                  ),
                  // Nút play/pause
                  ElevatedButton(
                    onPressed: audioProvider.togglePlayPause,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(14),
                    ),
                    child: Icon(
                      audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  // Nút tua tới 10 giây
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.blue),
                    onPressed: () => audioProvider.seek(10),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Định dạng thời lượng thành chuỗi "mm:ss"
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}
