import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/video_provider.dart';

class MiniControl extends StatelessWidget {
  const MiniControl({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final videoProvider = Provider.of<VideoProvider>(context);

    final bool isAudioPlaying = audioProvider.isPlaying;
    final bool isVideoPlaying = videoProvider.isPlaying;
    final bool isAudioInitialized = audioProvider.audioUrl.isNotEmpty;
    final bool isVideoInitialized = videoProvider.controller != null;

    // If no media is initialized, return an empty widget
    if (!isAudioInitialized && !isVideoInitialized) {
      return const SizedBox.shrink();
    }

    // Determine media title
    final String title = isAudioInitialized
        ? "Audio: ${audioProvider.sourceType ?? ''} ${audioProvider.sourceId ?? ''}"
        : "Video: ${videoProvider.sourceType ?? ''} ${videoProvider.sourceId ?? ''}";

    return Positioned(
      bottom: 80,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade600,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Media Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Play/Pause Button
            IconButton(
              onPressed: () {
                if (isAudioInitialized) {
                  audioProvider.togglePlayPause();
                } else if (isVideoInitialized) {
                  videoProvider.togglePlayPause();
                }
              },
              icon: Icon(
                (isAudioPlaying || isVideoPlaying) ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
            // Close Button
            IconButton(
              onPressed: () {
                if (isAudioInitialized) {
                  audioProvider.disposeAudio();
                }
                if (isVideoInitialized) {
                  videoProvider.disposeVideo();
                }
              },
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
