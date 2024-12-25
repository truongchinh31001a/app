import 'package:flutter/material.dart';
import '../services/story_service.dart';
import '../models/story.dart';

class StoryProvider extends ChangeNotifier {
  final StoryService storyService;

  StoryProvider({required this.storyService});

  List<Story> _stories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Story> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Tìm Story theo `id`
  Story? getStoryById(int id) {
    return _stories.firstWhere(
      (story) => story.storyId == id,
    );
  }

  /// Lấy danh sách câu chuyện theo khu vực (`areaId`)
  List<Story> getStoriesByAreaId(int areaId) {
    return _stories.where((story) => story.areaId == areaId).toList();
  }

  /// Lấy danh sách câu chuyện và nhóm theo khu vực (`areaId`)
  Map<int, List<Story>> get playlists {
    final Map<int, List<Story>> groupedStories = {};

    for (var story in _stories) {
      groupedStories.putIfAbsent(story.areaId, () => []).add(story);
    }

    return groupedStories;
  }

  /// Tải danh sách câu chuyện từ API
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

  /// Làm mới danh sách câu chuyện
  Future<void> refreshStories() async {
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
}
