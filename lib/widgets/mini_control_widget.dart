import 'package:app/providers/artifact_provider.dart';
import 'package:app/providers/audio_provider.dart';
import 'package:app/providers/mini_control_provider.dart';
import 'package:app/providers/story_provider.dart';
import 'package:app/providers/video_provider.dart';
import 'package:app/screens/detail_artifact_screen.dart';
import 'package:app/screens/detail_story_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MiniControl extends StatefulWidget {
  const MiniControl({Key? key}) : super(key: key);

  @override
  _MiniControlState createState() => _MiniControlState();
}

class _MiniControlState extends State<MiniControl> {
  @override
  Widget build(BuildContext context) {
    final miniControlProvider = Provider.of<MiniControlProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context);
    final videoProvider = Provider.of<VideoProvider>(context);
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    final artifactProvider = Provider.of<ArtifactProvider>(context, listen: false);

    // Kiểm tra trạng thái tải Artifact
    if (artifactProvider.isLoading) {
      return const SizedBox.shrink(); // Không hiển thị gì khi đang tải dữ liệu
    }

    final bool isAudioPlaying = audioProvider.isPlaying;
    final bool isVideoPlaying = videoProvider.isPlaying;
    final bool isAudioInitialized = audioProvider.audioUrl.isNotEmpty;
    final bool isVideoInitialized = videoProvider.controller != null;

    // Dọn dẹp media cũ khi media mới bắt đầu
    if (isAudioPlaying && isVideoInitialized) {
      audioProvider.disposeAudio(); // Dừng audio nếu video bắt đầu
    }
    if (isVideoPlaying && isAudioInitialized) {
      videoProvider.disposeVideo(); // Dừng video nếu audio bắt đầu
    }

    // Nếu không có media nào được khởi tạo hoặc đang phát, ẩn MiniControl
    if ((!isAudioInitialized && !isVideoInitialized) || !miniControlProvider.isVisible) {
      return const SizedBox.shrink();
    }

    // Lấy tiêu đề từ ArtifactProvider hoặc StoryProvider
    final String title = isAudioInitialized
        ? _getTitle(audioProvider.sourceId, audioProvider.sourceType, artifactProvider, storyProvider)
        : _getTitle(videoProvider.sourceId, videoProvider.sourceType, artifactProvider, storyProvider);

    return Positioned(
      bottom: 80,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: () {
          if (isAudioInitialized) {
            _navigateToDetail(
              context,
              audioProvider.sourceId,
              audioProvider.sourceType,
              storyProvider,
            );
          } else if (isVideoInitialized) {
            _navigateToDetail(
              context,
              videoProvider.sourceId,
              videoProvider.sourceType,
              storyProvider,
            );
          }
        },
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
              IconButton(
                onPressed: () {
                  if (isAudioInitialized) {
                    audioProvider.togglePlayPause();
                  } else if (isVideoInitialized) {
                    videoProvider.togglePlayPause();
                  }
                },
                icon: Icon(
                  isAudioPlaying || isVideoPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  miniControlProvider.hide();
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
      ),
    );
  }

  /// Lấy tiêu đề từ ArtifactProvider hoặc StoryProvider
  String _getTitle(
    int? id,
    String? type,
    ArtifactProvider artifactProvider,
    StoryProvider storyProvider,
  ) {
    if (id == null || type == null) return 'Unknown';

    if (type == 'artifact') {
      final artifact = artifactProvider.getArtifactById(id);
      debugPrint('Fetching Title for Artifact ID: $id, Found: ${artifact?.name}');
      return artifact?.name ?? 'Unknown Artifact';
    } else if (type == 'story') {
      final story = storyProvider.getStoryById(id);
      debugPrint('Fetching Title for Story ID: $id, Found: ${story?.name}');
      return story?.name ?? 'Unknown Story';
    }

    return 'Unknown';
  }

  void _navigateToDetail(
    BuildContext context,
    int? id,
    String? type,
    StoryProvider storyProvider,
  ) {
    if (id != null && type != null) {
      if (type == 'artifact') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ArtifactDetailScreen(),
          ),
        );
      } else if (type == 'story') {
        final story = storyProvider.getStoryById(id);
        if (story != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsStoryScreen(story: story),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Story not found')),
          );
        }
      }
    }
  }
}
