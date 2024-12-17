import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class AudioWidget extends StatelessWidget {
  final String audioUrl;

  const AudioWidget({
    Key? key,
    required this.audioUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    if (audioProvider.audioUrl != audioUrl) {
      Future.microtask(() => audioProvider.initAudio(audioUrl));
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
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              const Text("Đang tải âm thanh..."),
            ] else if (audioProvider.totalDuration == Duration.zero) ...[
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
                onChanged: (value) =>
                    audioProvider.seek((value).toInt() - audioProvider.currentPosition.inSeconds),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(audioProvider.currentPosition)),
                  Text(_formatDuration(audioProvider.totalDuration)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.blueAccent),
                    onPressed: () => audioProvider.seek(-10),
                  ),
                  ElevatedButton(
                    onPressed: audioProvider.togglePlayPause,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(14),
                    ),
                    child: Icon(
                      audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.blueAccent),
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}
