// import 'package:app/screens/detail_artifact_screen.dart';
// import 'package:app/screens/detail_story_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/audio_provider.dart';
// import '../providers/video_provider.dart';

// class MiniMediaControllerWidget extends StatelessWidget {
//   const MiniMediaControllerWidget({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final audioProvider = Provider.of<AudioProvider>(context);
//     final videoProvider = Provider.of<VideoProvider>(context);

//     // Kiểm tra xem có nội dung audio/video đang phát không
//     final isAudioPlaying = audioProvider.audioUrl.isNotEmpty;
//     final isVideoPlaying = videoProvider.videoUrl.isNotEmpty;

//     // Nếu không có nội dung audio/video đang phát, không hiển thị Mini Controller
//     if (!isAudioPlaying && !isVideoPlaying) {
//       return const SizedBox.shrink();
//     }

//     // Dữ liệu hiển thị
//     final isPlaying = isAudioPlaying
//         ? audioProvider.isPlaying
//         : videoProvider.controller?.value.isPlaying ?? false;
//     final title = isAudioPlaying
//         ? (audioProvider.currentStory?.name ?? audioProvider.currentArtifact?.name ?? "Audio Playing")
//         : (videoProvider.currentStory?.name ?? videoProvider.currentArtifact?.name ?? "Video Playing");

//     return Container(
//       margin: const EdgeInsets.all(8.0),
//       padding: const EdgeInsets.all(12.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             blurRadius: 4,
//             spreadRadius: 1,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Nút Play/Pause
//           IconButton(
//             icon: Icon(
//               isPlaying ? Icons.pause : Icons.play_arrow,
//               color: Colors.black,
//               size: 32,
//             ),
//             onPressed: isAudioPlaying
//                 ? audioProvider.togglePlayPause
//                 : () {
//                     if (isPlaying) {
//                       videoProvider.controller?.pause();
//                     } else {
//                       videoProvider.controller?.play();
//                     }
//                   },
//           ),
//           const SizedBox(width: 12),

//           // Thông tin nội dung
//           Expanded(
//             child: Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               maxLines: 1,
//             ),
//           ),

//           // Nút mở chi tiết
//           IconButton(
//             icon: const Icon(Icons.open_in_new, color: Colors.black),
//             onPressed: () {
//               if (isAudioPlaying) {
//                 _navigateToDetail(context, audioProvider);
//               } else {
//                 _navigateToDetail(context, videoProvider);
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   /// Điều hướng đến màn hình chi tiết
//   void _navigateToDetail(BuildContext context, dynamic provider) {
//     if (provider.currentScreenType == 'story' && provider.currentStory != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => DetailsStoryScreen(story: provider.currentStory!),
//         ),
//       );
//     } else if (provider.currentScreenType == 'artifact' && provider.currentArtifact != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ArtifactDetailScreen(artifact: provider.currentArtifact!),
//         ),
//       );
//     }
//   }
// }
