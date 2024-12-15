import 'dart:convert';

class Story {
  final int storyId;
  final int areaId;
  final String name;
  final Map<String, String> contentText; // Nội dung dạng ngôn ngữ
  final String imageUrl;
  final Map<String, String> videoUrl; // Video dạng ngôn ngữ
  final Map<String, String> audioUrl; // Audio dạng ngôn ngữ
  final String status;

  Story({
    required this.storyId,
    required this.areaId,
    required this.name,
    required this.contentText,
    required this.imageUrl,
    required this.videoUrl,
    required this.audioUrl,
    required this.status,
  });

  // Phương thức từ JSON
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      storyId: json['story_id'],
      areaId: json['area_id'],
      name: json['name'],
      contentText: Map<String, String>.from(jsonDecode(json['content_text'])),
      imageUrl: json['image_url'],
      videoUrl: Map<String, String>.from(jsonDecode(json['video_url'])),
      audioUrl: Map<String, String>.from(jsonDecode(json['audio_url'])),
      status: json['status'],
    );
  }
}
