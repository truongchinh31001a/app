import 'package:flutter/material.dart';
import '../services/story_service.dart';
import '../models/story.dart';

class StoryProvider extends ChangeNotifier {
  final StoryService storyService;

  StoryProvider({required this.storyService});

  List<Story> _stories = [];
  bool _isLoading = false;
  String? _error;

  List<Story> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStories() async {
    if (_stories.isNotEmpty) return; // Nếu đã tải, không tải lại

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await storyService.fetchStories();
      _stories = data.map((json) => Story.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<int, List<Story>> get playlists {
    final Map<int, List<Story>> groupedStories = {};

    for (var story in _stories) {
      if (!groupedStories.containsKey(story.areaId)) {
        groupedStories[story.areaId] = [];
      }
      groupedStories[story.areaId]!.add(story);
    }

    return groupedStories;
  }
}
