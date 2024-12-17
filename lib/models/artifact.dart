import 'dart:convert';

class Artifact {
  final int artifactId;
  final String qrCode;
  final int areaId;
  final String name;
  final Map<String, dynamic> description;
  final String imageUrl;
  final Map<String, dynamic> videoUrl;
  final Map<String, dynamic> audioUrl;
  final String status;
  final String qrImage;

  Artifact({
    required this.artifactId,
    required this.qrCode,
    required this.areaId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.videoUrl,
    required this.audioUrl,
    required this.status,
    required this.qrImage,
  });

  factory Artifact.fromJson(Map<String, dynamic> json) {
    return Artifact(
      artifactId: json['artifact_id'],
      qrCode: json['qr_code'],
      areaId: json['area_id'],
      name: json['name'],
      description: json['description'] is String
          ? jsonDecode(json['description'])
          : json['description'],
      imageUrl: json['image_url'] ?? '',
      videoUrl: json['video_url'] is String
          ? jsonDecode(json['video_url'])
          : json['video_url'],
      audioUrl: json['audio_url'] is String
          ? jsonDecode(json['audio_url'])
          : json['audio_url'],
      status: json['status'] ?? '',
      qrImage: json['qr_image'] ?? '',
    );
  }
}
