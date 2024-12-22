import 'package:app/services/artifact_log_service.dart'; // Import service logging
import 'package:app/widgets/audio_widget.dart';
import 'package:app/widgets/video_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/artifact_provider.dart';
import '../providers/security_provider.dart';

class ArtifactDetailScreen extends StatelessWidget {
  const ArtifactDetailScreen({Key? key}) : super(key: key);

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
    final artifactProvider = Provider.of<ArtifactProvider>(context);
    final securityProvider = Provider.of<SecurityProvider>(context);
    final artifactLogService = ArtifactLogService(); // Tạo service logging
    final artifact = artifactProvider.currentArtifact;

    // Lấy ngôn ngữ từ `SecurityProvider`
    final language = _mapLanguage(securityProvider.language);

    // Loading State
    if (artifactProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Error State
    if (artifactProvider.errorMessage != null) {
      return Scaffold(
        appBar: _buildAppBar(context, "Chi tiết Artifact"),
        body: Center(child: Text(artifactProvider.errorMessage!)),
      );
    }

    // No Artifact State
    if (artifact == null) {
      return Scaffold(
        appBar: _buildAppBar(context, "Chi tiết Artifact"),
        body: const Center(child: Text("Không có dữ liệu Artifact.")),
      );
    }

    // Gọi API log scan sau khi giao diện được dựng
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final visitorId = securityProvider.visitorId;
        if (visitorId != null) {
          await artifactLogService.logArtifactScan(
            artifactId: artifact.artifactId,
            visitorId: visitorId,
          );
        }
      } catch (e) {
        print("Error logging artifact scan: $e");
      }
    });

    // Lấy dữ liệu theo ngôn ngữ
    final String audioUrl = artifact.audioUrl[language] ?? '';
    final String videoUrl = artifact.videoUrl[language] ?? '';
    final String description =
        artifact.description[language] ?? 'Không có mô tả';
    final String imageUrl = artifact.imageUrl;

    return Scaffold(
      backgroundColor: Colors.white, // Đặt màu nền trắng
      appBar: _buildAppBar(context, artifact.name),
      body: Stack(
        children: [
          Column(
            children: [
              // TOP: Video hoặc Hình ảnh
              if (videoUrl.isNotEmpty)
                VideoWidget(videoUrl: 'http://192.168.1.4:3000$videoUrl')
              else if (imageUrl.isNotEmpty)
                _buildTopImage(imageUrl),

              // MID: Description
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // BOTTOM: AudioWidget (chỉ khi có audioUrl)
          if (audioUrl.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 30, // Margin từ đáy
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 180, // Cố định chiều cao
                child: AudioWidget(
                  audioUrl: 'http://192.168.1.4:3000$audioUrl',
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Hiển thị hình ảnh khi không có Video
  Widget _buildTopImage(String imageUrl) {
    return Image.network(
      'http://192.168.1.4:3000$imageUrl',
      fit: BoxFit.cover,
      width: double.infinity,
      height: 200,
    );
  }

  /// Tạo AppBar tái sử dụng
  AppBar _buildAppBar(BuildContext context, String title) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white, // Đặt màu nền AppBar trắng
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
