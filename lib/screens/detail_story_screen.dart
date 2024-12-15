import 'package:app/widgets/video_widget.dart.dart';
import 'package:flutter/material.dart';
import '../models/story.dart';
import '../widgets/audio_widget.dart';

class DetailsStoryScreen extends StatelessWidget {
  final Story story;

  const DetailsStoryScreen({Key? key, required this.story}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String description =
        story.contentText['vi'] ?? 'No description available';
    final String imageUrl = story.imageUrl;
    final String videoPath = story.videoUrl['vi'] ?? '';
    final String audioPath = story.audioUrl['vi'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(story.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh (nếu có)
            if (imageUrl.isNotEmpty)
              Image.network(
                'http://192.168.1.4:3000$imageUrl',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),

            // Mô tả
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                description,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            // Audio (nếu có)
            if (audioPath.isNotEmpty)
              AudioWidget(audioUrl: 'http://192.168.1.4:3000$audioPath'),

            // Video (nếu có)
            if (videoPath.isNotEmpty)
              VideoWidget(videoUrl: 'http://192.168.1.4:3000$videoPath'),
          ],
        ),
      ),
    );
  }
}
