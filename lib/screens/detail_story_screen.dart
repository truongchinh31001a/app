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
      appBar: AppBar(
        title: Text(story.name),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình ảnh (nếu có)
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    'http://192.168.1.86:3000$imageUrl',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 20),

              // Mô tả
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  description,
                  style: TextStyle(fontSize: 16, height: 1.5),
                  textAlign: TextAlign.justify,
                ),
              ),
              SizedBox(height: 20),

              // Audio (nếu có)
              if (audioPath.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: AudioWidget(audioUrl: 'http://192.168.1.86:3000$audioPath'),
                ),

              // Video (nếu có)
              if (videoPath.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: VideoWidget(videoUrl: 'http://192.168.1.86:3000$videoPath'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
