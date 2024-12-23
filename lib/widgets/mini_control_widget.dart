import 'package:app/providers/audio_provider.dart';
import 'package:app/providers/details_manager.dart';
import 'package:app/providers/video_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MiniControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final detailsManager = Provider.of<DetailsManager>(context);

    if (detailsManager.currentType == null) {
      return SizedBox.shrink(); // Không hiển thị nếu không có trạng thái
    }

    final type = detailsManager.currentType!;
    final data = detailsManager.currentData!;
    final String? audioUrl = data['audioUrl'];
    final String? videoUrl = data['videoUrl'];

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade600,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Audio/Video Controls
            if (detailsManager.hasAudio) _buildAudioControls(context, audioUrl!),
            if (detailsManager.hasVideo) _buildVideoControls(context, videoUrl!),

            const SizedBox(height: 8),

            // Back to Details Button
            GestureDetector(
              onTap: () {
                if (type == 'artifact') {
                  Navigator.pushNamed(context, '/artifact'); // Điều hướng Artifact
                } else if (type == 'story') {
                  Navigator.pushNamed(context, '/story'); // Điều hướng Story
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Back to Details',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Audio Controls (Pause/Play)
  Widget _buildAudioControls(BuildContext context, String audioUrl) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: audioProvider.togglePlayPause,
          icon: Icon(
            audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
        ),
        const Text(
          'Audio Playing',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  /// Video Controls (Pause/Play)
  Widget _buildVideoControls(BuildContext context, String videoUrl) {
    final videoProvider = Provider.of<VideoProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: videoProvider.togglePlayPause,
          icon: Icon(
            videoProvider.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
        ),
        const Text(
          'Video Playing',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
