class Artifact {
  final int artifactId;
  final String qrCode;
  final int areaId;
  final String name;
  final Map<String, String> description; // Mô tả dạng ngôn ngữ
  final String imageUrl;
  final Map<String, String> videoUrl; // Video dạng ngôn ngữ
  final Map<String, String> audioUrl; // Audio dạng ngôn ngữ
  final String status;

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
  });

  // Phương thức từ JSON
  factory Artifact.fromJson(Map<String, dynamic> json) {
    return Artifact(
      artifactId: json['artifact_id'],
      qrCode: json['qr_code'],
      areaId: json['area_id'],
      name: json['name'],
      description: Map<String, String>.from(json['description']),
      imageUrl: json['image_url'],
      videoUrl: Map<String, String>.from(json['video_url']),
      audioUrl: Map<String, String>.from(json['audio_url']),
      status: json['status'],
    );
  }
}
