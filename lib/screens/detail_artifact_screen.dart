import 'package:app/services/artifact_log_service.dart'; // Import service logging
import 'package:app/widgets/audio_widget.dart';
import 'package:app/widgets/video_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/artifact_provider.dart';
import '../providers/security_provider.dart';

class ArtifactDetailScreen extends StatefulWidget {
  const ArtifactDetailScreen({Key? key}) : super(key: key);

  @override
  State<ArtifactDetailScreen> createState() => _ArtifactDetailScreenState();
}

class _ArtifactDetailScreenState extends State<ArtifactDetailScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtifact();
  }

  Future<void> _loadArtifact() async {
    final artifactProvider =
        Provider.of<ArtifactProvider>(context, listen: false);
    final qrCode = artifactProvider.currentQrCode;

    if (qrCode != null) {
      try {
        await artifactProvider.fetchArtifactByQRCode(qrCode);
      } catch (e) {
        debugPrint('Error loading artifact: $e');
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } else {
      setState(() => isLoading = false);
    }
  }

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
    final artifactLogService = ArtifactLogService();

    final artifact = artifactProvider.currentArtifact;

    // Loading State
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Error State: Không tìm thấy Artifact
    if (artifact == null) {
      return Scaffold(
        appBar: _buildAppBar(context, "Artifact Not Found"),
        body: const Center(
          child: Text("No Artifact available for the given QR Code."),
        ),
      );
    }

    final language = _mapLanguage(securityProvider.language);

    // Gọi API log scan
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
        debugPrint("Error logging artifact scan: $e");
      }
    });

    // Lấy dữ liệu theo ngôn ngữ
    final String audioUrl = artifact.audioUrl[language] ?? '';
    final String videoUrl = artifact.videoUrl[language] ?? '';
    final String description =
        artifact.description[language] ?? 'No description available.';
    final String imageUrl = artifact.imageUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, artifact.name),
      body: Stack(
        children: [
          Column(
            children: [
              // TOP: Video hoặc Hình ảnh
              if (videoUrl.isNotEmpty)
                VideoWidget(
                  videoUrl: 'http://192.168.1.44:3000$videoUrl',
                  sourceId: artifact.artifactId,
                  sourceType: 'artifact',
                )
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

          // BOTTOM: AudioWidget
          if (audioUrl.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 30,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 180,
                child: AudioWidget(
                  audioUrl: 'http://192.168.1.44:3000$audioUrl',
                  id: artifact.artifactId,
                  type: 'artifact',
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
      'http://192.168.1.44:3000$imageUrl',
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
      backgroundColor: Colors.white,
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
