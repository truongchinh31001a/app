import 'package:app/screens/main_screen.dart';
import 'package:app/screens/qr_scanner_screen.dart';
import 'package:app/widgets/audio_widget.dart';
import 'package:app/widgets/video_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/artifact_provider.dart';

class ArtifactDetailScreen extends StatelessWidget {
  const ArtifactDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final artifactProvider = Provider.of<ArtifactProvider>(context);
    final artifact = artifactProvider.currentArtifact;

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

    // Kiểm tra trạng thái
    final String audioUrl = artifact.audioUrl['vi'] ?? '';
    final String videoUrl = artifact.videoUrl['vi'] ?? '';
    final String description = artifact.description['vi'] ?? 'Không có mô tả';
    final String imageUrl = artifact.imageUrl;

    return Scaffold(
      appBar: _buildAppBar(context, artifact.name),
      body: Stack(
        children: [
          Column(
            children: [
              // TOP: Video hoặc Hình ảnh
              if (videoUrl.isNotEmpty)
                VideoWidget(videoUrl: 'http://192.168.1.86:3000$videoUrl')
              else if (imageUrl.isNotEmpty)
                _buildTopImage(imageUrl),

              // MID: Description
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    textAlign: TextAlign.justify,
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
                  audioUrl: 'http://192.168.1.86:3000$audioUrl',
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
      'http://192.168.1.86:3000$imageUrl',
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
      backgroundColor: Colors.transparent,
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
