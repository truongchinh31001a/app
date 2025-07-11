import 'package:app/widgets/audio_widget.dart';
import 'package:app/widgets/video_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story.dart';
import '../providers/security_provider.dart';

class DetailsStoryScreen extends StatelessWidget {
  final Story story;

  const DetailsStoryScreen({Key? key, required this.story}) : super(key: key);

  /// Ánh xạ `language` từ SecurityProvider sang mã ngôn ngữ
  String _mapLanguage(String? language) {
    switch (language) {
      case 'English':
        return 'en';
      case 'Vietnamese':
        return 'vi';
      default:
        return 'vi'; // Mặc định là tiếng Việt
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy ngôn ngữ hiện tại từ SecurityProvider
    final securityProvider = Provider.of<SecurityProvider>(context);
    final language = _mapLanguage(securityProvider.language);

    // Dữ liệu dựa trên ngôn ngữ
    final String description =
        story.contentText[language] ?? 'No description available';
    final String imageUrl = story.imageUrl;
    final String videoPath = story.videoUrl[language] ?? '';
    final String audioPath = story.audioUrl[language] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          story.name,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // TOP: Hình ảnh hoặc Video
              if (videoPath.isNotEmpty)
                VideoWidget(
                    videoUrl: 'http://192.168.1.44:3000$videoPath',
                    sourceId: story.storyId,
                    sourceType: 'story')
              else if (imageUrl.isNotEmpty)
                _buildTopImage(imageUrl),

              // MID: Mô tả
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ],
          ),

          // BOTTOM: AudioWidget (nằm dưới cùng màn hình)
          if (audioPath.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 30, // Margin bottom
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 180, // Cố định chiều cao của AudioWidget
                child: AudioWidget(
                  audioUrl: 'http://192.168.1.44:3000$audioPath',
                  id: story.storyId,
                  type: 'story',
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Widget hiển thị hình ảnh
  Widget _buildTopImage(String imageUrl) {
    return Image.network(
      'http://192.168.1.44:3000$imageUrl',
      fit: BoxFit.contain, // Hiển thị toàn bộ hình ảnh
      width: double.infinity,
      height: 300, // Chiều cao cố định là 400
    );
  }
}
